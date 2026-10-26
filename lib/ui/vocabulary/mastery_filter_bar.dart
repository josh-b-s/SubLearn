import 'package:flutter/material.dart';

import '../../models/mastery_filter.dart';

/// Chip row: All plus one chip per mastery level group (null means All), then a Due today toggle that combines with them.
class MasteryFilterBar extends StatelessWidget {
  const MasteryFilterBar({
    super.key,
    required this.selection,
    required this.dueOnly,
    required this.onSelection,
    required this.onDueOnly,
  });

  final MasteryFilter? selection;
  final bool dueOnly;
  final ValueChanged<MasteryFilter?> onSelection;
  final ValueChanged<bool> onDueOnly;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ChoiceChip(label: const Text('All'), selected: selection == null, onSelected: (_) => onSelection(null)),
          for (final filter in MasteryFilter.values) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(filter.label),
              selected: selection == filter,
              onSelected: (_) => onSelection(filter),
            ),
          ],
          const SizedBox(width: 8),
          FilterChip(label: const Text('Due today'), selected: dueOnly, onSelected: onDueOnly),
        ],
      ),
    );
  }
}
