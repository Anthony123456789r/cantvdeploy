from django.shortcuts import redirect
from django.urls import reverse
from .views import login
import time
from django.shortcuts import render
from datetime import datetime, timedelta
from django.http import HttpResponse

class AuthRequiredMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        allowed_paths = [reverse('loginSeleccion'), reverse('registro'), reverse('loginSistema'), reverse('loginUser')]
        current_path = request.path

        if not request.session.get('usuario') and request.path not in allowed_paths:
            return redirect('loginSeleccion')

        response = self.get_response(request)
        return response
    