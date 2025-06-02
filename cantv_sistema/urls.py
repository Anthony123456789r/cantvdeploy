from django.urls import path
from django.urls import include
from . import views

urlpatterns = [
    #====VISTAS PRINCIPALES DE LA PAGINA====
    path('',views.seleccion_login,name='loginSeleccion'),
    path('Autentication',views.identidad_user,name="autenticationUser"),
    path('registro',views.registro,name='registro'),
    path('login',views.login,name='loginSistema'),
    path('loginUser',views.login_user,name='loginUser'),
    path('cerrar sesion',views.cerrarSesion_cantv,name="cerrar_cantv"),
    path('cerrar sesion user',views.cerrarSesion_user,name="cerrar_user"),
    #====MODULOS DE LA PAGINA====
    #++++MODULO ADMIN+++++
    path('admin',views.modulo_admin,name='admin'),
    path('registrarODN',views.registroODN,name="regisODN"),
    path('registarFAT',views.registroFAT,name="regisFAT"),
    path('permisos',views.permisos_admin,name="permisosAdmin"),
    path('registraclient',views.registroCliente,name="registrarCliente"),
    path('registroSudAdmin',views.crearSubAdmin,name="registrosudAdmin"),
    path('obtenerDatosCliente',views.obtener_datas_clientes,name="datos_cli_report"),
    path('eliminacionServi/p00-<int:id>',views.eliminacion_total_cliente,name="elimServicio"),
    path('crearTecnico',views.crearTecnico,name='crearTecnico'),
    path('crearSubAdmin',views.crearSubAdmin,name='crearSubAdmin'),
    path('eliminarTecnico/p00-<int:id>',views.eliminar_tecnico,name='eliminarTecnico'),
    path('eliminarSubAdmin/p00-<int:id>',views.eliminar_subAdmin,name='eliminarSubAdmin'),
    path('editarTecnico/p00-<int:id>',views.editarTecnico,name='editarTecnico'),
    path('editarSubAdmin/p00-<int:id>',views.editarSubAdmin,name='editarSubAdmin'),
    path('enviarReporteTecnico/p00-<int:id>',views.enviar_reporte_tecnico,name='enviarReporte'),
    path('verReportesTecnico/p00-<int:id>',views.ver_reportes_tecnico,name='verReportes'),
    path("reportesGestionados",views.ver_reportes_gestion,name='reportesGestionados'),
    path("hinabilitados",views.hinabilitados,name="hinabilitados"),
    path('historial_tecnico',views.historial_tecnico_pdf,name="historial_tecnico"),
    path('crearCliente', views.registroCliente, name="registroCliente"),
    path('obtener_datos_fat/', views.obtener_datos_fat, name='obtener_datos_fat'),
    path('obtener_fats/', views.obtener_fats, name='obtener_fats'),
    path('mostrarFtasOdn/',views.mostrar_fats,name="mostrarFAT"),
    path("eliminarCliente/p00-<int:id>",views.eliminar_cliente,name="eliminarCliente"),
    path("editarCliente/<int:id>",views.editarCliente,name="editarCliente"),
    path("eliminarPermisos",views.eliminar_permisos_admin,name="eliminar_permi_user"),
    #++++MODULO SUB ADMIN+++++
    path('subAdmin',views.modulo_subAdmin,name='subAdmin'),
    path("algoRaro/p00-<int:id>",views.algo_anda_mal,name="algoRaroPasa"),
    path('eliminarClienteSub/p00-<int:id>',views.eliminar_cliente_sub,name='eliminar_cli'),
    path('crearTecnicoSub',views.crearEmpleado_modulo_subAdmin,name='crearTecnicoSubAdmin'),
    path("reportesGestionadosSub",views.ver_reportes_gestion_sub,name='reportesGestionados_sub'),
    path('enviarReporteTecnico_sub/p00-<int:id>',views.enviar_reporte_tecnico_sub,name='enviarReporte_sub'),
    path('verReportesTecnico_sub/p00-<int:id>',views.ver_reportes_tecnico_sub,name='verReportes_sub'),
    path('eliminarTecnico_sub/p00-<int:id>',views.eliminar_tecnico_sub,name='eliminarTecnico_sub'),
    path('editarTecnico_sub/p00-<int:id>',views.editarTecnico_sub,name='editarTecnico_sub'),
    #++++MODULO TECNICO++++
    path('tecnico',views.modulo_tecnico,name='tecnico'),
    path('reportesAsignados',views.reportes_asignados,name='reportesAsignados'),
    path('informeGestion',views.formulario_gestion,name='informeGestion'),
    #++++++++MODULO CLIENTE++++
    path('cliente',views.modulo_cliente,name='cliente'),
    path('reporte',views.cliente_reporte,name="generarReporte"),
    path('historialReporteCliente',views.historial_reporte,name="historialReporteCliente"),
    path('historialClientePdf',views.historial_reporte_pdf,name="historialClientePdf"),
    path('eliminar_reporte/p00-<int:id>',views.eliminar_reporte,name="eliminar_reporte"),
    path('eliminar_todos/<str:cedula>',views.eliminar_todos_reportes,name="eliminar_todos_reportes"),
    path("generarSolicitudes",views.generar_solicitudes,name="solicitudes"),
]