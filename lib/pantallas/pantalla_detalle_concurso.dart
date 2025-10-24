import 'package:flutter/material.dart';
import '../modelos/concurso.dart';
import '../utilidades/estilos.dart';
import '../widgets/widgets_personalizados.dart';
import 'pantalla_enviar_proyecto.dart';
import 'pantalla_mis_proyectos.dart';

class PantallaDetalleConcurso extends StatelessWidget {
  final Concurso concurso;

  const PantallaDetalleConcurso({
    super.key,
    required this.concurso,
  });

  void _seleccionarCategoria(BuildContext context, Categoria categoria) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PantallaEnviarProyecto(
          concurso: concurso,
          categoria: categoria,
        ),
      ),
    );
  }

  void _navegarAMisProyectos(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PantallaMisProyectos(concursoId: concurso.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colores.fondo,
      appBar: AppBar(
        title: const Text('Detalle del Concurso'),
        backgroundColor: Colores.primario,
        foregroundColor: Colores.blanco,
      ),
      body: SingleChildScrollView(
        padding: Estilos.paddingGeneral,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informacion del concurso
            TarjetaPersonalizada(
              hijo: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          concurso.nombre,
                          style: Estilos.titulo,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: concurso.estaEnPeriodoDeInscripcion ? Colores.exito : Colores.gris,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          concurso.estaEnPeriodoDeInscripcion ? 'Abierto' : 'Cerrado',
                          style: const TextStyle(
                            color: Colores.blanco,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fecha de Inicio',
                              style: Estilos.cuerpoSecundario,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${concurso.fechaCreacion.day}/${concurso.fechaCreacion.month}/${concurso.fechaCreacion.year}',
                              style: Estilos.cuerpo.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fecha de Fin',
                              style: Estilos.cuerpoSecundario,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${concurso.fechaLimiteInscripcion.day}/${concurso.fechaLimiteInscripcion.month}/${concurso.fechaLimiteInscripcion.year}',
                              style: Estilos.cuerpo.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            BotonPersonalizado(
              texto: 'Ver Mis Envíos',
              alPresionar: () => _navegarAMisProyectos(context),
              esSecundario: true,
            ),
            const SizedBox(height: 24),

            Text(
              'Categorias Disponibles para Participar',
              style: Estilos.subtitulo,
            ),
            const SizedBox(height: 16),

            if (concurso.categorias.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: Colores.gris,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No hay categorias disponibles',
                        style: Estilos.subtitulo,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: concurso.categorias.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final categoria = concurso.categorias[index];
                  return _construirTarjetaCategoria(context, categoria);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _construirTarjetaCategoria(BuildContext context, Categoria categoria) {
    final bool puedeEnviar = concurso.estaEnPeriodoDeInscripcion;

    return TarjetaPersonalizada(
      alPresionar: puedeEnviar ? () => _seleccionarCategoria(context, categoria) : null,
      hijo: Opacity(
        opacity: puedeEnviar ? 1.0 : 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category,
                  color: Colores.primario,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    categoria.nombre,
                    style: Estilos.subtitulo.copyWith(
                      color: puedeEnviar ? Colores.primario : Colores.gris,
                    ),
                  ),
                ),
                if (puedeEnviar)
                  const Icon(Icons.arrow_forward_ios, color: Colores.gris, size: 16)
                else
                  const Icon(Icons.lock_outline, color: Colores.gris, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ciclos: ${categoria.rangoCiclos}',
              style: Estilos.cuerpoSecundario,
            ),
          ],
        ),
      ),
    );
  }
}