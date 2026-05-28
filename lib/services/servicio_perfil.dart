import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_clima/modelos/usuario.dart';

/// Servicio que maneja la lectura/escritura del perfil y la foto local.
class ServicioPerfil {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _claveFoto = 'foto_perfil_local';

  /// Obtiene el perfil del usuario actual desde Firestore.
  Future<Usuario> obtenerPerfil() async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('No hay sesión iniciada');

    final doc = await _firestore.collection('perfiles').doc(user.uid).get();
    // Recupera la ruta local de la foto guardada en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final rutaLocal = prefs.getString(_claveFoto);

    if (doc.exists) {
      final datos = doc.data()!;
      return Usuario.desdeFirestore(datos, user.uid, rutaLocal);
    } else {
      // Si no existe, crea un perfil por defecto con el email como nombre
      final perfilInicial = Usuario(
        uid: user.uid,
        nombre: user.email ?? 'Usuario',
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

  /// Actualiza el nombre y la biografía en Firestore (no la foto).
  Future<void> actualizarPerfil(Usuario usuario) async {
    final User? user = _auth.currentUser;
    if (user == null) throw Exception('No hay sesión iniciada');
    await _firestore.collection('perfiles').doc(user.uid).update({
      'nombre': usuario.nombre,
      'biografia': usuario.biografia,
    });
  }

  /// Guarda una copia local de la imagen seleccionada y devuelve su ruta.
  Future<String> guardarFotoLocal(XFile archivo) async {
    final directory = await getApplicationDocumentsDirectory();
    final String rutaCarpeta = '${directory.path}/fotos_perfil';
    final carpeta = Directory(rutaCarpeta);
    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }

    final String nombreArchivo =
        '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String rutaCompleta = '$rutaCarpeta/$nombreArchivo';

    // Copiar el archivo temporal a la ubicación permanente
    final File fotoTemporal = File(archivo.path);
    await fotoTemporal.copy(rutaCompleta);

    // Guardar la ruta en SharedPreferences para futuras sesiones
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveFoto, rutaCompleta);

    return rutaCompleta;
  }
}