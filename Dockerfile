# Usa una imagen base de Python. 'slim-bookworm' es una buena opción porque es más pequeña.
FROM python:3.11-slim-bookworm

# Instala espeak y un conjunto más completo de dependencias de OpenCV y audio.
# Instala también python3-pip directamente en el sistema como root.
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
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Establece el directorio de trabajo dentro del contenedor.
WORKDIR /app

# Crea un usuario no-root.
RUN adduser --system --group appuser

# Crea el directorio home para appuser si no existe (adduser --system no siempre lo hace)
# y asegúrate de que appuser tenga permisos sobre él.
# Esto es CRÍTICO para que --user funcione correctamente.
RUN mkdir -p /home/appuser \
    && chown -R appuser:appuser /home/appuser

# Crea directorios para el caché de pip y temporales, y asegúrate de que appuser tenga permisos.
# Aseguramos que /tmp y /var/tmp sean propiedad de appuser explícitamente.
RUN mkdir -p /home/appuser/.cache/pip \
    && mkdir -p /app/tmp \
    && mkdir -p /tmp \
    && mkdir -p /var/tmp \
    && chown -R appuser:appuser /home/appuser/.cache \
    && chown -R appuser:appuser /app/tmp \
    && chown -R appuser:appuser /tmp \
    && chown -R appuser:appuser /var/tmp \
    && chown -R appuser:appuser /app

# Copia el archivo requirements.txt.
COPY requirements.txt /app/

# Cambia al usuario no-root para instalar las dependencias de Python.
USER appuser

# Establece las variables de entorno para pip y temporales.
# PYTHONUSERBASE es crucial para asegurar que la instalación --user funcione correctamente.
ENV PIP_CACHE_DIR=/home/appuser/.cache/pip
ENV TMPDIR=/app/tmp
ENV TEMP=/app/tmp
ENV TEMPDIR=/app/tmp
ENV PYTHONUSERBASE=/home/appuser/.local

# Limpia la caché de pip (si existe de un intento anterior) antes de instalar.
RUN rm -rf $PIP_CACHE_DIR/*

# Intento 1: Actualizar pip para el usuario
# Pasamos las variables de entorno explícitamente al comando pip.
# Añadimos --break-system-packages para evitar problemas con las instalaciones del sistema.
RUN TMPDIR=$TMPDIR TEMP=$TEMP TEMPDIR=$TEMPDIR \
    PIP_CACHE_DIR=$PIP_CACHE_DIR \
    python3 -m pip install --upgrade pip \
    --user --no-warn-script-location --break-system-packages \
    || echo "Pip upgrade failed, but will proceed (likely due to base system pip issues)."

# Intento 2: Instalar las dependencias de Python.
# Si el error persiste, intenta descomentar la línea con --no-cache-dir.
RUN TMPDIR=$TMPDIR TEMP=$TEMP TEMPDIR=$TEMPDIR \
    PIP_CACHE_DIR=$PIP_CACHE_DIR \
    python3 -m pip install -r requirements.txt \
    --user --no-warn-script-location --break-system-packages

# --- ALTERNATIVA SI LO ANTERIOR FALLA (Descomentar y comentar la línea de arriba) ---
# RUN TMPDIR=$TMPDIR TEMP=$TEMP TEMPDIR=$TEMPDIR \
#     PIP_CACHE_DIR=$PIP_CACHE_DIR \
#     python3 -m pip install --no-cache-dir -r requirements.txt \
#     --user --no-warn-script-location --break-system-packages

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