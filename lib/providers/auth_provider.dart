import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/db_service.dart';
import '../services/navigation_service.dart';
import '../services/snackbar_service.dart';

enum AuthStatus {
  NotAuthenticated,
  Authenticating,
  Authenticated,
  Error,
}

class AuthProvider with ChangeNotifier {
  User? _user;
  AuthStatus _status = AuthStatus.NotAuthenticated;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final AuthProvider _instance = AuthProvider._internal();

  factory AuthProvider() {
    return _instance;
  }

  AuthProvider._internal() {
    _checkCurrentUserIsAuthenticated();
  }

  Future<void> _checkCurrentUserIsAuthenticated() async {
    _user = _auth.currentUser;
    if (_user != null) {
      _status = AuthStatus.Authenticated;
      notifyListeners();
    }
  }

  User? get user => _user;

  AuthStatus get status => _status;

  Future<void> loginUserWithEmailAndPassword(String email, String password) async {
    try {
      _status = AuthStatus.Authenticating;
      notifyListeners();

      final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      _user = result.user;
      _status = AuthStatus.Authenticated;

      await DBService.instance.updateUserLastSeenTime(_user!.uid);
      NavigationService.instance.navigateToReplacement("home");
      SnackBarService.instance.showSuccessSnackBar("Login successful");
    } catch (e) {
      _status = AuthStatus.Error;
      SnackBarService.instance.showErrorSnackBar("Login failed: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> registerUserWithEmailAndPassword(String email, String password) async {
    try {
      _status = AuthStatus.Authenticating;
      notifyListeners();

      final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _user = result.user;
      _status = AuthStatus.Authenticated;

      await DBService.instance.updateUserLastSeenTime(_user!.uid);
      NavigationService.instance.navigateToReplacement("home");
      SnackBarService.instance.showSuccessSnackBar("Registration successful");
    } catch (e) {
      _status = AuthStatus.Error;
      SnackBarService.instance.showErrorSnackBar("Registration failed: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> logoutUser() async {
    try {
      await _auth.signOut();
      _user = null;
      _status = AuthStatus.NotAuthenticated;
      NavigationService.instance.navigateToReplacement("login");
      SnackBarService.instance.showSuccessSnackBar("Logout successful");
    } catch (e) {
      SnackBarService.instance.showErrorSnackBar("Logout failed: $e");
    } finally {
      notifyListeners();
    }
  }
}
