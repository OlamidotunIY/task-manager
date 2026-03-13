import 'package:hive/hive.dart';

import '../../../../core/constants/hive_constants.dart';
import '../models/task_model.dart';
import 'task_local_datasource.dart';

class HiveTaskLocalDataSource implements TaskLocalDataSource {
  HiveTaskLocalDataSource(this._taskBox);

  final Box<TaskModel> _taskBox;

  factory HiveTaskLocalDataSource.create() {
    return HiveTaskLocalDataSource(Hive.box<TaskModel>(HiveConstants.tasksBox));
  }

  @override
  Future<void> addTask(TaskModel task) async {
    await _taskBox.put(task.id, task);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _ensureTaskExists(taskId);
    await _taskBox.delete(taskId);
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    final tasks = _taskBox.values.toList(growable: false)
      ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));

    return tasks;
  }

  @override
  Future<void> toggleTaskCompletion({
    required String taskId,
    required bool isCompleted,
  }) async {
    final existingTask = await _getTaskOrThrow(taskId);
    await _taskBox.put(
      taskId,
      existingTask.copyWith(
        isCompleted: isCompleted,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await _ensureTaskExists(task.id);
    await _taskBox.put(task.id, task);
  }

  Future<void> _ensureTaskExists(String taskId) async {
    if (!_taskBox.containsKey(taskId)) {
      throw TaskLocalDataSourceException('Task with id $taskId was not found.');
    }
  }

  Future<TaskModel> _getTaskOrThrow(String taskId) async {
    final task = _taskBox.get(taskId);

    if (task == null) {
      throw TaskLocalDataSourceException('Task with id $taskId was not found.');
    }

    return task;
  }
}
