import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet_profile.dart';

class User {
  final String id;
  final String email;
  String name;
  String petName;
  PetProfile? petProfile;
  bool petProfileComplete = false;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.petName = 'Bella',
    this.petProfile,
    this.petProfileComplete = false,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'petName': petName,
      'petProfileComplete': petProfileComplete,
      if (petProfile != null) ...{
        'petProfile': {
          'dogName': petProfile!.dogName,
          'breed': petProfile!.breed,
          'ageCategory': petProfile!.ageCategory,
          'weight': petProfile!.weight,
          'weightUnit': petProfile!.weightUnit,
        }
      }
    };
  }

  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    PetProfile? petProfile;
    if (json['petProfile'] != null) {
      final petData = json['petProfile'] as Map<String, dynamic>;
      petProfile = PetProfile(
        dogName: petData['dogName'] ?? '',
        breed: petData['breed'] ?? '',
        ageCategory: petData['ageCategory'] ?? '',
        weight: (petData['weight'] ?? 0).toDouble(),
        weightUnit: petData['weightUnit'] ?? 'lbs',
      );
    }

    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      petName: json['petName'] ?? 'Bella',
      petProfile: petProfile,
      petProfileComplete: json['petProfileComplete'] ?? false,
    );
  }
}

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthService() {
    // Listen to authentication state changes
    _firebaseAuth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserFromFirestore(firebaseUser.uid);
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserFromFirestore(String userId) async {
    try {
      final userDoc = await _firebaseFirestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        _currentUser = User.fromJson(userDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error loading user from Firestore: $e');
    }
  }

  Future<void> reloadCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return;
    }

    await _loadUserFromFirestore(firebaseUser.uid);
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        _errorMessage = 'All fields are required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _errorMessage = 'Password must be at least 6 characters';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create user with Firebase
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create user document in Firestore
        final newUser = User(
          id: userCredential.user!.uid,
          email: email,
          name: name,
        );

        await _firebaseFirestore
            .collection('users')
            .doc(newUser.id)
            .set(newUser.toJson());

        _currentUser = newUser;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Failed to create user';
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _errorMessage = 'Email already registered';
      } else if (e.code == 'invalid-email') {
        _errorMessage = 'Invalid email address';
      } else {
        _errorMessage = 'Sign up failed: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Sign up failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        _errorMessage = 'Email and password are required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Sign in with Firebase
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _loadUserFromFirestore(userCredential.user!.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _errorMessage = 'Email not found';
      } else if (e.code == 'wrong-password') {
        _errorMessage = 'Incorrect password';
      } else {
        _errorMessage = 'Login failed: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout failed: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? petName,
  }) async {
    if (_currentUser == null) {
      _errorMessage = 'No user logged in';
      return false;
    }

    try {
      if (name != null && name.isNotEmpty) {
        _currentUser!.name = name;
      }

      if (petName != null && petName.isNotEmpty) {
        _currentUser!.petName = petName;
      }

      // Update in Firestore
      await _firebaseFirestore
          .collection('users')
          .doc(_currentUser!.id)
          .update(_currentUser!.toJson());

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail() async {
    if (_currentUser == null) {
      _errorMessage = 'No user logged in';
      notifyListeners();
      return false;
    }

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: _currentUser!.email);
      _errorMessage = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = 'Password reset failed: ${e.message}';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Password reset failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> savePetProfile(PetProfile petProfile) async {
    if (_currentUser == null) {
      _errorMessage = 'No user logged in';
      return false;
    }

    try {
      _currentUser!.petProfile = petProfile;
      _currentUser!.petProfileComplete = true;
      _currentUser!.petName = petProfile.dogName;

      // Update in Firestore
      await _firebaseFirestore
          .collection('users')
          .doc(_currentUser!.id)
          .update(_currentUser!.toJson());

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save pet profile: ${e.toString()}';
      return false;
    }
  }
}
