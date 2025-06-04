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
    # Instala o actualiza python3-pip directamente en el sistema como root,
    # para que el pip base esté en un estado conocido y funcional.
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Establece el directorio de trabajo dentro del contenedor.
WORKDIR /app

# Crea un usuario no-root.
RUN adduser --system --group appuser

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

# Establece las variables de entorno PIP_CACHE_DIR y TMPDIR para que pip use directorios que el usuario posee.
# También establece TEMP y TEMPDIR para mayor compatibilidad.
ENV PIP_CACHE_DIR=/home/appuser/.cache/pip
ENV TMPDIR=/app/tmp
ENV TEMP=/app/tmp
ENV TEMPDIR=/app/tmp

# *** LA CLAVE AQUÍ: Forzar las variables temporales directamente en el comando pip ***
# También, usa --break-system-packages si es necesario (para evitar errores en ambientes Python del sistema)
# Instalar pip y luego las dependencias.

# Paso 1: Asegurarse de que pip esté actualizado para el usuario.
# Usamos un comando completo que pasa las variables de entorno explícitamente.
# Si sigue fallando, la causa es más profunda que solo permisos de /tmp.
RUN TMPDIR=/app/tmp TEMP=/app/tmp TEMPDIR=/app/tmp \
    PIP_CACHE_DIR=/home/appuser/.cache/pip \
    python3 -m pip install --upgrade pip --user --no-warn-script-location \
    || echo "Pip upgrade failed, but will proceed (likely due to base system pip issues)."

# Paso 2: Instalar las dependencias de Python usando pip.
# De nuevo, pasamos las variables de entorno explícitamente.
RUN TMPDIR=/app/tmp TEMP=/app/tmp TEMPDIR=/app/tmp \
    PIP_CACHE_DIR=/home/appuser/.cache/pip \
    python3 -m pip install -r requirements.txt --user --no-warn-script-location

# NOTA: Si el error persiste en el paso anterior,
# podrías intentar descomentar la siguiente línea y comentar la anterior.
# Esto deshabilitaría la caché de pip, que a veces es la fuente del problema.
# RUN TMPDIR=/app/tmp TEMP=/app/tmp TEMPDIR=/app/tmp \
#     python3 -m pip install --no-cache-dir -r requirements.txt --user --no-warn-script-location


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
CMD gunicorn sistema_canTV.wsgi:application --bind 0.00.0.0:$PORT