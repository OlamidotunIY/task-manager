import 'package:flutter/material.dart';

class TaskEmptyState extends StatelessWidget {
  const TaskEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            offset: Offset.zero,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 260),
              opacity: 1,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 88,
                        width: 88,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Icon(
                          icon,
                          size: 42,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (actionLabel != null && onAction != null) ...[
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: onAction,
                          child: Text(actionLabel!),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
