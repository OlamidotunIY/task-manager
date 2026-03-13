import 'package:flutter/material.dart';

class TaskSearchBar extends StatefulWidget {
  const TaskSearchBar({
    super.key,
    required this.value,
    required this.onChanged,
    this.onClear,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  @override
  State<TaskSearchBar> createState() => _TaskSearchBarState();
}

class _TaskSearchBarState extends State<TaskSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant TaskSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SearchBar(
      controller: _controller,
      hintText: 'Search tasks by title',
      leading: const Icon(Icons.search_rounded),
      trailing: [
        if (_controller.text.isNotEmpty)
          IconButton(
            onPressed: () {
              _controller.clear();
              widget.onChanged('');
              widget.onClear?.call();
              setState(() {});
            },
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Clear search',
          ),
      ],
      elevation: const WidgetStatePropertyAll<double>(0),
      backgroundColor: WidgetStatePropertyAll<Color>(theme.cardTheme.color!),
      padding: const WidgetStatePropertyAll<EdgeInsets>(
        EdgeInsets.symmetric(horizontal: 16),
      ),
      onChanged: (value) {
        widget.onChanged(value);
        setState(() {});
      },
    );
  }
}
