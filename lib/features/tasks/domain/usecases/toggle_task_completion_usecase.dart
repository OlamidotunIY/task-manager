import '../repositories/task_repository.dart';

class ToggleTaskCompletionUseCase {
  const ToggleTaskCompletionUseCase(this._taskRepository);

  final TaskRepository _taskRepository;

  Future<void> call({required String taskId, required bool isCompleted}) {
    return _taskRepository.toggleTaskCompletion(
      taskId: taskId,
      isCompleted: isCompleted,
    );
  }
}
