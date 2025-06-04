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
    git \
    && rm -rf /var/lib/apt/lists/*

# Establece el directorio de trabajo dentro del contenedor.
WORKDIR /app

# Crea un usuario no-root.
# Esto mejora la seguridad al no ejecutar la aplicación como root.
RUN adduser --system --group appuser

# Crea directorios para el caché de pip y temporales, y asegúrate de que appuser tenga permisos.
# !!! CRÍTICO: Asegura que /tmp y /var/tmp existan y sean accesibles para appuser ANTES de cambiar a appuser
RUN mkdir -p /home/appuser/.cache/pip \
    && mkdir -p /app/tmp \
    && mkdir -p /tmp \
    && mkdir -p /var/tmp \
    && chown -R appuser:appuser /home/appuser/.cache \
    && chown -R appuser:appuser /app/tmp \
    && chown -R appuser:appuser /tmp \
    && chown -R appuser:appuser /var/tmp \
    && chown -R appuser:appuser /app # Otorga a appuser la propiedad de /app *después* de crearlo

# Copia el archivo requirements.txt.
COPY requirements.txt /app/

# Cambia al usuario no-root para instalar las dependencias de Python.
USER appuser

# Establece las variables de entorno PIP_CACHE_DIR y TMPDIR para que pip use directorios que el usuario posee.
# También establece TEMP y TEMPDIR para mayor compatibilidad.
ENV PIP_CACHE_DIR=/home/appuser/.cache/pip
ENV TMPDIR=/app/tmp
ENV TEMP=/app/tmp
ENV TEMPDIR=/app/tmp

# --- INTENTO 1: Actualizar pip y luego instalar requirements ---
# Esto es lo primero que probaremos.
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# --- INTENTO 2 (Alternativa si INTENTO 1 falla): Instalar requirements sin caché ---
# Descomentar la siguiente línea si el intento 1 falla y el problema persiste con '/nonexistent'
# y comentar la línea "RUN pip install -r requirements.txt" de arriba.
# RUN pip install --no-cache-dir -r requirements.txt

# Vuelve a root temporalmente para copiar el resto del código.
USER root
COPY . /app/

# Cambia la propiedad de los archivos copiados al usuario no-root.
RUN chown -R appuser:appuser /app

# Vuelve al usuario no-root para ejecutar los comandos de Django y la aplicación.
USER appuser

# Recopila archivos estáticos y ejecuta migraciones.
RUN python manage.py collectstatic --noinput
RUN python manage.py migrate

# Expone el puerto en el que Gunicorn va a escuchar.
EXPOSE 8000

# Comando para iniciar tu aplicación con Gunicorn.
CMD gunicorn sistema_canTV.wsgi:application --bind 0.0.0.0:$PORT