# Usa una imagen base de Python. 'slim-bookworm' es una buena opción porque es más pequeña.
FROM python:3.11-slim-bookworm

# Instala espeak y limpia el caché de apt-get para reducir el tamaño de la imagen.
# Esto se ejecuta durante la construcción de la imagen, no en tiempo de ejecución.
RUN apt-get update && apt-get install -y espeak && rm -rf /var/lib/apt/lists/*

# Establece el directorio de trabajo dentro del contenedor.
WORKDIR /app

# Copia el archivo requirements.txt primero para aprovechar el caché de Docker.
# Esto es crucial para que Docker pueda instalar las dependencias.
COPY requirements.txt /app/

# Instala las dependencias de Python usando pip.
RUN pip install -r requirements.txt

# Copia el resto de tu código de la aplicación.
COPY . /app/

# Recopila archivos estáticos y ejecuta migraciones.
# Esto también se hace durante la construcción de la imagen.
RUN python manage.py collectstatic --noinput
RUN python manage.py migrate

# Expone el puerto en el que Gunicorn va a escuchar.
EXPOSE 8000

# Comando para iniciar tu aplicación con Gunicorn.
# Asegúrate de que 'sistema_canTV' sea el nombre real de la carpeta de tu proyecto Django
# (la que contiene settings.py y wsgi.py).
CMD ["gunicorn", "sistema_canTV.wsgi:application", "--bind", "0.0.0.0:$PORT"]