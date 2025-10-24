import 'package:proyectos_cliente/modelos/concurso.dart';
import 'package:proyectos_cliente/modelos/proyecto.dart';

// Importa esta extensión para usar firstWhereOrNull de forma segura
import 'package:collection/collection.dart';

class ServicioConcursos {
  static const String urlBase = 'https://api-ejemplo.com'; // Cambiar por la URL real
  
  static ServicioConcursos? _instancia;
  static ServicioConcursos get instancia {
    _instancia ??= ServicioConcursos._();
    return _instancia!;
  }
  
  ServicioConcursos._();

  // Lista interna de concursos para simulación
  final List<Concurso> _concursos = [
    Concurso(
      id: '1',
      nombre: 'Concurso de Innovacion Tecnologica 2024',
      descripcion: 'Concurso para proyectos de innovacion en tecnologia',
      fechaInicio: DateTime(2023, 5, 20),
      fechaFin: DateTime(2024, 5, 20),
      activo: true,
      categorias: [
        Categoria(id: '1', nombre: 'Desarrollo Web', descripcion: 'Proyectos de desarrollo web y aplicaciones', concursoId: '1'),
        Categoria(id: '2', nombre: 'Aplicaciones Moviles', descripcion: 'Desarrollo de aplicaciones para dispositivos moviles', concursoId: '1'),
        Categoria(id: '3', nombre: 'Inteligencia Artificial', descripcion: 'Proyectos que implementen IA o Machine Learning', concursoId: '1'),
      ],
    ),
    Concurso(
      id: '2',
      nombre: 'Hackathon EPIS 2024',
      descripcion: 'Hackathon de 48 horas para estudiantes de EPIS',
      fechaInicio: DateTime.now().add(const Duration(days: 15)),
      fechaFin: DateTime.now().add(const Duration(days: 17)),
      activo: true,
      categorias: [
        Categoria(id: '4', nombre: 'Solucion Empresarial', descripcion: 'Soluciones tecnologicas para empresas', concursoId: '2'),
        Categoria(id: '5', nombre: 'Impacto Social', descripcion: 'Proyectos con impacto social positivo', concursoId: '2'),
      ],
    ),
     Concurso(
      id: '3',
      nombre: 'Concurso de Verano 2025',
      descripcion: 'Concurso de proyectos para el ciclo de verano.',
      fechaInicio: DateTime.now().subtract(const Duration(days: 10)),
      fechaFin: DateTime.now().add(const Duration(days: 20)),
      activo: true,
      categorias: [
        Categoria(id: '6', nombre: 'Videojuegos', descripcion: 'Desarrollo de videojuegos.', concursoId: '3'),
      ],
    ),
  ];

  Future<List<Concurso>> obtenerConcursosDisponibles() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return _concursos;
    } catch (e) {
      print('Error al obtener concursos: $e');
      return [];
    }
  }

  Future<Concurso?> obtenerConcursoPorId(String id) async {
    try {
      final concursos = await obtenerConcursosDisponibles();
      return concursos.firstWhere((concurso) => concurso.id == id);
    } catch (e) {
      print('Error al obtener concurso por ID: $e');
      return null;
    }
  }

  Future<Concurso?> getConcursoActivo() async {
    // Simulación de llamada a API
    await Future.delayed(const Duration(seconds: 1));

    final concursos = await obtenerConcursosDisponibles();

    // Usamos la extensión `firstWhereOrNull` del paquete `collection`.
    // Esto es más limpio que un try-catch para este caso.
    final concursoActivo = concursos.firstWhereOrNull(
      (c) => c.estaVigente && c.estaEnPeriodoDeInscripcion
    );
    
    return concursoActivo;
  }

  Future<List<Proyecto>> getHistorialProyectos(String usuarioId) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return [
        Proyecto(
          id: 'p1',
          nombre: 'Proyecto antiguo 1',
          concursoId: 'hist-1',
          concursoNombre: 'Concurso de Proyectos 2023-I',
          estado: EstadoProyecto.calificado,
          calificacion: 85.5,
          estudianteId: usuarioId,
          categoriaId: 'hist-cat-1',
          fechaEnvio: DateTime(2023, 5, 20),
          // --- CAMPO AÑADIDO ---
          retroalimentacion: '¡Excelente trabajo en el backend! El frontend podría mejorar en la responsividad. La documentación es clara y completa.',
        ),
        Proyecto(
          id: 'p2',
          nombre: 'Proyecto antiguo 2',
          concursoId: 'hist-2',
          concursoNombre: 'Concurso de Proyectos 2023-II',
          estado: EstadoProyecto.calificado,
          calificacion: 92.0,
          estudianteId: usuarioId,
          categoriaId: 'hist-cat-2',
          fechaEnvio: DateTime(2023, 11, 15),
           // --- CAMPO AÑADIDO ---
          retroalimentacion: 'Una idea muy innovadora y con gran potencial de impacto social. Faltó pulir la presentación final y el demo en vivo.',
        ),
      ];
    } catch (e) {
      print('Error al obtener el historial de proyectos: $e');
      return [];
    }
  }

  Future<bool> enviarProyecto({
    required String nombreProyecto,
    required String estudianteId,
    required String concursoId,
    required String categoriaId,
    required String enlaceGithub,
    required String archivoZip,
    required String archivoAval,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      print('Proyecto enviado (simulación):');
      print('  - Nombre: $nombreProyecto');
      print('  - Aval: $archivoAval');
      print('  - Zip: $archivoZip');

      return true;
    } catch (e) {
      print('Error al enviar proyecto: $e');
      return false;
    }
  }

  Future<List<Proyecto>> obtenerProyectosEstudiante(String estudianteId) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return [
        Proyecto(
          id: '1',
          nombre: 'Sistema de Gestion Academica',
          estudianteId: estudianteId,
          concursoId: '1',
          categoriaId: '1',
          enlaceGithub: 'https://github.com/usuario/proyecto1',
          archivoZip: 'proyecto1.zip',
          estado: EstadoProyecto.pendiente,
          fechaEnvio: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];
    } catch (e) {
      print('Error al obtener proyectos del estudiante: $e');
      return [];
    }
  }
}