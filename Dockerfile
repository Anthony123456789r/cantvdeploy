# Usa una imagen base de Python. 'slim-bookworm' es una buena opción porque es más pequeña.
FROM python:3.11-slim-bookworm

# Instala espeak y un conjunto más completo de dependencias de OpenCV y audio.
# 'build-essential' incluye herramientas de compilación básicas.
# 'libgl1-mesa-glx' es para libGL.so.1.
# 'libsm6', 'libxext6', 'libxrender1', 'libfontconfig1', 'libice6' son librerías X11/gráficas comunes.
# 'libatlas-base-dev' es para optimizaciones numéricas, a menudo usadas por NumPy/SciPy (que OpenCV usa).
# 'libhdf5-dev', 'libjpeg-dev', 'libpng-dev', 'libtiff-dev' son para soporte de formatos de imagen.
# 'libglib2.0-0' es para libgthread-2.0.so.0 y otras dependencias de GLib.
# 'alsa-utils' proporciona 'aplay' para la reproducción de audio, necesaria para espeak.
# Limpia el caché de apt-get para reducir el tamaño de la imagen.
RUN apt-get update && apt-get install -y \
    espeak \
    build-essential \
    libgl1-mesa-glx \
    libsm6 \
    libxext6 \
    libxrender1 \
    libfontconfig1 \
    libice6 \
    libatlas-base-dev \
    libhdf5-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libglib2.0-0 \
    alsa-utils \
    && rm -rf /var/lib/apt/lists/*

# Establece el directorio de trabajo dentro del contenedor.
WORKDIR /app

# Crea un usuario no-root.
# Esto mejora la seguridad al no ejecutar la aplicación como root.
RUN adduser --system --group appuser

# Crea un directorio para el caché de pip y asegúrate de que appuser tenga permisos.
# Esto resuelve el error "Permission denied" al instalar paquetes.
RUN mkdir -p /home/appuser/.cache/pip \
    && chown -R appuser:appuser /home/appuser/.cache

# Copia el archivo requirements.txt primero para aprovechar el caché de Docker.
COPY requirements.txt /app/

# Cambia al usuario no-root para instalar las dependencias de Python.
USER appuser

# Instala las dependencias de Python usando pip.
# Establece la variable de entorno PIP_CACHE_DIR para que pip use el directorio que creamos.
ENV PIP_CACHE_DIR=/home/appuser/.cache/pip
RUN pip install -r requirements.txt

# Vuelve a root temporalmente para copiar el resto del código
USER root
COPY . /app/

# Cambia la propiedad de los archivos copiados al usuario no-root.
# Esto es esencial para que appuser pueda leer y escribir los archivos de la aplicación.
RUN chown -R appuser:appuser /app

# Vuelve al usuario no-root para ejecutar los comandos de Django y la aplicación.
USER appuser

# Recopila archivos estáticos y ejecuta migraciones.
# Esto se hace durante la construcción de la imagen para preparar la aplicación.
RUN python manage.py collectstatic --noinput
RUN python manage.py migrate

# Expone el puerto en el que Gunicorn va a escuchar.
EXPOSE 8000

# Comando para iniciar tu aplicación con Gunicorn.
CMD gunicorn sistema_canTV.wsgi:application --bind 0.0.0.0:$PORT
