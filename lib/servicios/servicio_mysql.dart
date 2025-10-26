import 'package:mysql1/mysql1.dart';
import '../modelos/concurso.dart';

class ServicioMySQL {
  static const String host = '161.132.55.248';
  static const int port = 3306;
  static const String usuario = 'admin';
  static const String contrasena = 'Upt2025';
  static const String baseDatos = 'epis_proyectos';

  static MySqlConnection? _conexion;

  // Método para obtener una conexión a la base de datos
  static Future<MySqlConnection> _obtenerConexion() async {
    if (_conexion == null) {
      final settings = ConnectionSettings(
        host: host,
        port: port,
        user: usuario,
        password: contrasena,
        db: baseDatos,
      );
      
      _conexion = await MySqlConnection.connect(settings);
    }
    return _conexion!;
  }

  // Método para cerrar la conexión
  static Future<void> cerrarConexion() async {
    if (_conexion != null) {
      await _conexion!.close();
      _conexion = null;
    }
  }

  // Método principal para obtener concursos activos
  static Future<List<Concurso>> obtenerConcursosActivos() async {
    final conn = await _obtenerConexion();
    
    try {
      // Consulta para obtener concursos activos (donde la fecha actual está entre fecha_creacion y fecha_limite_inscripcion)
      final resultados = await conn.query(
        '''
        SELECT c.id, c.nombre, c.fecha_creacion, c.fecha_limite_inscripcion,
               cat.id as categoria_id, cat.nombre as categoria_nombre, cat.rango_ciclos
        FROM concursos c
        LEFT JOIN categorias cat ON c.id = cat.concurso_id
        WHERE NOW() BETWEEN c.fecha_creacion AND c.fecha_limite_inscripcion
        ORDER BY c.fecha_creacion DESC
        '''
      );

      // Procesar resultados y agrupar por concurso
      final Map<int, Concurso> concursosMap = {};
      
      for (final row in resultados) {
        final concursoId = row[0] as int;
        
        if (!concursosMap.containsKey(concursoId)) {
          // Crear nuevo concurso
          concursosMap[concursoId] = Concurso(
            id: concursoId.toString(),
            nombre: row[1] as String,
            fechaCreacion: (row[2] as DateTime).toLocal(),
            fechaLimiteInscripcion: (row[3] as DateTime).toLocal(),
            categorias: [],
          );
        }
        
        // Agregar categoría si existe
        if (row[4] != null) {
          final categoria = Categoria(
            nombre: row[5] as String,
            rangoCiclos: row[6] as String? ?? '',
          );
          concursosMap[concursoId]!.categorias.add(categoria);
        }
      }
      
      return concursosMap.values.toList();
      
    } catch (e) {
      print('Error al obtener concursos activos: $e');
      rethrow;
    }
  }

  // Método para obtener un concurso específico por ID
  static Future<Concurso?> obtenerConcursoPorId(int id) async {
    final conn = await _obtenerConexion();
    
    try {
      final resultados = await conn.query(
        '''
        SELECT c.id, c.nombre, c.fecha_creacion, c.fecha_limite_inscripcion,
               cat.id as categoria_id, cat.nombre as categoria_nombre, cat.rango_ciclos
        FROM concursos c
        LEFT JOIN categorias cat ON c.id = cat.concurso_id
        WHERE c.id = ?
        ORDER BY cat.nombre
        ''',
        [id]
      );

      if (resultados.isEmpty) {
        return null;
      }

      Concurso? concurso;
      final categorias = <Categoria>[];
      
      for (final row in resultados) {
        if (concurso == null) {
          concurso = Concurso(
            id: row[0].toString(),
            nombre: row[1] as String,
            fechaCreacion: (row[2] as DateTime).toLocal(),
            fechaLimiteInscripcion: (row[3] as DateTime).toLocal(),
            categorias: [],
          );
        }
        
        // Agregar categoría si existe
        if (row[4] != null) {
          categorias.add(Categoria(
            nombre: row[5] as String,
            rangoCiclos: row[6] as String? ?? '',
          ));
        }
      }
      
      concurso!.categorias.addAll(categorias);
      return concurso;
      
    } catch (e) {
      print('Error al obtener concurso por ID: $e');
      rethrow;
    }
  }

  // Método para verificar la conexión a la base de datos
  static Future<bool> verificarConexion() async {
    try {
      final conn = await _obtenerConexion();
      await conn.query('SELECT 1');
      return true;
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }
}