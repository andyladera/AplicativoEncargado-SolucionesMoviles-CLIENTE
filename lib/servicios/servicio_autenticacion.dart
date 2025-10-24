import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/estudiante.dart';

class ServicioAutenticacion {
  static const String urlBase = 'https://api-ejemplo.com'; // Cambiar por la URL real
  
  static ServicioAutenticacion? _instancia;
  static ServicioAutenticacion get instancia {
    _instancia ??= ServicioAutenticacion._();
    return _instancia!;
  }
  
  ServicioAutenticacion._();

  Estudiante? _estudianteActual;
  Estudiante? get estudianteActual => _estudianteActual;

  bool get estaAutenticado => _estudianteActual != null;

  Future<bool> registrarEstudiante({
    required String nombres,
    required String apellidos,
    required String codigoUniversitario,
    required String correo,
    required String numeroTelefonico,
    required int ciclo,
    required String contrasena,
  }) async {
    try {
      // Simulacion del registro - reemplazar con llamada real a la API
      // final datosRegistro = {
      //   'nombres': nombres,
      //   'apellidos': apellidos,
      //   'codigo_universitario': codigoUniversitario,
      //   'correo': correo,
      //   'numero_telefonico': numeroTelefonico,
      //   'ciclo': ciclo,
      //   'contrasena': contrasena,
      // };

      // Por ahora simularemos que el registro es exitoso
      await Future.delayed(const Duration(seconds: 2));
      
      // En una implementacion real, aqui harias:
      // final respuesta = await http.post(
      //   Uri.parse('$urlBase/auth/registro'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode(datosRegistro),
      // );
      // return respuesta.statusCode == 200;
      
      return true;
    } catch (e) {
      print('Error al registrar estudiante: $e');
      return false;
    }
  }

  Future<bool> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      // Simulacion del inicio de sesion - reemplazar con llamada real a la API
      await Future.delayed(const Duration(seconds: 2));
      
      // Credenciales de prueba predefinidas
      if (correo.toLowerCase() == 'cliente@gmail.com' && contrasena == 'cliente') {
        _estudianteActual = Estudiante(
          id: '1',
          nombres: 'Estudiante',
          apellidos: 'Cliente Prueba',
          codigoUniversitario: '2024000001',
          correo: 'cliente@gmail.com',
          numeroTelefonico: '987654321',
          ciclo: 8,
        );
        await _guardarSesion();
        return true;
      }
      
      // Credencial alternativa para testing
      if (correo.toLowerCase() == 'test@epis.edu.pe' && contrasena == 'test123') {
        _estudianteActual = Estudiante(
          id: '2',
          nombres: 'Maria Elena',
          apellidos: 'Gonzalez Ramirez',
          codigoUniversitario: '2024000002',
          correo: 'test@epis.edu.pe',
          numeroTelefonico: '976543210',
          ciclo: 6,
        );
        await _guardarSesion();
        return true;
      }
      
      // Para cualquier otro correo/contraseña, también permitir acceso (para pruebas)
      if (correo.isNotEmpty && contrasena.isNotEmpty) {
        _estudianteActual = Estudiante(
          id: '999',
          nombres: 'Usuario',
          apellidos: 'General',
          codigoUniversitario: '2024999999',
          correo: correo,
          numeroTelefonico: '999999999',
          ciclo: 5,
        );
        await _guardarSesion();
        return true;
      }
      
      // En una implementacion real, aqui harias:
      // final respuesta = await http.post(
      //   Uri.parse('$urlBase/auth/login'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode({
      //     'correo': correo,
      //     'contrasena': contrasena,
      //   }),
      // );
      
      // if (respuesta.statusCode == 200) {
      //   final datos = json.decode(respuesta.body);
      //   _estudianteActual = Estudiante.desdeJson(datos['estudiante']);
      //   await _guardarSesion();
      //   return true;
      // }
      
      return false;
    } catch (e) {
      print('Error al iniciar sesion: $e');
      return false;
    }
  }

  Future<void> cerrarSesion() async {
    _estudianteActual = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sesion_estudiante');
  }

  Future<void> verificarSesionGuardada() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final datosEstudiante = prefs.getString('sesion_estudiante');
      
      if (datosEstudiante != null) {
        final json = jsonDecode(datosEstudiante);
        _estudianteActual = Estudiante.desdeJson(json);
      }
    } catch (e) {
      print('Error al verificar sesion guardada: $e');
    }
  }

  Future<void> _guardarSesion() async {
    if (_estudianteActual != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sesion_estudiante', jsonEncode(_estudianteActual!.aJson()));
    }
  }

  // --- MÉTODO AÑADIDO ---
  Future<Estudiante?> obtenerEstudianteActual() async {
    // En una app real, obtendrías esto de SharedPreferences, una base de datos local o un token.
    await Future.delayed(const Duration(milliseconds: 500));
    return Estudiante(
      id: 'estudiante123',
      nombres: 'Juan',
      apellidos: 'Pérez García',
      codigoUniversitario: '202012345',
      correo: 'juan.perez@universidad.edu.pe',
      numeroTelefonico: '+51 987 654 321',
      ciclo: 7,
    );
  }
}