import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_manager/app.dart';
import 'package:task_manager/features/tasks/data/datasource/task_local_datasource.dart';
import 'package:task_manager/features/tasks/data/models/task_model.dart';
import 'package:task_manager/features/tasks/presentation/providers/task_providers.dart';

class _FakeTaskLocalDataSource implements TaskLocalDataSource {
  final Map<String, TaskModel> _tasks = <String, TaskModel>{};

  @override
  Future<void> addTask(TaskModel task) async {
    _tasks[task.id] = task;
  }

  @override
  Future<void> deleteTask(String taskId) async {
    _tasks.remove(taskId);
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    return _tasks.values.toList(growable: false);
  }

  @override
  Future<void> toggleTaskCompletion({
    required String taskId,
    required bool isCompleted,
  }) async {
    final task = _tasks[taskId];
    if (task == null) {
      return;
    }

    _tasks[taskId] = task.copyWith(
      isCompleted: isCompleted,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    _tasks[task.id] = task;
  }
}

void main() {
  testWidgets('renders task list placeholder screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskLocalDataSourceProvider.overrideWithValue(
            _FakeTaskLocalDataSource(),
          ),
        ],
        child: const TaskManagerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Task Manager'), findsOneWidget);
    expect(find.text('Your tasks will appear here.'), findsOneWidget);
  });
}
