import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/task.dart';
import '../providers/task_providers.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  const AddEditTaskScreen({super.key, this.task});

  final Task? task;

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  var _isSaving = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Task' : 'Add Task')),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  24,
                  12,
                  24,
                  32 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditing
                            ? 'Refine the task details and save the update.'
                            : 'Capture a title and a short description to keep work organized.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Task details',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _titleController,
                                  focusNode: _titleFocusNode,
                                  autofocus: !_isEditing,
                                  textInputAction: TextInputAction.next,
                                  maxLength: 80,
                                  decoration: const InputDecoration(
                                    labelText: 'Title',
                                    hintText: 'Prepare weekly sprint report',
                                  ),
                                  onFieldSubmitted: (_) {
                                    _descriptionFocusNode.requestFocus();
                                  },
                                  validator: (value) {
                                    final trimmedValue = value?.trim() ?? '';

                                    if (trimmedValue.isEmpty) {
                                      return 'Title is required.';
                                    }

                                    if (trimmedValue.length < 3) {
                                      return 'Title must be at least 3 characters.';
                                    }

                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _descriptionController,
                                  focusNode: _descriptionFocusNode,
                                  minLines: 4,
                                  maxLines: 6,
                                  maxLength: 240,
                                  textInputAction: TextInputAction.done,
                                  decoration: const InputDecoration(
                                    labelText: 'Description',
                                    hintText:
                                        'Add useful context, notes, or acceptance criteria.',
                                    alignLabelWithHint: true,
                                  ),
                                  onFieldSubmitted: (_) => _submit(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton(
                            onPressed: _isSaving ? null : () => context.pop(),
                            child: const Text('Cancel'),
                          ),
                          FilledButton.icon(
                            onPressed: _isSaving ? null : _submit,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    _isEditing
                                        ? Icons.save_rounded
                                        : Icons.add_task_rounded,
                                  ),
                            label: Text(
                              _isEditing ? 'Save Changes' : 'Create Task',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final notifier = ref.read(taskProvider.notifier);

      if (_isEditing) {
        await notifier.updateTask(
          task: widget.task!,
          title: _titleController.text,
          description: _descriptionController.text,
        );
      } else {
        await notifier.addTask(
          title: _titleController.text,
          description: _descriptionController.text,
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Task updated successfully.'
                  : 'Task created successfully.',
            ),
          ),
        );

      context.pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
          ),
        );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });
    }
  }
}
