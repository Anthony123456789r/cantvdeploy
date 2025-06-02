from django.db import models
from django.contrib.auth.hashers import make_password
from datetime import datetime
import pytz
from django.contrib.auth.models import AbstractUser
import random
import string
from django.utils import timezone
# Create your models here.

    
class regisODN(models.Model):
    id = models.AutoField(primary_key=True)
    odn = models.TextField(max_length=250)
    olt = models.TextField(max_length=250)
    cantidadFat = models.IntegerField()
    direccion = models.TextField(max_length=350)
    observacion = models.TextField(max_length=150)

    
class regisFAT(models.Model):
    id = models.AutoField(primary_key=True)
    dato_fat = models.ForeignKey(regisODN,on_delete=models.CASCADE,null=True)
    direccionFat = models.TextField(max_length=150)
    observacionFat = models.TextField(max_length=150,null=True)
    fat = models.TextField(max_length=150)
#========PLANES DE CANTV===========
class tipoReporte(models.Model):
    id = models.AutoField(primary_key=True)
    tipo = models.TextField(max_length=255)
class planes(models.Model):
    id = models.AutoField(primary_key=True)
    plan = models.TextField(max_length=255)
# ============ESTADO DEL REPORTE DEL CLIENTE========
class estadoReporte(models.Model):
    id = models.AutoField(primary_key=True)
    estadoReporter = models.TextField(max_length=255)
#======ESTADO DEL TECNICO======
class estadoTecnico(models.Model):
    id = models.AutoField(primary_key=True)
    estado = models.TextField(max_length=150)
#=============TABLA DE ROLES===============
class rangos(models.Model):
    id = models.AutoField(primary_key=True)
    rango = models.TextField(max_length=200)
#==================================================
#=================SECCION DE AUDITORIA=============================

#=======================================================
#==========TABLA DE ADMIN================================

class admin(models.Model):
    id = models.IntegerField(primary_key=True)
    nombre = models.TextField(max_length=200)
    apellido = models.TextField(max_length=200)
    cedula = models.TextField(unique=True, max_length=8)
    tipo_rango = models.ForeignKey(rangos,on_delete=models.CASCADE)
    telefono = models.CharField(max_length=11,unique=True)
    direccion = models.CharField(max_length=250)
    eliminado = models.BooleanField(default=False)

    def save(self, *args, **kwargs):
        if not self.id:
            self.id = 7006000 + admin.objects.count() + 1
        super(admin, self).save(*args, **kwargs)

class tiposPermisos(models.Model):
    id = models.AutoField(primary_key=True)
    tipoPermiso = models.TextField(max_length=150)
    descripcion = models.TextField(max_length=250,null=True)
    estadoPermiso = models.BooleanField(default=False)
    admins_con_permiso = models.ManyToManyField(admin, through='Permiso')

    def __str__(self):
        return self.tipoPermiso
    
#========TABLA DE SUBADMIN============
class subAdmin(models.Model):
    id = models.IntegerField(primary_key=True)
    nombre = models.TextField(max_length=200)
    apellido = models.TextField(max_length=200)
    cedula = models.TextField(unique=True, max_length=8)
    tipo_rango = models.ForeignKey(rangos,on_delete=models.CASCADE)
    eliminado = models.BooleanField(default=False)
    telefono = models.CharField(max_length=11,unique=True)
    direccion = models.CharField(max_length=250)

    def save(self, *args, **kwargs):
        if not self.id:
            self.id = 7003000 + subAdmin.objects.count() + 1
        super(subAdmin, self).save(*args, **kwargs)

#=========TABLA DE TECNICO O EMPLEADO=========
class tecnico(models.Model):
    id = models.IntegerField(primary_key=True)
    nombre = models.TextField(max_length=200)
    apellido = models.TextField(max_length=200)
    cedula = models.TextField(unique=True, max_length=8)
    huella = models.TextField(max_length=120, null=True)
    tipo_rango = models.ForeignKey(rangos,on_delete=models.CASCADE)
    estado = models.ForeignKey(estadoTecnico, on_delete=models.CASCADE)
    eliminado = models.BooleanField(default=False)
    telefono = models.CharField(max_length=11,unique=True)
    direccion = models.CharField(max_length=250)

    def save(self, *args, **kwargs):
        if not self.id:
            self.id = 7001000 + tecnico.objects.count() + 1
        super(tecnico, self).save(*args, **kwargs)
#==========TABLA DE CLIENTES O USUARIOS===========
class cliente(models.Model):
    id = models.BigIntegerField(primary_key=True)
    ond_fat = models.ForeignKey(regisODN,on_delete=models.CASCADE)
    apellido = models.TextField(max_length=150)
    nombre = models.CharField(max_length=100)
    fat1 = models.ForeignKey(regisFAT,on_delete=models.CASCADE)
    cedula= models.CharField(max_length=15)
    contacto = models.CharField(max_length=100)
    direccion = models.CharField(max_length=200)
    cuadrilla = models.CharField(max_length=100)
    posicion_fat = models.CharField(max_length=100)
    potencia_fat = models.CharField(max_length=100)
    potencia_casa = models.CharField(max_length=100)
    eliminado = models.BooleanField(default=False)
    servicio = models.ForeignKey(planes,on_delete=models.CASCADE)
    tipo_rango = models.ForeignKey(rangos,on_delete=models.CASCADE)
    correo = models.EmailField(max_length=150)

    def save(self, *args, **kwargs):
        if not self.id:
            last_id = cliente.objects.order_by('-id').first()
            if last_id:
                self.id = last_id.id + 1
            else:
                self.id = 700400100
        super().save(*args, **kwargs)
        
