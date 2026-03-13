import '../entities/task.dart';
import '../repositories/task_repository.dart';

class AddTaskUseCase {
  const AddTaskUseCase(this._taskRepository);

  final TaskRepository _taskRepository;

  Future<void> call(Task task) {
    return _taskRepository.addTask(task);
  }
}
