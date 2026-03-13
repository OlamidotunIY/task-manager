import '../../domain/entities/task.dart';

enum TaskStateStatus { initial, loading, success, error }

class TaskState {
  const TaskState({
    required this.status,
    required this.tasks,
    this.isMutating = false,
    this.errorMessage,
    this.actionErrorMessage,
  });

  factory TaskState.initial() {
    return const TaskState(status: TaskStateStatus.initial, tasks: <Task>[]);
  }

  final TaskStateStatus status;
  final List<Task> tasks;
  final bool isMutating;
  final String? errorMessage;
  final String? actionErrorMessage;

  bool get isLoading =>
      status == TaskStateStatus.initial || status == TaskStateStatus.loading;

  bool get hasError => status == TaskStateStatus.error && errorMessage != null;

  bool get isEmpty => status == TaskStateStatus.success && tasks.isEmpty;

  TaskState copyWith({
    TaskStateStatus? status,
    List<Task>? tasks,
    bool? isMutating,
    String? errorMessage,
    String? actionErrorMessage,
    bool clearErrorMessage = false,
    bool clearActionErrorMessage = false,
  }) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      actionErrorMessage: clearActionErrorMessage
          ? null
          : actionErrorMessage ?? this.actionErrorMessage,
    );
  }
}
