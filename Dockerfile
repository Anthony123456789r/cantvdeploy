# Usa una imagen base de Python. 'slim-bookworm' es una buena opción porque es más pequeña.
FROM python:3.11-slim-bookworm

# Instala espeak y las dependencias de OpenCV (libGL.so.1 y otras comunes)
# y limpia el caché de apt-get para reducir el tamaño de la imagen.
# 'espeak' es para la funcionalidad de texto a voz.
# 'libgl1-mesa-glx', 'libsm6', 'libxext6', 'libxrender1' son dependencias comunes para OpenCV
# en sistemas basados en Debian/Ubuntu (como Bookworm).
RUN apt-get update && apt-get install -y \
    espeak \
    libgl1-mesa-glx \
    libsm6 \
    libxext6 \
    libxrender1 \
    && rm -rf /var/lib/apt/lists/*

# Establece el directorio de trabajo dentro del contenedor.
WORKDIR /app

# Copia el archivo requirements.txt primero para aprovechar el caché de Docker.
# Esto es crucial para que Docker pueda instalar las dependencias de Python.
# Asegúrate de que 'requirements.txt' esté en la raíz de tu proyecto y no contenga 'pywin32'.
COPY requirements.txt /app/

# Instala las dependencias de Python usando pip.
RUN pip install -r requirements.txt

# Copia el resto de tu código de la aplicación.
# Esto debe hacerse después de instalar las dependencias para optimizar el caché de Docker.
COPY . /app/

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
# Gunicorn es el servidor WSGI que ejecutará tu aplicación Django en producción.
CMD ["gunicorn", "sistema_canTV.wsgi:application", "--bind", "0.0.0.0:$PORT"]