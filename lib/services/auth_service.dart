import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final GoogleSignIn _googleSignIn;

  AuthService() {
    _googleSignIn = GoogleSignIn(
      clientId: kIsWeb
          ? (dotenv.env['GOOGLE_WEB_CLIENT_ID'] ??
                '1079053947136-2rushsobd5f82vna93isf39i73p3t2js.apps.googleusercontent.com')
          : null,
    );
  }

  // Auth State Stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current User
  User? get currentUser => _auth.currentUser;

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential cred = await _auth.signInWithCredential(credential);

      // Check if user exists in Firestore, if not create
      if (cred.user != null) {
        final doc = await _firestore
            .collection('users')
            .doc(cred.user!.uid)
            .get();
        if (!doc.exists) {
          await _firestore.collection('users').doc(cred.user!.uid).set({
            'uid': cred.user!.uid,
            'displayName': cred.user!.displayName ?? 'User',
            'email': cred.user!.email,
            'phoneNumber': cred.user!.phoneNumber ?? '',
            'role': 'user',
            'rating': 5.0,
          });
        }
      }

      return cred;
    } catch (e) {
      rethrow;
    }
  }

  // Sign In
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign Up
  Future<UserCredential> signUp(
    String email,
    String password,
    String name,
    String phoneNumber,
  ) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      if (cred.user != null) {
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'displayName': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'role': 'user',
          'rating': 5.0, // Default rating
        });
      }

      return cred;
    } catch (e) {
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Get User Role
  Future<String?> getUserRole() async {
    if (currentUser == null) return null;
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      if (doc.exists) {
        return (doc.data() as Map<String, dynamic>)['role'];
      }
    } catch (e) {
      print('Error getting user role: $e');
    }
    return null;
  }
}
