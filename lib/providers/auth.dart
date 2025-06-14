import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String _errorMessage = '';
  bool _isInitialized = false;

  AuthService() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _user = _auth.currentUser;
    _isInitialized = true;
    notifyListeners();

    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get currentUser {
    if (!_isInitialized) {
      _initializeAuth();
      return _auth.currentUser;
    }
    return _user;
  }

  String get errorMessage => _errorMessage;

  Future<UserCredential> signIn(String email, String password) async {
    try {
      _errorMessage = '';
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<UserCredential> signUp(String email, String password) async {
    try {
      _errorMessage = '';
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _errorMessage = '';
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}