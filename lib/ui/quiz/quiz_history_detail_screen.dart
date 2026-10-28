import 'package:flutter/material.dart';

import '../../models/quiz_record.dart';
import '../format_date.dart';
import '../theme/app_colors.dart';

/// Every question from one quiz with its right answer and a mark for the first try.
class QuizHistoryDetailScreen extends StatelessWidget {
  const QuizHistoryDetailScreen({super.key, required this.record});

  final QuizRecord record;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(formatDay(record.date))),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Semantics(
              header: true,
              child: Text(
                '${record.correctCount} of ${record.items.length} right on the first try',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: context.mutedText),
              ),
            ),
          ),
          for (final item in record.items)
            MergeSemantics(
              child: ListTile(
                leading: Semantics(
                  label: item.correct ? 'Correct' : 'Incorrect',
                  child: Icon(item.correct ? Icons.check_circle : Icons.cancel, color: item.correct ? Colors.green : Colors.red),
                ),
                title: Text(item.prompt, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Answer: ${item.answer}'),
              ),
            ),
        ],
      ),
    );
  }
}
