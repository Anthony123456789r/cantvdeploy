from django import forms
from .models import ExcelData
from django.core.exceptions import ValidationError

class ExcelForm(forms.ModelForm):
    class Meta:
        model = ExcelData
        fields = '__all__'