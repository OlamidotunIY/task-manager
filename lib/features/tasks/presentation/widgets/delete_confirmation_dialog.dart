import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';

Future<bool?> showDeleteConfirmationDialog(
  BuildContext context, {
  required Task task,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded),
        title: const Text('Delete task?'),
        content: Text('Remove "${task.title}" from your task list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
