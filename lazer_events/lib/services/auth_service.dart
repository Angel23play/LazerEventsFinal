import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Login con email y password
  Future<AppUser?> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _db.collection('users').doc(result.user!.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        // Pasar el id explícitamente
        return AppUser(
          id: userDoc.id,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
        );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception("Error login: ${e.message}");
    }
  }

  // Registro con email y password
  Future<AppUser?> register(String name, String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = AppUser(
        id: result.user!.uid, // obligatorio
        name: name,
        email: email,
      );

      await _db.collection('users').doc(newUser.id).set(newUser.toMap());

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw Exception("Error registro: ${e.message}");
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Obtener usuario actual de Firebase
  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user != null) {
      return AppUser(
        id: user.uid, // obligatorio
        name: user.displayName ?? '',
        email: user.email ?? '',
      );
    }
    return null;
  }
}
