import '../models/task_model.dart';

abstract interface class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();

  Future<void> addTask(TaskModel task);

  Future<void> updateTask(TaskModel task);

  Future<void> deleteTask(String taskId);

  Future<void> toggleTaskCompletion({
    required String taskId,
    required bool isCompleted,
  });
}

class TaskLocalDataSourceException implements Exception {
  const TaskLocalDataSourceException(this.message);

  final String message;

  @override
  String toString() => 'TaskLocalDataSourceException(message: $message)';
}
