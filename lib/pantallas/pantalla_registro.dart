import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyectos_cliente/modelos/estudiante.dart';
import '../servicios/servicio_autenticacion.dart';
import '../utilidades/estilos.dart';
import '../utilidades/validadores.dart';
import '../widgets/widgets_personalizados.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _controladorNombres = TextEditingController();
  final _controladorApellidos = TextEditingController();
  final _controladorCodigo = TextEditingController();
  final _controladorCorreo = TextEditingController();
  final _controladorTelefono = TextEditingController();
  final _controladorCiclo = TextEditingController();
  final _controladorContrasena = TextEditingController();
  final _controladorConfirmarContrasena = TextEditingController();

  bool _cargando = false;
  bool _mostrarContrasena = false;
  bool _mostrarConfirmarContrasena = false;

  @override
  void dispose() {
    _controladorNombres.dispose();
    _controladorApellidos.dispose();
    _controladorCodigo.dispose();
    _controladorCorreo.dispose();
    _controladorTelefono.dispose();
    _controladorCiclo.dispose();
    _controladorContrasena.dispose();
    _controladorConfirmarContrasena.dispose();
    super.dispose();
  }

  String? _validarConfirmarContrasena(String? valor) {
    if (valor != _controladorContrasena.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  Future<void> _registrarse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _cargando = true; });

    try {
      final nuevoEstudiante = Estudiante(
        id: '', // El ID será asignado por Firestore
        nombres: _controladorNombres.text.trim(),
        apellidos: _controladorApellidos.text.trim(),
        codigoUniversitario: _controladorCodigo.text.trim(),
        correo: _controladorCorreo.text.trim(),
        numeroTelefonico: _controladorTelefono.text.trim(),
        ciclo: int.parse(_controladorCiclo.text.trim()),
      );

      await ServicioAutenticacion.instancia.registrarEstudiante(
        estudiante: nuevoEstudiante,
        contrasena: _controladorContrasena.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estudiante registrado con éxito.'), backgroundColor: Colores.exito),
        );
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String mensaje = 'Ocurrió un error durante el registro.';
        if (e.code == 'email-already-in-use') {
          mensaje = 'El correo electrónico ya está en uso.';
        } else if (e.code == 'weak-password') {
          mensaje = 'La contraseña es demasiado débil.';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Estudiante'),
        backgroundColor: Colores.primario,
        foregroundColor: Colores.blanco,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Estilos.paddingGeneral,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Text('Crea tu Cuenta', style: Estilos.titulo, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text('Completa tus datos para registrarte.', style: Estilos.cuerpoSecundario, textAlign: TextAlign.center),
                const SizedBox(height: 24),

                Text('Información Personal', style: Estilos.subtitulo.copyWith(color: Colores.primario)),
                const Divider(height: 24),
                CampoTextoPersonalizado(etiqueta: 'Nombres', controlador: _controladorNombres, validador: Validadores.validarNombre),
                const SizedBox(height: 16),
                CampoTextoPersonalizado(etiqueta: 'Apellidos', controlador: _controladorApellidos, validador: Validadores.validarNombre),
                const SizedBox(height: 16),
                CampoTextoPersonalizado(etiqueta: 'Código Universitario', controlador: _controladorCodigo, validador: Validadores.validarCodigoUniversitario, tipoTeclado: TextInputType.number),
                const SizedBox(height: 16),
                CampoTextoPersonalizado(etiqueta: 'Correo Electrónico', controlador: _controladorCorreo, validador: Validadores.validarCorreo, tipoTeclado: TextInputType.emailAddress),
                const SizedBox(height: 16),
                CampoTextoPersonalizado(etiqueta: 'Número Telefónico', controlador: _controladorTelefono, validador: Validadores.validarTelefono, tipoTeclado: TextInputType.phone),
                const SizedBox(height: 16),
                CampoTextoPersonalizado(etiqueta: 'Ciclo', controlador: _controladorCiclo, validador: Validadores.validarCiclo, tipoTeclado: TextInputType.number),
                const SizedBox(height: 16),
                CampoTextoPersonalizado(etiqueta: 'Contraseña', controlador: _controladorContrasena, validador: Validadores.validarContrasena, obscureText: !_mostrarContrasena, iconoSufijo: IconButton(icon: Icon(_mostrarContrasena ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _mostrarContrasena = !_mostrarContrasena))),
                const SizedBox(height: 16),
                CampoTextoPersonalizado(etiqueta: 'Confirmar Contraseña', controlador: _controladorConfirmarContrasena, validador: _validarConfirmarContrasena, obscureText: !_mostrarConfirmarContrasena, iconoSufijo: IconButton(icon: Icon(_mostrarConfirmarContrasena ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _mostrarConfirmarContrasena = !_mostrarConfirmarContrasena))),
                const SizedBox(height: 32),

                BotonPersonalizado(
                  texto: 'Registrarse',
                  alPresionar: _registrarse,
                  cargando: _cargando,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}