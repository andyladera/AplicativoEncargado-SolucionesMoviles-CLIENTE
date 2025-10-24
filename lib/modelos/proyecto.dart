enum EstadoProyecto { pendiente, calificado }

class Proyecto {
  final String id;
  final String nombre;
  final String estudianteId;
  final String concursoId;
  final String categoriaId;
  final String? enlaceGithub;
  final String? archivoZip;
  final EstadoProyecto estado;
  final DateTime fechaEnvio;
  
  // Campos para historial y resultados
  final String? concursoNombre;
  final double? calificacion;
  final String? descripcion;
  final String? archivoAval;
  final String? retroalimentacion; // <-- CAMPO AÑADIDO

  Proyecto({
    required this.id,
    required this.nombre,
    required this.estudianteId,
    required this.concursoId,
    required this.categoriaId,
    required this.estado,
    required this.fechaEnvio,
    this.enlaceGithub,
    this.archivoZip,
    this.concursoNombre,
    this.calificacion,
    this.descripcion,
    this.archivoAval,
    this.retroalimentacion, // <-- CAMPO AÑADIDO
  });

  factory Proyecto.desdeJson(Map<String, dynamic> json) {
    return Proyecto(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      estudianteId: json['estudiante_id'] ?? '',
      concursoId: json['concurso_id'] ?? '',
      categoriaId: json['categoria_id'] ?? '',
      enlaceGithub: json['enlace_github'],
      archivoZip: json['archivo_zip'],
      estado: EstadoProyecto.values.firstWhere(
        (e) => e.toString() == 'EstadoProyecto.${json['estado']}',
        orElse: () => EstadoProyecto.pendiente,
      ),
      fechaEnvio: DateTime.parse(json['fecha_envio'] ?? DateTime.now().toIso8601String()),
      concursoNombre: json['concurso_nombre'],
      calificacion: (json['calificacion'] as num?)?.toDouble(),
      descripcion: json['descripcion'],
      archivoAval: json['archivo_aval'],
      retroalimentacion: json['retroalimentacion'], // <-- CAMPO AÑADIDO
    );
  }
}