import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../providers/task_providers.dart';
import '../providers/task_state.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/task_empty_state.dart';
import '../widgets/task_search_bar.dart';
import '../widgets/task_tile.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  late final ProviderSubscription<TaskState> _taskStateSubscription;

  @override
  void initState() {
    super.initState();
    _taskStateSubscription = ref.listenManual(
      taskProvider,
      _handleTaskStateChange,
    );
  }

  @override
  void dispose() {
    _taskStateSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskState = ref.watch(taskProvider);
    final filteredTasks = ref.watch(filteredTaskProvider);
    final hasTasks = taskState.tasks.isNotEmpty;
    final completedTasks = taskState.tasks
        .where((task) => task.isCompleted)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Task Manager')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRoutes.addTask),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  _TaskHeader(
                    totalTasks: taskState.tasks.length,
                    completedTasks: completedTasks,
                  ),
                  const SizedBox(height: 18),
                  if (taskState.isMutating)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(),
                    ),
                  TaskSearchBar(
                    value: ref.watch(searchProvider),
                    onChanged: (value) =>
                        ref.read(searchProvider.notifier).state = value,
                    onClear: () => ref.read(searchProvider.notifier).state = '',
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: switch (taskState.status) {
                        TaskStateStatus.initial || TaskStateStatus.loading =>
                          const Center(child: CircularProgressIndicator()),
                        TaskStateStatus.error => TaskEmptyState(
                          icon: Icons.error_outline_rounded,
                          title:
                              taskState.errorMessage ?? 'Unable to load tasks.',
                          description:
                              'Please try again. Your local task data will remain available.',
                          actionLabel: 'Retry',
                          onAction: () =>
                              ref.read(taskProvider.notifier).loadTasks(),
                        ),
                        TaskStateStatus.success when !hasTasks =>
                          const TaskEmptyState(
                            icon: Icons.checklist_rounded,
                            title: 'Your tasks will appear here.',
                            description:
                                'Add your first task to start tracking priorities, deadlines, and follow-up notes.',
                          ),
                        TaskStateStatus.success when filteredTasks.isEmpty =>
                          TaskEmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'No matching tasks found.',
                            description:
                                'Try a different title keyword or clear the current search.',
                            actionLabel: 'Clear Search',
                            onAction: () =>
                                ref.read(searchProvider.notifier).state = '',
                          ),
                        TaskStateStatus.success => ListView.separated(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount: filteredTasks.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];

                            return Dismissible(
                              key: ValueKey(task.id),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (_) =>
                                  showDeleteConfirmationDialog(
                                    context,
                                    task: task,
                                  ),
                              onDismissed: (_) {
                                ref
                                    .read(taskProvider.notifier)
                                    .deleteTask(task.id);
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text('${task.title} deleted.'),
                                    ),
                                  );
                              },
                              background: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.delete_outline_rounded,
                                        color:
                                            theme.colorScheme.onErrorContainer,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              child: TaskTile(
                                task: task,
                                onChanged: (_) => ref
                                    .read(taskProvider.notifier)
                                    .toggleTaskCompletion(task),
                                onTap: () => context.pushNamed(
                                  AppRoutes.editTask,
                                  extra: task,
                                ),
                              ),
                            );
                          },
                        ),
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTaskStateChange(TaskState? previous, TaskState next) {
    if (!mounted) {
      return;
    }

    final message = next.actionErrorMessage;
    final didChangeMessage =
        message != null && message != previous?.actionErrorMessage;

    if (!didChangeMessage) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));

    ref.read(taskProvider.notifier).clearActionError();
  }
}

class _TaskHeader extends StatelessWidget {
  const _TaskHeader({required this.totalTasks, required this.completedTasks});

  final int totalTasks;
  final int completedTasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pendingTasks = totalTasks - completedTasks;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 640;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay on top of today\'s priorities',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Track active work, close out completed tasks, and keep your list focused.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _TaskMetricChip(label: 'Total', value: totalTasks),
                    _TaskMetricChip(label: 'Pending', value: pendingTasks),
                    if (!isCompact)
                      _TaskMetricChip(label: 'Done', value: completedTasks),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TaskMetricChip extends StatelessWidget {
  const _TaskMetricChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
