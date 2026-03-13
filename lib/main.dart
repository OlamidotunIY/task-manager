import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/constants/hive_constants.dart';
import 'features/tasks/data/models/task_model.dart';
import 'features/tasks/data/models/task_model_adapter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(HiveConstants.taskModelTypeId)) {
    Hive.registerAdapter(TaskModelAdapter());
  }
  await Hive.openBox<TaskModel>(HiveConstants.tasksBox);

  runApp(const ProviderScope(child: TaskManagerApp()));
}
