import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/task.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/toggle_task_completion_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import 'task_state.dart';

class TaskNotifier extends StateNotifier<TaskState> {
  TaskNotifier({
    required GetTasksUseCase getTasksUseCase,
    required AddTaskUseCase addTaskUseCase,
    required UpdateTaskUseCase updateTaskUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
    required ToggleTaskCompletionUseCase toggleTaskCompletionUseCase,
    required Uuid uuid,
  }) : _getTasksUseCase = getTasksUseCase,
       _addTaskUseCase = addTaskUseCase,
       _updateTaskUseCase = updateTaskUseCase,
       _deleteTaskUseCase = deleteTaskUseCase,
       _toggleTaskCompletionUseCase = toggleTaskCompletionUseCase,
       _uuid = uuid,
       super(TaskState.initial()) {
    unawaited(loadTasks());
  }

  final GetTasksUseCase _getTasksUseCase;
  final AddTaskUseCase _addTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final ToggleTaskCompletionUseCase _toggleTaskCompletionUseCase;
  final Uuid _uuid;

  Future<void> loadTasks() async {
    state = state.copyWith(
      status: TaskStateStatus.loading,
      clearErrorMessage: true,
      clearActionErrorMessage: true,
    );

    try {
      final tasks = await _getTasksUseCase();
      state = state.copyWith(
        status: TaskStateStatus.success,
        tasks: tasks,
        isMutating: false,
        clearErrorMessage: true,
        clearActionErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: TaskStateStatus.error,
        isMutating: false,
        errorMessage: 'Failed to load tasks. Please try again.',
      );
    }
  }

  Future<void> addTask({
    required String title,
    required String description,
  }) async {
    final now = DateTime.now();
    final task = Task(
      id: _uuid.v4(),
      title: title.trim(),
      description: description.trim(),
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );

    await _runMutation(
      action: () => _addTaskUseCase(task),
      failureMessage: 'Could not create the task. Please try again.',
    );
  }

  Future<void> updateTask({
    required Task task,
    required String title,
    required String description,
  }) async {
    final updatedTask = task.copyWith(
      title: title.trim(),
      description: description.trim(),
      updatedAt: DateTime.now(),
    );

    await _runMutation(
      action: () => _updateTaskUseCase(updatedTask),
      failureMessage: 'Could not update the task. Please try again.',
    );
  }

  Future<void> deleteTask(String taskId) async {
    await _runMutation(
      action: () => _deleteTaskUseCase(taskId),
      failureMessage: 'Could not delete the task. Please try again.',
    );
  }

  Future<void> toggleTaskCompletion(Task task) async {
    await _runMutation(
      action: () => _toggleTaskCompletionUseCase(
        taskId: task.id,
        isCompleted: !task.isCompleted,
      ),
      failureMessage: 'Could not update the task status. Please try again.',
    );
  }

  void clearActionError() {
    if (state.actionErrorMessage == null) {
      return;
    }

    state = state.copyWith(clearActionErrorMessage: true);
  }

  Future<void> _runMutation({
    required Future<void> Function() action,
    required String failureMessage,
  }) async {
    final previousTasks = state.tasks;
    final previousStatus = state.status;

    state = state.copyWith(isMutating: true, clearActionErrorMessage: true);

    try {
      await action();
      final tasks = await _getTasksUseCase();
      state = state.copyWith(
        status: TaskStateStatus.success,
        tasks: tasks,
        isMutating: false,
        clearErrorMessage: true,
        clearActionErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: previousStatus == TaskStateStatus.initial
            ? TaskStateStatus.error
            : previousStatus,
        tasks: previousTasks,
        isMutating: false,
        actionErrorMessage: failureMessage,
      );
    }
  }
}
