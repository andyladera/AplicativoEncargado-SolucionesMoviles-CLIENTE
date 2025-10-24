import 'package:flutter/material.dart';
import '../modelos/proyecto.dart';
import '../servicios/servicio_concursos.dart';
import '../utilidades/estilos.dart';
import '../widgets/widgets_personalizados.dart';

class PantallaHistorialParticipacion extends StatefulWidget {
  const PantallaHistorialParticipacion({super.key});

  @override
  State<PantallaHistorialParticipacion> createState() => _PantallaHistorialParticipacionState();
}

class _PantallaHistorialParticipacionState extends State<PantallaHistorialParticipacion> {
  late Future<List<Proyecto>> _futureProyectos;

  @override
  void initState() {
    super.initState();
    // Usamos un ID de prueba para la simulación
    _futureProyectos = ServicioConcursos.instancia.getHistorialProyectos('estudiante123');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Participación'),
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
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tienes proyectos en tu historial.'));
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
                    Text(proyecto.concursoNombre ?? 'Concurso sin nombre', style: Estilos.cuerpoSecundario),
                    const SizedBox(height: 4),
                    Text(proyecto.nombre, style: Estilos.subtitulo),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Calificación Final:', style: Estilos.cuerpo),
                        Text(
                          proyecto.calificacion?.toStringAsFixed(1) ?? 'N/A',
                          style: Estilos.titulo.copyWith(color: Colores.primario),
                        ),
                      ],
                    ),
                    // --- SECCIÓN DE RETROALIMENTACIÓN AÑADIDA ---
                    if (proyecto.retroalimentacion != null && proyecto.retroalimentacion!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Comentarios del Jurado:',
                              style: Estilos.cuerpo.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                proyecto.retroalimentacion!,
                                style: Estilos.cuerpoSecundario.copyWith(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
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