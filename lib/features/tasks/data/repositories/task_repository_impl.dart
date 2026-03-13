import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasource/task_local_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._localDataSource);

  final TaskLocalDataSource _localDataSource;

  @override
  Future<void> addTask(Task task) {
    return _localDataSource.addTask(TaskModel.fromEntity(task));
  }

  @override
  Future<void> deleteTask(String taskId) {
    return _localDataSource.deleteTask(taskId);
  }

  @override
  Future<List<Task>> getTasks() async {
    final tasks = await _localDataSource.getTasks();
    return tasks.map((task) => task.toEntity()).toList(growable: false);
  }

  @override
  Future<void> toggleTaskCompletion({
    required String taskId,
    required bool isCompleted,
  }) {
    return _localDataSource.toggleTaskCompletion(
      taskId: taskId,
      isCompleted: isCompleted,
    );
  }

  @override
  Future<void> updateTask(Task task) {
    return _localDataSource.updateTask(TaskModel.fromEntity(task));
  }
}
