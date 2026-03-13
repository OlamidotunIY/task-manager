import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onTap,
  });

  final Task task;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Checkbox(value: task.isCompleted, onChanged: onChanged),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        style: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: theme.colorScheme.onSurface,
                        ),
                        child: Text(task.title),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description.isEmpty
                            ? 'No description provided.'
                            : task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: task.isCompleted
                              ? theme.colorScheme.secondaryContainer
                              : theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          task.isCompleted ? 'Completed' : 'In Progress',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: task.isCompleted
                                ? theme.colorScheme.onSecondaryContainer
                                : theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
