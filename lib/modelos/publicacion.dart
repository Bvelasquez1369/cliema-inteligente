import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo que representa una publicación en el feed social.
/// Almacena el autor, comentario, datos del clima y likes.
class Publicacion {
  final String id;
  final String uidAutor;
  final String nombreAutor;
  final String? comentario;
  final DateTime fecha;
  final double temperatura;
  final double viento;
  final int humedad;
  final List<String> likes;

  /// Crea una nueva publicación con todos sus campos.
  Publicacion({
    required this.id,
    required this.uidAutor,
    required this.nombreAutor,
    this.comentario,
    required this.fecha,
    required this.temperatura,
    required this.viento,
    required this.humedad,
    this.likes = const [],
  });

  /// Construye una publicación desde un documento de Firestore.
  factory Publicacion.desdeFirestore(String id, Map<String, dynamic> datos) {
    return Publicacion(
      id: id,
      uidAutor: datos['uidAutor'] ?? '',
      nombreAutor: datos['nombreAutor'] ?? '',
      comentario: datos['comentario'],
      fecha: (datos['fecha'] as Timestamp).toDate(),
      temperatura: (datos['temperatura'] ?? 0).toDouble(),
      viento: (datos['viento'] ?? 0).toDouble(),
      humedad: (datos['humedad'] ?? 0).toInt(),
      likes: List<String>.from(datos['likes'] ?? []),
    );
  }

  /// Convierte la publicación en un mapa para guardar en Firestore.
  Map<String, dynamic> aFirestore() {
    return {
      'uidAutor': uidAutor,
      'nombreAutor': nombreAutor,
      'comentario': comentario,
      'fecha': Timestamp.fromDate(fecha),
      'temperatura': temperatura,
      'viento': viento,
      'humedad': humedad,
      'likes': likes,
    };
  }
}