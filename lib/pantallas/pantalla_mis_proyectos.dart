import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../modelos/proyecto.dart';
import '../servicios/servicio_concursos.dart';
import '../utilidades/estilos.dart';
import '../widgets/widgets_personalizados.dart';

class PantallaMisProyectos extends StatefulWidget {
  final String concursoId;

  const PantallaMisProyectos({
    super.key,
    required this.concursoId,
  });

  @override
  State<PantallaMisProyectos> createState() => _PantallaMisProyectosState();
}

class _PantallaMisProyectosState extends State<PantallaMisProyectos> {
  late Future<List<Proyecto>> _futureProyectos;

  @override
  void initState() {
    super.initState();
    _cargarProyectos();
  }

  void _cargarProyectos() {
    const estudianteId = 'estudiante123';
    _futureProyectos = ServicioConcursos.instancia.obtenerProyectosEstudiante(estudianteId);
  }

  Future<void> _lanzarUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay un enlace válido.'), backgroundColor: Colores.advertencia),
      );
      return;
    }
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el enlace: $urlString'), backgroundColor: Colores.error),
      );
    }
  }

  // --- WIDGET PARA EL INDICADOR DE ESTADO (VERSIÓN FINAL) ---
  Widget _buildEstadoChip(EstadoProyecto estado) {
    String texto;
    Color colorFondo;
    Color colorTexto;

    // Usando los valores correctos del enum EstadoProyecto
    switch (estado) {
      case EstadoProyecto.pendiente:
        texto = 'Pendiente';
        colorFondo = Colors.orange.shade100;
        colorTexto = Colors.orange.shade800;
        break;
      case EstadoProyecto.calificado:
        texto = 'Calificado';
        colorFondo = Colors.green.shade100;
        colorTexto = Colors.green.shade800;
        break;
      // El enum solo tiene 'pendiente' y 'calificado' por ahora.
      // El default manejará cualquier otro caso futuro.
      default:
        texto = 'Enviado'; // Un estado genérico si no es pendiente ni calificado
        colorFondo = Colors.blue.shade100;
        colorTexto = Colors.blue.shade800;
    }

    return Chip(
      label: Text(
        texto,
        style: TextStyle(color: colorTexto, fontWeight: FontWeight.bold, fontSize: 12),
      ),
      backgroundColor: colorFondo,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Proyectos Enviados'),
        backgroundColor: Colores.primario,
        foregroundColor: Colores.blanco,
      ),
      body: FutureBuilder<List<Proyecto>>(
        future: _futureProyectos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar proyectos: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_off_outlined, size: 80, color: Colores.gris),
                  SizedBox(height: 16),
                  Text('Aún no has enviado proyectos', style: Estilos.subtitulo),
                  Text('para este concurso.', style: Estilos.cuerpoSecundario, textAlign: TextAlign.center),
                ],
              ),
            );
          }

          final proyectos = snapshot.data!;
          return ListView.builder(
            padding: Estilos.paddingGeneral,
            itemCount: proyectos.length,
            itemBuilder: (context, index) {
              final proyecto = proyectos[index];
              return TarjetaPersonalizada(
                hijo: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            proyecto.nombre,
                            style: Estilos.subtitulo,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildEstadoChip(proyecto.estado),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      'Enviado el: ${proyecto.fechaEnvio.day}/${proyecto.fechaEnvio.month}/${proyecto.fechaEnvio.year}',
                      style: Estilos.cuerpoSecundario,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: BotonPersonalizado(
                            texto: 'Ver en GitHub',
                            alPresionar: () => _lanzarUrl(proyecto.enlaceGithub),
                            esSecundario: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: BotonPersonalizado(
                            texto: 'Descargar ZIP',
                            alPresionar: () => _lanzarUrl(proyecto.archivoZip),
                          ),
                        ),
                      ],
                    ),
                    if (proyecto.estado == EstadoProyecto.calificado && proyecto.calificacion != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Center(
                          child: Text(
                            'Calificación Final: ${proyecto.calificacion!.toStringAsFixed(1)}',
                            style: Estilos.titulo.copyWith(color: Colores.primario),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}