import 'package:flutter/material.dart';

void showSnackBar({
  required BuildContext context,
  required String message,
}) =>
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
