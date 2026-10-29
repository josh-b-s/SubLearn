import 'package:flutter/cupertino.dart';

import '../../models/quiz_record.dart';
import '../components/grouped_row.dart';
import '../components/grouped_section.dart';
import '../components/pushed_page.dart';
import '../format_date.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Every question from one quiz with its right answer and a mark for the first try.
class QuizHistoryDetailScreen extends StatelessWidget {
  const QuizHistoryDetailScreen({super.key, required this.record});

  final QuizRecord record;

  @override
  Widget build(BuildContext context) {
    return PushedPage(
      title: formatDay(record.date),
      backLabel: 'Quiz',
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
            child: Semantics(
              header: true,
              child: Text(
                '${record.correctCount} of ${record.items.length} right on the first try',
                style: context.footnote.copyWith(color: context.mutedText),
              ),
            ),
          ),
          GroupedSection(
            dividerIndent: 68,
            children: [
              for (final item in record.items)
                MergeSemantics(
                  child: GroupedRow(
                    leading: Semantics(
                      label: item.correct ? 'Correct' : 'Incorrect',
                      child: Icon(
                        item.correct ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.xmark_circle_fill,
                        color: item.correct ? context.successText : context.destructive,
                      ),
                    ),
                    title: item.prompt,
                    subtitle: 'Answer: ${item.answer}',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
