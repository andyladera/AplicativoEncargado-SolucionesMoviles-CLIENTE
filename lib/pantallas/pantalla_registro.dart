import 'package:flutter/material.dart';
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
  // --- CAMPOS DEL LÍDER ---
  final _controladorNombres = TextEditingController();
  final _controladorApellidos = TextEditingController();
  final _controladorCodigo = TextEditingController();
  final _controladorCorreo = TextEditingController();
  final _controladorTelefono = TextEditingController();
  final _controladorCiclo = TextEditingController();
  final _controladorContrasena = TextEditingController();
  final _controladorConfirmarContrasena = TextEditingController();
  
  // --- NUEVO: LISTA DE INTEGRANTES ---
  final List<TextEditingController> _integrantesControllers = [];

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
    // Limpiar controllers de integrantes
    for (var controller in _integrantesControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // --- NUEVOS MÉTODOS PARA GESTIONAR INTEGRANTES ---
  void _agregarIntegrante() {
    // No se pueden añadir más de 4 integrantes (total 5 con el líder)
    if (_integrantesControllers.length < 4) {
      setState(() {
        _integrantesControllers.add(TextEditingController());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Un equipo puede tener un máximo de 5 integrantes.'),
          backgroundColor: Colores.advertencia,
        ),
      );
    }
  }

  void _quitarIntegrante(int index) {
    setState(() {
      _integrantesControllers[index].dispose();
      _integrantesControllers.removeAt(index);
    });
  }

  String? _validarConfirmarContrasena(String? valor) {
    if (valor != _controladorContrasena.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  Future<void> _registrarse() async {
    if (!_formKey.currentState!.validate()) return;

    // --- VALIDACIÓN DEL NÚMERO DE INTEGRANTES ---
    final totalIntegrantes = 1 + _integrantesControllers.length;
    if (totalIntegrantes < 2 || totalIntegrantes > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El equipo debe tener entre 2 y 5 integrantes. Actualmente tienes $totalIntegrantes.'),
          backgroundColor: Colores.error,
        ),
      );
      return;
    }

    setState(() { _cargando = true; });

    // Preparar la lista de códigos de los otros integrantes
    final codigosIntegrantes = _integrantesControllers.map((c) => c.text.trim()).toList();

    try {
      // NOTA: El servicio de autenticación debería ser modificado para aceptar un equipo.
      // Por ahora, solo se registra al líder y se simula el envío de los demás.
      print('Registrando equipo con los siguientes integrantes (códigos):');
      print('Líder: ${_controladorCodigo.text.trim()}');
      print('Otros: $codigosIntegrantes');

      final exito = await ServicioAutenticacion.instancia.registrarEstudiante(
        nombres: _controladorNombres.text.trim(),
        apellidos: _controladorApellidos.text.trim(),
        codigoUniversitario: _controladorCodigo.text.trim(),
        correo: _controladorCorreo.text.trim(),
        numeroTelefonico: _controladorTelefono.text.trim(),
        ciclo: int.parse(_controladorCiclo.text.trim()),
        contrasena: _controladorContrasena.text,
        // En una implementación real, pasarías la lista de integrantes aquí:
        // codigosIntegrantes: codigosIntegrantes,
      );

      if (mounted) {
        if (exito) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Equipo registrado con éxito.'), backgroundColor: Colores.exito),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al registrar el equipo.'), backgroundColor: Colores.error),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de conexión.'), backgroundColor: Colores.error),
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
        title: const Text('Registro de Equipo'),
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
                const Text('Registra tu Equipo', style: Estilos.titulo, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text('Completa los datos del líder y añade a tus compañeros.', style: Estilos.cuerpoSecundario, textAlign: TextAlign.center),
                const SizedBox(height: 24),

                // --- DATOS DEL LÍDER ---
                Text('Datos del Líder del Equipo', style: Estilos.subtitulo.copyWith(color: Colores.primario)),
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

                // --- SECCIÓN DE INTEGRANTES ---
                Text('Integrantes del Equipo', style: Estilos.subtitulo.copyWith(color: Colores.primario)),
                const Text('Añade los códigos universitarios de tus compañeros (mínimo 1, máximo 4).', style: Estilos.cuerpoSecundario),
                const Divider(height: 24),
                
                if (_integrantesControllers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('Aún no has añadido integrantes.', textAlign: TextAlign.center, style: Estilos.cuerpoSecundario),
                  ),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _integrantesControllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: CampoTextoPersonalizado(
                        controlador: _integrantesControllers[index],
                        etiqueta: 'Código del Integrante ${index + 1}',
                        validador: Validadores.validarCodigoUniversitario,
                        tipoTeclado: TextInputType.number,
                        iconoSufijo: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colores.error),
                          onPressed: () => _quitarIntegrante(index),
                        ),
                      ),
                    );
                  },
                ),
                
                BotonPersonalizado(
                  texto: 'Añadir Integrante',
                  alPresionar: _agregarIntegrante,
                  esSecundario: true, // Asumiendo que tienes un estilo de botón secundario
                ),
                const SizedBox(height: 32),

                // --- BOTÓN DE REGISTRO ---
                BotonPersonalizado(
                  texto: 'Registrar Equipo',
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