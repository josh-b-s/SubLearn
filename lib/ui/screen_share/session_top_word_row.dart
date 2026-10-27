import 'package:flutter/material.dart';

import '../../models/session/session_entry.dart';
import '../theme/app_colors.dart';

/// One most-heard word with a bar scaled against the highest count.
class SessionTopWordRow extends StatelessWidget {
  const SessionTopWordRow({super.key, required this.entry, required this.maxCount});

  final SessionEntry entry;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      label: '${entry.token.text}, heard ${entry.count} times',
      child: ExcludeSemantics(
        child: Row(spacing: 12, children: [
          SizedBox(
            width: 72,
            child: Text(entry.token.text, style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: entry.count / (maxCount < 1 ? 1 : maxCount),
                minHeight: 8,
                backgroundColor: context.chipBackground,
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text('${entry.count}', textAlign: TextAlign.end, style: text.bodyMedium?.copyWith(color: context.mutedText)),
          ),
        ]),
      ),
    );
  }
}
