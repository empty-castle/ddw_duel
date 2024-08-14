import 'package:flutter/material.dart';

class DialogHelper {
  static void error(
      {required BuildContext context,
      required String title,
      required String content}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text("Error"),
            ],
          ),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  static void show(
      {required BuildContext context,
      required String title,
      required String content,
      required Future<void> Function() onPressedFunc}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('아니오'),
            ),
            TextButton(
              onPressed: () async {
                await onPressedFunc();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('예'),
            ),
          ],
        );
      },
    );
  }
}
