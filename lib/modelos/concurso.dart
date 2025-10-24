import 'package:cloud_firestore/cloud_firestore.dart';

class Concurso {
  final String id;
  final String nombre;
  final DateTime fechaCreacion;
  final DateTime fechaLimiteInscripcion;
  final List<Categoria> categorias;

  Concurso({
    required this.id,
    required this.nombre,
    required this.fechaCreacion,
    required this.fechaLimiteInscripcion,
    required this.categorias,
  });

  factory Concurso.desdeDocumento(String id, Map<String, dynamic> data) {
    return Concurso(
      id: id,
      nombre: data['nombre'] ?? '',
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
      fechaLimiteInscripcion:
          (data['fechaLimiteInscripcion'] as Timestamp).toDate(),
      categorias: (data['categorias'] as List<dynamic>?)
              ?.map((categoria) => Categoria.desdeJson(categoria))
              .toList() ??
          [],
    );
  }

  bool get estaEnPeriodoDeInscripcion {
    final ahora = DateTime.now();
    return ahora.isAfter(fechaCreacion) && ahora.isBefore(fechaLimiteInscripcion);
  }

  bool get estaVigente {
    return estaEnPeriodoDeInscripcion;
  }
}

class Categoria {
  final String nombre;
  final String rangoCiclos;

  Categoria({
    required this.nombre,
    required this.rangoCiclos,
  });

  factory Categoria.desdeJson(Map<String, dynamic> json) {
    return Categoria(
      nombre: json['nombre'] ?? '',
      rangoCiclos: json['rangoCiclos'] ?? '',
    );
  }

  Map<String, dynamic> aJson() {
    return {
      'nombre': nombre,
      'rangoCiclos': rangoCiclos,
    };
  }
}