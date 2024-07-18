import 'package:flutter/material.dart';

class SnackbarHelper {
  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      duration: const Duration(seconds: 3),
      width: 600,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.grey[850],
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