class reporteCliente(models.Model):
    id = models.AutoField(primary_key=True)
    categoria = models.TextField(max_length=250)
    falla = models.TextField(max_length=250,null=True)
    DatosCliente = models.ForeignKey(cliente, on_delete=models.CASCADE)
    fecha = models.DateTimeField(auto_now_add=True)
    eliminado = models.BooleanField(default=False)
    status = models.ForeignKey(estadoReporte,on_delete=models.CASCADE)
    status_valor = models.ForeignKey(estadoReporte,on_delete=models.CASCADE,related_name="estadoReporte_admin")
    valor = models.BooleanField()
    capture = models.ImageField(upload_to="testeos/",null=True, blank=True)
    codigo_qr = models.ImageField(upload_to='qr_codes/', null=True, blank=True)
    luces = models.CharField(max_length=250)
    description = models.TextField(max_length=500)
    def formatted_fecha(self):
        timezone = pytz.timezone('America/Caracas')  # Zona horaria de Venezuela
        fecha_formateada = self.fecha.astimezone(timezone).strftime("%m/%d/%Y %I:%M %p")
        return fecha_formateada
    
    
class reportesParaTecnico(models.Model):
    id = models.AutoField(primary_key=True)
    Datos_Cliente = models.ForeignKey(cliente,on_delete=models.SET_NULL,null=True)
    DatosCliente_id = models.BigIntegerField(null=True,blank=True)
    DatosCliente_nombre = models.TextField(null=True,blank=True)
    DatosCliente_cedula = models.TextField(null=True,blank=True)
    DatosCliente_falla = models.TextField(null=True,blank=True)
    DatosCliente_FechaCreacion = models.DateTimeField(auto_now_add=False,null=True)
    DatosReporteCliente = models.ForeignKey(reporteCliente, on_delete=models.SET_NULL,null=True)
    DatosTecnico = models.ForeignKey(tecnico, on_delete=models.CASCADE)
    status = models.ForeignKey(estadoReporte, on_delete=models.CASCADE,null=True)
    mas_informacion_tecnico = models.TextField(max_length=255,null=True)
    fecha_gestion = models.DateTimeField(auto_now_add=False,null=True)
    tipo_reporte = models.ForeignKey(tipoReporte,on_delete=models.CASCADE)
    def formatted_fecha_gestion(self):
        timezone = pytz.timezone('America/Caracas')  # Zona horaria de Venezuela
        fecha_formateada = self.fecha_gestion.astimezone(timezone).strftime("%m/%d/%Y %I:%M %p")
        return fecha_formateada
    def formatted_fecha_gestionn(self):
        timezone = pytz.timezone('America/Caracas')  # Zona horaria de Venezuela
        fecha_formateadaa = self.DatosCliente_FechaCreacion.astimezone(timezone).strftime("%m/%d/%Y %I:%M %p")
        return fecha_formateadaa

#=================SECCION DE AUDITORIA=============================

#=======================================================
class Permiso(models.Model):
    admin = models.ForeignKey(admin, on_delete=models.CASCADE,null=True)
    sub_admin = models.ForeignKey(subAdmin, null=True, blank=True, on_delete=models.CASCADE)
    tecnico = models.ForeignKey(tecnico, null=True, blank=True, on_delete=models.CASCADE)
    cliente = models.ForeignKey(cliente, null=True, blank=True, on_delete=models.CASCADE)
    tipo_permiso = models.ForeignKey(tiposPermisos, on_delete=models.CASCADE)

    
    
class peticionesCliente(models.Model):
    id = models.AutoField(primary_key=True)
    peticion = models.TextField(max_length=150,null=True)
    tema = models.TextField(max_length=150,null=True)
    datosCliente = models.ForeignKey(cliente,on_delete=models.CASCADE)
    tipo_de_reporte = models.ForeignKey(tipoReporte,on_delete=models.CASCADE)

class RespaldoNinja(models.Model):
    id = models.AutoField(primary_key=True)
    nombre = models.TextField(max_length=150,null=True)
    apellido = models.TextField(max_length=150,null=True)
    cedula = models.TextField(max_length=150,null=True)
    fat = models.TextField(max_length=150,null=True)
    correo = models.TextField(max_length=150,null=True)
    cuadrilla = models.TextField(max_length=150,null=True)
    odn = models.TextField(max_length=150,null=True)
    telefono = models.TextField(max_length=150,null=True)
    potencia_casa = models.TextField(max_length=150,null=True)
    potencia_fat = models.TextField(max_length=150,null=True)
    rango = models.TextField(max_length=150,null=True)
    fecha_retiro = models.DateField(auto_now_add=False,null=True)


    
    

