import 'package:flutter/material.dart';
import '../modelos/concurso.dart';
import '../servicios/servicio_autenticacion.dart';
import '../servicios/servicio_concursos.dart';
import '../utilidades/estilos.dart';
import '../widgets/widgets_personalizados.dart';
import 'pantalla_detalle_concurso.dart';
import 'pantalla_historial_participacion.dart';
import 'pantalla_inicio_sesion.dart';
import 'pantalla_perfil.dart'; // <-- IMPORTAR PANTALLA DE PERFIL

class PantallaDashboard extends StatefulWidget {
  const PantallaDashboard({super.key});

  @override
  State<PantallaDashboard> createState() => _PantallaDashboardState();
}

class _PantallaDashboardState extends State<PantallaDashboard> {
  Concurso? _concursoActivo;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarConcursoActivo();
  }

  Future<void> _cerrarSesion() async {
    await ServicioAutenticacion.instancia.cerrarSesion();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const PantallaInicioSesion()),
        (Route<dynamic> route) => false,
      );
    }
  }

  // --- MÉTODO DE NAVEGACIÓN A PERFIL AÑADIDO ---
  void _navegarAPerfil() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PantallaPerfil()),
    );
  }

  Future<void> _cargarConcursoActivo() async {
    setState(() {
      _cargando = true;
    });

    try {
      final concurso = await ServicioConcursos.instancia.getConcursoActivo();
      if (mounted) {
        setState(() {
          _concursoActivo = concurso;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar el concurso activo'),
            backgroundColor: Colores.error,
          ),
        );
      }
    }
  }

  void _navegarADetalle(Concurso concurso) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PantallaDetalleConcurso(concurso: concurso),
      ),
    );
  }
  
  void _navegarAHistorial() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PantallaHistorialParticipacion(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colores.fondo,
      appBar: AppBar(
        title: const Text('Concurso de Proyectos'),
        backgroundColor: Colores.primario,
        foregroundColor: Colores.blanco,
        actions: [
          // --- ICONO DE PERFIL AÑADIDO ---
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: _navegarAPerfil,
            tooltip: 'Mi Perfil',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarConcursoActivo,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: Estilos.paddingGeneral,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido',
                style: Estilos.titulo,
              ),
              const SizedBox(height: 8),
              Text(
                'Consulta la información del concurso activo y tu historial.',
                style: Estilos.cuerpoSecundario,
              ),
              const SizedBox(height: 24),

              // --- Tarjeta de Historial ---
              _buildTarjetaHistorial(),

              const SizedBox(height: 24),
              
              Text(
                'Concurso Activo',
                style: Estilos.subtitulo,
              ),
              const SizedBox(height: 16),

              if (_cargando)
                const Center(child: CircularProgressIndicator())
              else if (_concursoActivo != null)
                _buildTarjetaConcurso(_concursoActivo!)
              else
                _buildMensajeVacio(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTarjetaHistorial() {
    return TarjetaPersonalizada(
      alPresionar: _navegarAHistorial,
      hijo: const Row(
        children: [
          Icon(Icons.history, color: Colores.primario, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Historial de Participación', style: Estilos.subtitulo),
                Text('Consulta tus proyectos de ediciones pasadas', style: Estilos.cuerpoSecundario),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colores.gris, size: 16),
        ],
      ),
    );
  }

  Widget _buildTarjetaConcurso(Concurso concurso) {
    return TarjetaPersonalizada(
      alPresionar: () => _navegarADetalle(concurso),
      hijo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            concurso.nombre,
            style: Estilos.subtitulo,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoFecha('Inicia', concurso.fechaCreacion),
              _buildInfoFecha('Finaliza', concurso.fechaLimiteInscripcion),
            ],
          ),
          const SizedBox(height: 16),
          BotonPersonalizado(
            texto: 'Ver Detalles',
            alPresionar: () => _navegarADetalle(concurso),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoFecha(String etiqueta, DateTime fecha) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta.toUpperCase(),
          style: Estilos.cuerpo.copyWith(
            color: Colores.gris,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${fecha.day}/${fecha.month}/${fecha.year}',
          style: Estilos.cuerpo.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildMensajeVacio() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colores.gris),
            SizedBox(height: 16),
            Text(
              'No hay concursos activos',
              style: Estilos.subtitulo,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Por favor, vuelve a intentarlo más tarde.',
              style: Estilos.cuerpoSecundario,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}