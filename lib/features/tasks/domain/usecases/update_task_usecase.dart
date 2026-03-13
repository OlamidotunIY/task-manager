import '../entities/task.dart';
import '../repositories/task_repository.dart';

class UpdateTaskUseCase {
  const UpdateTaskUseCase(this._taskRepository);

  final TaskRepository _taskRepository;

  Future<void> call(Task task) {
    return _taskRepository.updateTask(task);
  }
}
