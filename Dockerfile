# Usa una imagen base de Python. 'slim-bookworm' es una buena opción porque es más pequeña.
FROM python:3.11-slim-bookworm

# Instala espeak y un conjunto más completo de dependencias de OpenCV y audio.
# 'build-essential' incluye herramientas de compilación básicas.
# 'libgl1-mesa-glx' es para libGL.so.1 (dependencia de OpenCV).
# 'libsm6', 'libxext6', 'libxrender1', 'libfontconfig1', 'libice6' son librerías X11/gráficas comunes para OpenCV.
# 'libatlas-base-dev' es para optimizaciones numéricas, a menudo usadas por NumPy/SciPy (que OpenCV usa).
# 'libhdf5-dev', 'libjpeg-dev', 'libpng-dev', 'libtiff-dev' son para soporte de formatos de imagen en OpenCV.
# 'libglib2.0-0' es para libgthread-2.0.so.0 y otras dependencias de GLib (para OpenCV).
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

# Crea directorios para el caché de pip y temporales, y asegúrate de que appuser tenga permisos.
# Esto resuelve el error "Permission denied" al instalar paquetes.
RUN mkdir -p /home/appuser/.cache/pip \
    && mkdir -p /app/tmp \
    && chown -R appuser:appuser /home/appuser/.cache \
    && chown -R appuser:appuser /app/tmp

# Copia el archivo requirements.txt primero para aprovechar el caché de Docker.
# Asegúrate de que 'requirements.txt' esté en la raíz de tu proyecto y no contenga 'pywin32'.
COPY requirements.txt /app/

# Cambia al usuario no-root para instalar las dependencias de Python.
USER appuser

# Instala las dependencias de Python usando pip.
# Establece las variables de entorno PIP_CACHE_DIR y TMPDIR para que pip use directorios que el usuario posee.
ENV PIP_CACHE_DIR=/home/appuser/.cache/pip
ENV TMPDIR=/app/tmp
RUN pip install -r requirements.txt

# Vuelve a root temporalmente para copiar el resto del código.
# Es necesario volver a root para copiar archivos si el usuario no-root no tiene permisos en la raíz del contexto de build.
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
# Render usará esta información para dirigir el tráfico.
EXPOSE 8000

# Comando para iniciar tu aplicación con Gunicorn.
# 'sistema_canTV' es el nombre de la carpeta de tu proyecto Django
# (la que contiene settings.py y wsgi.py).
# Usamos la "shell form" para que la variable $PORT sea expandida correctamente por Render.
CMD gunicorn sistema_canTV.wsgi:application --bind 0.0.0.0:$PORT
