import '../entities/task.dart';

abstract interface class TaskRepository {
  Future<List<Task>> getTasks();

  Future<void> addTask(Task task);

  Future<void> updateTask(Task task);

  Future<void> deleteTask(String taskId);

  Future<void> toggleTaskCompletion({
    required String taskId,
    required bool isCompleted,
  });
}
