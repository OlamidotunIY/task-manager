import '../entities/task.dart';

class SearchTasksUseCase {
  const SearchTasksUseCase();

  List<Task> call({required List<Task> tasks, required String query}) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return List<Task>.unmodifiable(tasks);
    }

    return tasks
        .where((task) => task.title.toLowerCase().contains(normalizedQuery))
        .toList(growable: false);
  }
}
