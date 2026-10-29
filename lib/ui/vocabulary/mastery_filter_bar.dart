import 'package:flutter/cupertino.dart';

import '../../models/mastery_filter.dart';
import '../components/pill_chip.dart';

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
          PillChip(label: 'All', selected: selection == null, onTap: () => onSelection(null)),
          for (final filter in MasteryFilter.values) ...[
            const SizedBox(width: 8),
            PillChip(label: filter.label, selected: selection == filter, onTap: () => onSelection(filter)),
          ],
          const SizedBox(width: 8),
          PillChip(label: 'Due today', selected: dueOnly, onTap: () => onDueOnly(!dueOnly)),
        ],
      ),
    );
  }
}
