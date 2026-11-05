import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // بترجع null لو نجح، أو رسالة الخطأ لو فشل
  Future<String?> login(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return getErrorMessage(e.code);
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int avatarIndex,
  }) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(name.trim());

      await firestore.collection('users').doc(user.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'avatarIndex': avatarIndex,
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return getErrorMessage(e.code);
    } catch (e) {
      return 'Account created but saving data failed, check Firestore';
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return getErrorMessage(e.code);
    }
  }

  String getErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Email format is not valid';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'weak-password':
        return 'Password must be at least 6 characters';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts, try again later';
      case 'network-request-failed':
        return 'Check your internet connection';
      default:
        return 'Something went wrong, try again';
    }
  }
}