import 'package:flutter/cupertino.dart';

/// iOS pull-down menu anchored to its trigger, with a checkmark on the selected option.
class ChoiceMenu<T> extends StatelessWidget {
  const ChoiceMenu({super.key, required this.options, required this.selected, required this.onSelected, required this.builder});

  /// Value to label, in display order.
  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onSelected;

  /// Builds the trigger. Call the given function to open or close the menu.
  final Widget Function(BuildContext context, VoidCallback toggle) builder;

  @override
  Widget build(BuildContext context) {
    return CupertinoMenuAnchor(
      menuChildren: [
        for (final option in options.entries)
          CupertinoMenuItem(
            trailing: option.key == selected ? const Icon(CupertinoIcons.check_mark, size: 18) : null,
            onPressed: () => onSelected(option.key),
            child: Text(option.value),
          ),
      ],
      builder: (context, controller, _) => builder(context, () => controller.isOpen ? controller.close() : controller.open()),
    );
  }
}