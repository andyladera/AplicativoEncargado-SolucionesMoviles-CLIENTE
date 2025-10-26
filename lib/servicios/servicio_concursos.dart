import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import '../modelos/concurso.dart';
import '../modelos/proyecto.dart';
import 'servicio_mysql.dart';

class ServicioConcursos {
  static const String urlBase = 'https://api-ejemplo.com'; // Cambiar por la URL real
  
  static ServicioConcursos? _instancia;
  static ServicioConcursos get instancia {
    _instancia ??= ServicioConcursos._();
    return _instancia!;
  }
  
  ServicioConcursos._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Concurso>> obtenerConcursosDisponibles() async {
    try {
      // Usar MySQL en lugar de Firebase
      return await ServicioMySQL.obtenerConcursosActivos();
    } catch (e) {
      print('Error al obtener concursos desde MySQL: $e');
      // Fallback a Firebase si MySQL falla
      try {
        final snapshot = await _firestore.collection('concursos').get();
        final concursos = snapshot.docs.map((doc) {
          return Concurso.desdeDocumento(doc.id, doc.data());
        }).toList();
        return concursos;
      } catch (firebaseError) {
        print('Error al obtener concursos desde Firebase: $firebaseError');
        return [];
      }
    }
  }

  Future<Concurso?> obtenerConcursoPorId(String id) async {
    try {
      // Usar MySQL en lugar de Firebase
      return await ServicioMySQL.obtenerConcursoPorId(int.parse(id));
    } catch (e) {
      print('Error al obtener concurso por ID desde MySQL: $e');
      // Fallback a Firebase si MySQL falla
      try {
        final concursos = await obtenerConcursosDisponibles();
        return concursos.firstWhere((concurso) => concurso.id == id);
      } catch (firebaseError) {
        print('Error al obtener concurso por ID desde Firebase: $firebaseError');
        return null;
      }
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
      await _firestore.collection('proyectos').add({
        'nombre': nombreProyecto,
        'estudianteId': estudianteId,
        'concursoId': concursoId,
        'categoriaId': categoriaId,
        'enlaceGithub': enlaceGithub,
        'archivoZip': archivoZip,
        'archivoAval': archivoAval,
        'fechaEnvio': FieldValue.serverTimestamp(),
        'estado': 'pendiente',
      });
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