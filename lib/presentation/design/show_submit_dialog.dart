import 'package:flutter/material.dart';

Future<void> showSubmitDialog({
  required BuildContext context,
  required String title,
  required String content,
  required Function(BuildContext context) onSendPressed,
  required Function(BuildContext context) onCancelPressed,
}) async {
  FocusScope.of(context).unfocus();
  showGeneralDialog(
    context: context,
    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
        AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        ElevatedButton(
          onPressed: () => onSendPressed(context),
          child: const Text('Send'),
        ),
        ElevatedButton(
          onPressed: () => onCancelPressed(context),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}
