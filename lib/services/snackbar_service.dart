import 'package:flutter/material.dart';

class SnackBarService {
  static final SnackBarService instance = SnackBarService._();
  late BuildContext _buildContext;

  SnackBarService._();

  set buildContext(BuildContext context) {
    _buildContext = context;
  }

  void showSnackBar(String message, {Color backgroundColor = Colors.blue}) {
    if (_buildContext != null) {
      ScaffoldMessenger.of(_buildContext).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
            message,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          backgroundColor: backgroundColor,
        ),
      );
    }
  }

  void showErrorSnackBar(String message) => showSnackBar(message, backgroundColor: Colors.red);

  void showSuccessSnackBar(String message) => showSnackBar(message, backgroundColor: Colors.green);
}
