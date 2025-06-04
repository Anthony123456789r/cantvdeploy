"""
WSGI config for sistema_canTV project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/4.1/howto/deployment/wsgi/
"""

# sistema_canTV/wsgi.py

import os

from django.core.wsgi import get_wsgi_application
from whitenoise import WhiteNoise

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'sistema_canTV.settings')

# Obtén la aplicación WSGI original de Django
_application = get_wsgi_application()

# Envuelve la aplicación de Django con WhiteNoise
# y asigna el resultado a la variable 'application' que Gunicorn espera.
application = WhiteNoise(_application)

# Opcional: Si tienes archivos estáticos adicionales que WhiteNoise deba servir
# fuera de STATICFILES_DIRS, puedes añadirlos aquí.
# Por ejemplo:
# application.add_files('/ruta/absoluta/a/otra/carpeta/de/estaticos', prefix='otros-estaticos/')