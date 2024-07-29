import 'package:flutter/material.dart';

class SnackbarHelper {
  static void showSnackbar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(
        message,
        style: isError ? const TextStyle(color: Colors.white) : const TextStyle(color: Colors.black),
      ),
      duration: const Duration(seconds: 3),
      width: 600,
      behavior: SnackBarBehavior.floating,
      backgroundColor: isError ? const Color(0xFF632331) : const Color(0xF2EDD7F3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showErrorSnackbar(BuildContext context, String message) {
    showSnackbar(context, message, isError: true);
  }

  static void showInfoSnackbar(BuildContext context, String message) {
    showSnackbar(context, message, isError: false);
  }
}
