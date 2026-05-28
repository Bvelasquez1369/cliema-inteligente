import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_clima/modelos/publicacion.dart';
import 'package:app_clima/services/servicio_clima.dart';

/// Servicio para crear publicaciones y gestionar likes sin imágenes.
class ServicioPublicaciones {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ServicioClima _servicioClima = ServicioClima();

  /// Crea una nueva publicación de texto con datos del clima.
  Future<void> crearPublicacion({
    required String ciudad,
    String? comentario,
    required String nombreAutor,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('No hay sesión iniciada');

    // Obtiene el clima actual de la ciudad indicada
    final datosClima = await _servicioClima.obtenerClima(ciudad);

    final publicacion = Publicacion(
      id: '',
      uidAutor: user.uid,
      nombreAutor: nombreAutor,
      comentario: comentario,
      fecha: DateTime.now(),
      temperatura: datosClima.temperatura,
      viento: datosClima.viento,
      humedad: datosClima.humedad,
      likes: [],
    );

    await _firestore.collection('publicaciones').add(publicacion.aFirestore());
  }

  /// Retorna un stream con todas las publicaciones ordenadas por fecha.
  Stream<List<Publicacion>> obtenerPublicaciones() {
    return _firestore
        .collection('publicaciones')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Publicacion.desdeFirestore(doc.id, doc.data()))
            .toList());
  }

  /// Alterna like/unlike de una publicación.
  Future<void> toggleLike(String publicacionId) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('No hay sesión iniciada');

    final docRef = _firestore.collection('publicaciones').doc(publicacionId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final likes = List<String>.from(doc.data()!['likes'] ?? []);
    if (likes.contains(user.uid)) {
      likes.remove(user.uid);
    } else {
      likes.add(user.uid);
    }
    await docRef.update({'likes': likes});
  }
}