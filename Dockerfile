# Usa una imagen base de Python. 'slim-bookworm' es una buena opción porque es más pequeña.
FROM python:3.11-slim-bookworm

# Instala espeak y limpia el caché de apt-get para reducir el tamaño de la imagen.
# Esto se ejecuta durante la construcción de la imagen, no en tiempo de ejecución.
RUN apt-get update && apt-get install -y espeak && rm -rf /var/lib/apt/lists/*

# Establece el directorio de trabajo dentro del contenedor.
WORKDIR /app

# Copia los archivos de configuración de Poetry primero para aprovechar el caché de Docker.
# Esto es si estás usando Poetry para la gestión de dependencias.
COPY pyproject.toml poetry.lock /app/

# Instala Poetry y luego las dependencias del proyecto.
# poetry config virtualenvs.create false evita que Poetry cree un entorno virtual separado
# dentro del contenedor, ya que ya estamos en uno.
RUN pip install poetry
RUN poetry config virtualenvs.create false
RUN poetry install --no-root --no-dev

# Copia el resto de tu código de la aplicación.
COPY . /app/

# Recopila archivos estáticos y ejecuta migraciones.
# Esto también se hace durante la construcción de la imagen.
RUN python manage.py collectstatic --noinput
RUN python manage.py migrate

# Expone el puerto en el que Gunicorn va a escuchar.
EXPOSE 8000

# Comando para iniciar tu aplicación con Gunicorn.
# Asegúrate de reemplazar 'your_project_name' con el nombre real de tu proyecto Django
# (el nombre de la carpeta que contiene settings.py y wsgi.py).
CMD ["gunicorn", "sistema_canTV.wsgi:application", "--bind", "0.0.0.0:$PORT"]