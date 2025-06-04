# Usa una imagen base de Python. 'slim-bookworm' es una buena opción porque es más pequeña.
FROM python:3.11-slim-bookworm

# Instala espeak y un conjunto más completo de dependencias de OpenCV.
# 'build-essential' incluye herramientas de compilación básicas.
# 'libgl1-mesa-glx' es para libGL.so.1.
# 'libsm6', 'libxext6', 'libxrender1', 'libfontconfig1', 'libice6' son librerías X11/gráficas comunes.
# 'libatlas-base-dev' es para optimizaciones numéricas, a menudo usadas por NumPy/SciPy (que OpenCV usa).
# 'libhdf5-dev', 'libjpeg-dev', 'libpng-dev', 'libtiff-dev' son para soporte de formatos de imagen.
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
    && rm -rf /var/lib/apt/lists/*

# Establece el directorio de trabajo dentro del contenedor.
WORKDIR /app

# Copia el archivo requirements.txt primero para aprovechar el caché de Docker.
# Asegúrate de que 'requirements.txt' esté en la raíz de tu proyecto y no contenga 'pywin32'.
COPY requirements.txt /app/

# Instala las dependencias de Python usando pip.
RUN pip install -r requirements.txt

# Copia el resto de tu código de la aplicación.
COPY . /app/

# Recopila archivos estáticos y ejecuta migraciones.
# Esto se hace durante la construcción de la imagen para preparar la aplicación.
RUN python manage.py collectstatic --noinput
RUN python manage.py migrate

# Expone el puerto en el que Gunicorn va a escuchar.
EXPOSE 8000

# Comando para iniciar tu aplicación con Gunicorn.
# 'sistema_canTV' es el nombre de la carpeta de tu proyecto Django
# (la que contiene settings.py y wsgi.py).
CMD ["gunicorn", "sistema_canTV.wsgi:application", "--bind", "0.0.0.0:$PORT"]