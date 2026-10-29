import 'package:flutter/cupertino.dart';

/// iOS segmented control. Pass a null [onChanged] to lock it.
class SegmentedPicker<T extends Object> extends StatelessWidget {
  const SegmentedPicker({super.key, required this.labels, required this.selected, required this.onChanged});

  final Map<T, String> labels;
  final T selected;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final control = SizedBox(
      width: double.infinity,
      child: CupertinoSlidingSegmentedControl<T>(
        groupValue: selected,
        onValueChanged: (value) {
          if (value != null) onChanged?.call(value);
        },
        children: {
          for (final entry in labels.entries)
            entry.key: Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(entry.value)),
        },
      ),
    );
    return onChanged == null ? Opacity(opacity: 0.5, child: IgnorePointer(child: control)) : control;
  }
}
