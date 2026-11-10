import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
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

  Future<String?> loginWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return 'Google sign in was cancelled';

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await auth.signInWithCredential(credential);
      final user = result.user!;

      final userDoc = firestore.collection('users').doc(user.uid);
      final snapshot = await userDoc.get();
      if (!snapshot.exists) {
        await userDoc.set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'phone': '',
          'avatarIndex': 0,
        });
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return getErrorMessage(e.code);
    } catch (e) {
      print('GOOGLE ERROR: $e');
      return 'Google sign in failed, try again';
    }
  }

  Future<void> signOut() async {
    await googleSignIn.signOut();
    await auth.signOut();
  }

  Future<String?> updateProfile({
    required String name,
    required String phone,
    required int avatarIndex,
  }) async {
    try {
      final user = auth.currentUser!;
      await user.updateDisplayName(name.trim());
      await firestore.collection('users').doc(user.uid).set({
        'name': name.trim(),
        'phone': phone.trim(),
        'avatarIndex': avatarIndex,
      }, SetOptions(merge: true));
      return null;
    } catch (e) {
      return 'Could not update data, try again';
    }
  }

  Future<String?> deleteAccount() async {
    try {
      final user = auth.currentUser!;
      final uid = user.uid;

      await user.delete();

      final userDoc = firestore.collection('users').doc(uid);
      for (final name in ['watchlist', 'history']) {
        final snapshot = await userDoc.collection(name).get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
      await userDoc.delete();
      await googleSignIn.signOut();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'For security, please login again, then delete your account';
      }
      return getErrorMessage(e.code);
    } catch (e) {
      return 'Something went wrong, try again';
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