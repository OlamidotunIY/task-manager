import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase {
  const GetTasksUseCase(this._taskRepository);

  final TaskRepository _taskRepository;

  Future<List<Task>> call() {
    return _taskRepository.getTasks();
  }
}
