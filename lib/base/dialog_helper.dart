import 'package:flutter/material.dart';

class DialogHelper {
  static void show(
      {required BuildContext context,
      required String title,
      required String content,
      required Future<void> Function() onPressedFunc}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
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
