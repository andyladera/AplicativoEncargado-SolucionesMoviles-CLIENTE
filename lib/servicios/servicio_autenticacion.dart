import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modelos/estudiante.dart';

class ServicioAutenticacion {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static ServicioAutenticacion? _instancia;
  static ServicioAutenticacion get instancia {
    _instancia ??= ServicioAutenticacion._();
    return _instancia!;
  }

  ServicioAutenticacion._();

  Estudiante? _estudianteActual;
  Estudiante? get estudianteActual => _estudianteActual;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> registrarEstudiante({
    required Estudiante estudiante,
    required String contrasena,
  }) async {
    // La excepción de Firebase se propagará a la UI
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: estudiante.correo,
      password: contrasena,
    );

    // Usar copyWith para actualizar el ID del estudiante con el UID de Firebase
    Estudiante nuevoEstudiante = estudiante.copyWith(id: userCredential.user!.uid);

    await _firestore.collection('usuarios').doc(userCredential.user!.uid).set(nuevoEstudiante.aJson());
    _estudianteActual = nuevoEstudiante;
    
    return userCredential;
  }

  Future<UserCredential> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    // La excepción de Firebase se propagará a la UI
    UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: correo,
      password: contrasena,
    );

    // Carga los datos del usuario.
    final estudiante = await obtenerEstudianteActual();
    
    // Si no se encuentran datos en Firestore, es un estado inconsistente.
    // Cerramos la sesión de Firebase y lanzamos un error.
    if (estudiante == null) {
      await cerrarSesion(); // cerrarSesion también limpia _estudianteActual
      throw Exception('No se encontraron datos de usuario asociados a esta cuenta.');
    }
    
    return userCredential;
  }

  Future<void> cerrarSesion() async {
    _estudianteActual = null;
    await _firebaseAuth.signOut();
  }

  Future<Estudiante?> obtenerEstudianteActual() async {
    if (_estudianteActual != null) return _estudianteActual;

    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          _estudianteActual = Estudiante.desdeJson(data, id: doc.id);
          return _estudianteActual;
        }
      }
    } catch (e) {
      print('Error al obtener datos de usuario: $e');
    }
    
    return null;
  }
}