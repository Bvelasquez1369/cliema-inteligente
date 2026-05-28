import 'package:firebase_auth/firebase_auth.dart';

class ServicioAutenticacion {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get usuarioActual => _auth.currentUser;
  Stream<User?> get cambiosDeUsuario => _auth.authStateChanges();

  Future<User?> crearCuenta(String correo, String contrasena) async {
    try {
      UserCredential credencial = await _auth.createUserWithEmailAndPassword(
        email: correo.trim(),
        password: contrasena,
      );
      return credencial.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('La contraseña debe tener al menos 6 caracteres');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Ese correo ya está registrado');
      } else if (e.code == 'invalid-email') {
        throw Exception('El correo no tiene un formato válido');
      }
      throw Exception('Error al registrarse: ${e.message}');
    }
  }

  Future<User?> iniciarSesion(String correo, String contrasena) async {
    try {
      UserCredential credencial = await _auth.signInWithEmailAndPassword(
        email: correo.trim(),
        password: contrasena,
      );
      return credencial.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No existe una cuenta con ese correo');
      } else if (e.code == 'wrong-password') {
        throw Exception('Contraseña incorrecta');
      }
      throw Exception('Error al iniciar sesión: ${e.message}');
    }
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}