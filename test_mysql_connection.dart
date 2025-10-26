import 'package:mysql1/mysql1.dart';

void main() async {
  print('🔌 Probando conexión a MySQL...');
  
  try {
    final settings = ConnectionSettings(
      host: '161.132.55.248',
      port: 3306,
      user: 'admin',
      password: 'Upt2025',
      db: 'epis_proyectos',
    );
    
    final connection = await MySqlConnection.connect(settings);
    print('✅ Conexión exitosa a MySQL!');
    
    // Probar consulta simple - verificar si hay datos
    final results = await connection.query('SELECT COUNT(*) as total FROM concursos');
    if (results.isNotEmpty) {
      final totalConcursos = results.first[0]; // COUNT(*) devuelve un solo valor en la posición 0
      print('📊 Total de concursos en la base de datos: $totalConcursos');
    } else {
      print('📊 No hay concursos en la base de datos');
    }
    
    // Probar consulta de concursos activos
    final activeResults = await connection.query('''
      SELECT COUNT(*) as activos 
      FROM concursos 
      WHERE NOW() BETWEEN fecha_creacion AND fecha_limite_inscripcion
    ''');
    if (activeResults.isNotEmpty) {
      final concursosActivos = activeResults.first[0]; // COUNT(*) devuelve un solo valor en la posición 0
      print('🎯 Concursos activos: $concursosActivos');
    } else {
      print('🎯 No hay concursos activos');
    }
    
    await connection.close();
    print('🔌 Conexión cerrada correctamente.');
    
  } catch (e) {
    print('❌ Error de conexión: $e');
  }
}