import 'package:go_router/go_router.dart';

import '../../features/tasks/domain/entities/task.dart';
import '../../features/tasks/presentation/screens/add_edit_task_screen.dart';
import '../../features/tasks/presentation/screens/task_list_screen.dart';

abstract final class AppRoutes {
  static const home = 'home';
  static const taskListPath = '/';
  static const addTask = 'add-task';
  static const addTaskPath = '/tasks/new';
  static const editTask = 'edit-task';
  static const editTaskPath = '/tasks/edit';

  const AppRoutes._();
}

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.taskListPath,
    routes: [
      GoRoute(
        path: AppRoutes.taskListPath,
        name: AppRoutes.home,
        builder: (context, state) => const TaskListScreen(),
      ),
      GoRoute(
        path: AppRoutes.addTaskPath,
        name: AppRoutes.addTask,
        builder: (context, state) => const AddEditTaskScreen(),
      ),
      GoRoute(
        path: AppRoutes.editTaskPath,
        name: AppRoutes.editTask,
        builder: (context, state) {
          final task = state.extra;

          if (task is! Task) {
            return const TaskListScreen();
          }

          return AddEditTaskScreen(task: task);
        },
      ),
    ],
  );

  const AppRouter._();
}
