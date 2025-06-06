"""
Django settings for sistema_canTV project.

Generated by 'django-admin startproject' using Django 4.1.7.

For more information on this file, see
https://docs.djangoproject.com/en/4.1/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/4.1/ref/settings/
"""
import os
from pathlib import Path
import dj_database_url

# Construye rutas dentro del proyecto así: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

# --- Configuración General ---

# ¡ADVERTENCIA DE SEGURIDAD: mantén la clave secreta utilizada en producción en secreto!
# Usa una variable de entorno para la clave secreta en producción.
# El valor de respaldo es SOLO para desarrollo local si la variable de entorno no está configurada.
SECRET_KEY = os.environ.get('SECRET_KEY', 'django-insecure-i&tbyp58m=g!__x5a*eiori9dkw-3hm2-vk2_$carukl4xbbhj')

# ¡ADVERTENCIA DE SEGURIDAD: no ejecutes con DEBUG activado en producción!
# DEBUG debe ser False en producción para evitar fugas de información sensible.
# 'True' es el valor por defecto si DJANGO_DEBUG no está en las variables de entorno.
DEBUG = os.environ.get('DJANGO_DEBUG', 'True') == 'True'

# --- ALLOWED_HOSTS para Render ---
# Render establece la variable de entorno 'RENDER_EXTERNAL_HOSTNAME' automáticamente.
# Si estás usando un dominio personalizado en Render, DEBES añadirlo aquí o en la variable de entorno ALLOWED_HOSTS en Render.
RENDER_HOSTNAME = os.environ.get('RENDER_EXTERNAL_HOSTNAME')

if RENDER_HOSTNAME:
    ALLOWED_HOSTS = [RENDER_HOSTNAME, 'localhost', '127.0.0.1']
else:
    # Este fallback es útil si no se detecta RENDER_EXTERNAL_HOSTNAME.
    # '.onrender.com' permite cualquier subdominio de onrender.com.
    # La variable de entorno 'ALLOWED_HOSTS' en Render puede anular esto si se setea.
    ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', '.onrender.com,localhost,127.0.0.1').split(',')


# Definición de la aplicación
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'cantv_sistema',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware', # Añadir WhiteNoise para servir archivos estáticos
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    # 'cantv_sistema.middleware.AuthRequiredMiddleware', # Comenta o descomenta según tus pruebas
]

ROOT_URLCONF = 'sistema_canTV.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'sistema_canTV.wsgi.application'

# --- Configuración de la Base de Datos ---
# Usa dj_database_url para analizar la variable de entorno DATABASE_URL de Render.
# EL VALOR DE RESPALDO (DEFAULT) DEBE COINCIDIR EXACTAMENTE CON LA URL DE NEON CORRECTA.
DATABASES = {
    'default': dj_database_url.config(
        default=os.environ.get('DATABASE_URL', 'postgresql://er_owner:npg_14YxtGgfcdwq@ep-holy-pond-a8vw466q-pooler.eastus2.azure.neon.tech/er?sslmode=require'),
        conn_max_age=600, # Opcional: controla cuánto tiempo se almacenan en caché las conexiones
        ssl_require=True # Asegura que SSL sea requerido para producción (importante para Neon)
    )
}

# --- Validación de Contraseñas ---
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# --- Internacionalización ---
LANGUAGE_CODE = 'es-latam'
TIME_ZONE = 'America/Caracas'
USE_I18N = True
USE_TZ = True

# --- Archivos Estáticos y de Medios ---
# Recoge los archivos estáticos en un solo directorio para producción
STATIC_ROOT = BASE_DIR / 'staticfiles'
STATIC_URL = '/static/' # Cambiado por consistencia, será servido por WhiteNoise

# Directorios adicionales donde Django debe buscar archivos estáticos
STATICFILES_DIRS = [
    BASE_DIR / 'cantv_sistema' / 'static',
]

# Configura WhiteNoise para comprimir y cachear archivos estáticos
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

MEDIA_ROOT = BASE_DIR / 'media'
MEDIA_URL = '/media/'

# Tipo de campo de clave primaria por defecto
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

LANGUAGES = [
    ('en', 'English'),
    ('es', 'Español'),
    ('es-latam', 'Español (Latinoamérica)'),
]

# Directorio para archivos de Excel (plantillas, etc.)
EXCEL_FILES_DIR = BASE_DIR / 'cantv_sistema' / 'hojas_excel'