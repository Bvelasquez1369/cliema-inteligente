import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_clima/modelos/usuario.dart';

class ServicioPerfil {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Usuario> obtenerPerfil() async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('No hay sesión iniciada');

    final doc = await _firestore.collection('perfiles').doc(user.uid).get();

    if (doc.exists) {
      final datos = doc.data()!;
      return Usuario.desdeFirestore(datos, user.uid, null);
    } else {
      final perfilInicial = Usuario(
        uid: user.uid,
        nombre: user.email?.split('@')[0] ?? 'Usuario',
        biografia: '',
        urlFoto: null,
      );
      await _firestore
          .collection('perfiles')
          .doc(user.uid)
          .set(perfilInicial.aFirestore());
      return perfilInicial;
    }
  }

  Future<void> actualizarPerfil(Usuario usuario) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('No hay sesión iniciada');
    await _firestore.collection('perfiles').doc(user.uid).update({
      'nombre': usuario.nombre,
      'biografia': usuario.biografia,
    });
  }
}
