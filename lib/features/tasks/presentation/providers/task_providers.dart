import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasource/task_local_datasource.dart';
import '../../data/datasource/task_local_datasource_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/search_tasks_usecase.dart';
import '../../domain/usecases/toggle_task_completion_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import 'task_notifier.dart';
import 'task_state.dart';

final uuidProvider = Provider<Uuid>((ref) => const Uuid());

final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  return HiveTaskLocalDataSource.create();
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.watch(taskLocalDataSourceProvider));
});

final getTasksUseCaseProvider = Provider<GetTasksUseCase>((ref) {
  return GetTasksUseCase(ref.watch(taskRepositoryProvider));
});

final addTaskUseCaseProvider = Provider<AddTaskUseCase>((ref) {
  return AddTaskUseCase(ref.watch(taskRepositoryProvider));
});

final updateTaskUseCaseProvider = Provider<UpdateTaskUseCase>((ref) {
  return UpdateTaskUseCase(ref.watch(taskRepositoryProvider));
});

final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>((ref) {
  return DeleteTaskUseCase(ref.watch(taskRepositoryProvider));
});

final toggleTaskCompletionUseCaseProvider =
    Provider<ToggleTaskCompletionUseCase>((ref) {
      return ToggleTaskCompletionUseCase(ref.watch(taskRepositoryProvider));
    });

final searchTasksUseCaseProvider = Provider<SearchTasksUseCase>((ref) {
  return const SearchTasksUseCase();
});

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(
    getTasksUseCase: ref.watch(getTasksUseCaseProvider),
    addTaskUseCase: ref.watch(addTaskUseCaseProvider),
    updateTaskUseCase: ref.watch(updateTaskUseCaseProvider),
    deleteTaskUseCase: ref.watch(deleteTaskUseCaseProvider),
    toggleTaskCompletionUseCase: ref.watch(toggleTaskCompletionUseCaseProvider),
    uuid: ref.watch(uuidProvider),
  );
});

final searchProvider = StateProvider<String>((ref) => '');

final filteredTaskProvider = Provider<List<Task>>((ref) {
  final taskState = ref.watch(taskProvider);
  final query = ref.watch(searchProvider);
  final searchTasks = ref.watch(searchTasksUseCaseProvider);

  return searchTasks(tasks: taskState.tasks, query: query);
});
