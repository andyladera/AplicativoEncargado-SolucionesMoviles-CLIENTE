import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../servicios/servicio_autenticacion.dart';
import '../utilidades/estilos.dart';
import '../utilidades/validadores.dart';
import '../widgets/widgets_personalizados.dart';
import 'pantalla_registro.dart';
import 'pantalla_dashboard.dart';

class PantallaInicioSesion extends StatefulWidget {
  const PantallaInicioSesion({super.key});

  @override
  State<PantallaInicioSesion> createState() => _PantallaInicioSesionState();
}

class _PantallaInicioSesionState extends State<PantallaInicioSesion> {
  final _formKey = GlobalKey<FormState>();
  final _controladorCorreo = TextEditingController();
  final _controladorContrasena = TextEditingController();
  bool _cargando = false;
  bool _mostrarContrasena = false;

  @override
  void dispose() {
    _controladorCorreo.dispose();
    _controladorContrasena.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _cargando = true; });

    try {
      final userCredential = await ServicioAutenticacion.instancia.iniciarSesion(
        correo: _controladorCorreo.text.trim(),
        contrasena: _controladorContrasena.text,
      );

      if (mounted && userCredential != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const PantallaDashboard()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String mensaje = 'Ocurrió un error inesperado.';
        if (e.code == 'user-not-found') {
          mensaje = 'No se encontró un usuario con ese correo.';
        } else if (e.code == 'wrong-password') {
          mensaje = 'La contraseña es incorrecta.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje), backgroundColor: Colores.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colores.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _cargando = false; });
      }
    }
  }

  void _irARegistro() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PantallaRegistro()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colores.fondo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: Estilos.paddingGrande,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colores.primario,
                      borderRadius: Estilos.bordeRedondeadoGrande,
                    ),
                    child: const Icon(Icons.school, size: 60, color: Colores.blanco),
                  ),
                  const SizedBox(height: 32),
                  const Text('Concurso de Proyectos EPIS', style: Estilos.titulo, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  const Text('Inicia sesión para continuar', style: Estilos.cuerpoSecundario, textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  CampoTextoPersonalizado(
                    etiqueta: 'Correo electrónico',
                    sugerencia: 'ejemplo@ejemplo.com',
                    controlador: _controladorCorreo,
                    validador: Validadores.validarCorreo,
                    tipoTeclado: TextInputType.emailAddress,
                    iconoPrefijo: const Icon(Icons.email_outlined),
                  ),
                  const SizedBox(height: 16),
                  CampoTextoPersonalizado(
                    etiqueta: 'Contraseña',
                    sugerencia: 'Ingresa tu contraseña',
                    controlador: _controladorContrasena,
                    validador: Validadores.validarContrasena,
                    obscureText: !_mostrarContrasena,
                    iconoPrefijo: const Icon(Icons.lock_outline),
                    iconoSufijo: IconButton(
                      icon: Icon(_mostrarContrasena ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _mostrarContrasena = !_mostrarContrasena),
                    ),
                  ),
                  const SizedBox(height: 24),
                  BotonPersonalizado(
                    texto: 'Iniciar Sesión',
                    alPresionar: _iniciarSesion,
                    cargando: _cargando,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿No tienes una cuenta?', style: Estilos.cuerpoSecundario),
                      TextButton(
                        onPressed: _irARegistro,
                        child: const Text('Regístrate', style: TextStyle(color: Colores.primario, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}