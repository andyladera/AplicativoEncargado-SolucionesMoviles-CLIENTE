import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../modelos/concurso.dart';
import '../servicios/servicio_autenticacion.dart';
import '../servicios/servicio_concursos.dart';
import '../utilidades/estilos.dart';
import '../widgets/widgets_personalizados.dart';

class PantallaEnviarProyecto extends StatefulWidget {
  final Concurso concurso;
  final Categoria? categoria;

  const PantallaEnviarProyecto({
    super.key,
    required this.concurso,
    this.categoria,
  });

  @override
  State<PantallaEnviarProyecto> createState() => _PantallaEnviarProyectoState();
}

class _PantallaEnviarProyectoState extends State<PantallaEnviarProyecto> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _githubController = TextEditingController();
  
  String? _categoriaSeleccionada;
  bool _cargando = false;

  XFile? _archivoAval;
  XFile? _archivoZip;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.categoria != null) {
      _categoriaSeleccionada = widget.categoria!.id;
    }
  }

  Future<void> _seleccionarAval() async {
    try {
      final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery);
      if (imagen != null) {
        setState(() {
          _archivoAval = imagen;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al seleccionar la imagen.'), backgroundColor: Colores.error),
      );
    }
  }

  void _seleccionarZip() {
    setState(() {
      _archivoZip = XFile('path/simulado/proyecto.zip');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Simulación: Archivo ZIP seleccionado.')),
    );
  }

  Future<void> _enviarFormulario() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    if (_categoriaSeleccionada == null || _archivoAval == null || _archivoZip == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos y sube los archivos requeridos.'), backgroundColor: Colores.advertencia),
      );
      return;
    }

    setState(() { _cargando = true; });

    final estudiante = ServicioAutenticacion.instancia.estudianteActual;
    if (estudiante == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de autenticación.'), backgroundColor: Colores.error),
      );
      setState(() { _cargando = false; });
      return;
    }

    final bool exito = await ServicioConcursos.instancia.enviarProyecto(
      nombreProyecto: _nombreController.text,
      estudianteId: estudiante.id,
      concursoId: widget.concurso.id,
      categoriaId: _categoriaSeleccionada!,
      enlaceGithub: _githubController.text,
      archivoZip: _archivoZip!.name,
      archivoAval: _archivoAval!.name,
    );

    if (mounted) {
      setState(() { _cargando = false; });
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Proyecto enviado con éxito!'), backgroundColor: Colores.exito),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar el proyecto.'), backgroundColor: Colores.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inscribir Proyecto'),
        backgroundColor: Colores.primario,
        foregroundColor: Colores.blanco,
      ),
      body: Form(
        key: _formKey,
        child: ListView( // Usamos ListView en lugar de SingleChildScrollView+Column para mayor seguridad
          padding: const EdgeInsets.all(16.0),
          children: [
            Text('Completa los datos de tu proyecto', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Título del Proyecto',
                border: OutlineInputBorder(),
              ),
              validator: (val) => (val?.isEmpty ?? true) ? 'El título es obligatorio' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _categoriaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: widget.concurso.categorias.map((cat) {
                return DropdownMenuItem(value: cat.id, child: Text(cat.nombre));
              }).toList(),
              onChanged: (val) => setState(() => _categoriaSeleccionada = val),
              validator: (val) => val == null ? 'Selecciona una categoría' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _githubController,
              decoration: const InputDecoration(
                labelText: 'Enlace a GitHub (Opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text('Documentación Requerida', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _buildSelectorArchivo(
              titulo: 'Aval del Docente (Imagen)',
              nombreArchivo: _archivoAval?.name,
              alPresionar: _seleccionarAval,
            ),
            const SizedBox(height: 12),
            _buildSelectorArchivo(
              titulo: 'Proyecto (.zip)',
              nombreArchivo: _archivoZip?.name,
              alPresionar: _seleccionarZip,
            ),
            const SizedBox(height: 32),
            if (_cargando)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colores.primario,
                  foregroundColor: Colores.blanco,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _enviarFormulario,
                child: const Text('Enviar Proyecto'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorArchivo({
    required String titulo,
    String? nombreArchivo,
    required VoidCallback alPresionar,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(
              nombreArchivo ?? 'Ningún archivo seleccionado',
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: alPresionar,
                child: const Text('Seleccionar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}