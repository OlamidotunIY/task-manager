import '../repositories/task_repository.dart';

class DeleteTaskUseCase {
  const DeleteTaskUseCase(this._taskRepository);

  final TaskRepository _taskRepository;

  Future<void> call(String taskId) {
    return _taskRepository.deleteTask(taskId);
  }
}
