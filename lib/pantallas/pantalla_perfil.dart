import 'package:flutter/material.dart';
import '../modelos/estudiante.dart';
import '../servicios/servicio_autenticacion.dart';
import '../utilidades/estilos.dart';
import '../widgets/widgets_personalizados.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  late Future<Estudiante?> _futureEstudiante;

  @override
  void initState() {
    super.initState();
    _futureEstudiante = ServicioAutenticacion.instancia.obtenerEstudianteActual();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colores.primario,
        foregroundColor: Colores.blanco,
      ),
      body: FutureBuilder<Estudiante?>(
        future: _futureEstudiante,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No se pudo cargar la información del perfil.'));
          }

          final estudiante = snapshot.data!;

          return SingleChildScrollView(
            padding: Estilos.paddingGeneral,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colores.primario,
                        child: Icon(Icons.person, size: 60, color: Colores.blanco),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${estudiante.nombres} ${estudiante.apellidos}',
                        style: Estilos.titulo,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        estudiante.correo,
                        style: Estilos.cuerpoSecundario,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 48),
                _buildInfoRow(Icons.school_outlined, 'Código Universitario', estudiante.codigoUniversitario),
                _buildInfoRow(Icons.cake_outlined, 'Ciclo', '${estudiante.ciclo}° Ciclo'),
                _buildInfoRow(Icons.phone_outlined, 'Teléfono', estudiante.numeroTelefonico),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colores.primario, size: 28),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Estilos.cuerpoSecundario),
                const SizedBox(height: 4),
                Text(value, style: Estilos.subtitulo.copyWith(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}