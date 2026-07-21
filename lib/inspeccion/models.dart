import 'package:flutter/material.dart';

class Pregunta {
  final String id;
  final String texto;
  final int pe;
  final String obsCumple; // <-- El enunciado por defecto

  int? po;
  String estado;
  String observacion;
  String? fotoPath;

  // Controlador individual para manejar el texto en la interfaz sin perder el foco
  late final TextEditingController obsCtrl;

  Pregunta({
    required this.id,
    required this.texto,
    required this.pe,
    required this.obsCumple,
    this.po,
    this.estado = '',
    this.observacion = '',
    this.fotoPath,
  }) {
    // Inicializamos el controlador
    obsCtrl = TextEditingController(text: observacion);
    
    // Escuchamos lo que el usuario tipea para guardarlo automáticamente
    obsCtrl.addListener(() {
      observacion = obsCtrl.text;
    });
  }

  void marcar(String seleccion) {
    estado = seleccion;
    if (seleccion == 'CUMPLE') {
      po = pe;
      obsCtrl.text = obsCumple; // Inyecta el texto por defecto (queda editable)
    } else if (seleccion == 'NO CUMPLE') {
      po = 0;
      obsCtrl.text = ''; // Vacía la caja para que el inspector redacte
    } else if (seleccion == 'NO APLICA') {
      po = null;
      obsCtrl.text = '-'; // Inyecta el guion
      fotoPath = null;
    }
  }

  bool get requiereFotoYObs => estado == 'NO CUMPLE';

  // Helpers para la UI
  String get displayPe => estado == 'NO APLICA' ? '-' : pe.toString();
  String get displayPo => estado == 'NO APLICA' ? '-' : (po?.toString() ?? '');
  String get displayObs => estado == 'NO APLICA' ? '-' : observacion;

  void dispose() {
    obsCtrl.dispose();
  }
}

class SubSeccion {
  final String titulo;
  final List<Pregunta> preguntas;

  SubSeccion({required this.titulo, required this.preguntas});
}

class Seccion {
  final String titulo;
  final List<SubSeccion> subsecciones;

  Seccion({required this.titulo, required this.subsecciones});
}