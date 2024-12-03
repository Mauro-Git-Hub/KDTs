import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> createUserWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (cred.user != null) {
        // Actualizar el nombre del usuario
        await cred.user!.updateDisplayName(displayName);
        await cred.user!
            .reload(); // Recargar para asegurar que el cambio esté reflejado
      }

      return cred.user;
    } catch (e) {
      log("Error al registrar el usuario: $e");
    }
    return null;
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log("Error al iniciar sesión: $e");
    }
    return null;
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Error al cerrar sesión: $e");
    }
  }
}
