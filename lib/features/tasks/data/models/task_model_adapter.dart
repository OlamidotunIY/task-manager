import 'package:hive/hive.dart';

import '../../../../core/constants/hive_constants.dart';
import 'task_model.dart';

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = HiveConstants.taskModelTypeId;

  @override
  TaskModel read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var index = 0; index < fieldCount; index++)
        reader.readByte(): reader.read(),
    };

    return TaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      isCompleted: fields[3] as bool,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }
}
