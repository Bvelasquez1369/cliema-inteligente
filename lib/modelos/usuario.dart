/// Modelo que representa los datos del perfil de un usuario.
class Usuario {
  final String uid;
  final String nombre;
  final String biografia;
  final String? urlFoto; // Puede ser URL remota o ruta local

  Usuario({
    required this.uid,
    required this.nombre,
    required this.biografia,
    this.urlFoto,
  });

  factory Usuario.desdeFirestore(Map<String, dynamic> datos, String uid,
      [String? rutaLocal]) {
    return Usuario(
      uid: uid,
      nombre: datos['nombre'] ?? '',
      biografia: datos['biografia'] ?? '',
      urlFoto: rutaLocal, // Prefiere la ruta local si existe
    );
  }

  Map<String, dynamic> aFirestore() {
    return {
      'nombre': nombre,
      'biografia': biografia,
      // No guardamos urlFoto en Firestore para evitar URL rotas o problemas de Storage
    };
  }
}