import 'package:flutter/cupertino.dart';

import '../../models/session/session_entry.dart';
import '../components/progress_bar.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// One most-heard word with a bar scaled against the highest count.
class SessionTopWordRow extends StatelessWidget {
  const SessionTopWordRow({super.key, required this.entry, required this.maxCount});

  final SessionEntry entry;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${entry.token.text}, heard ${entry.count} times',
      child: ExcludeSemantics(
        child: Row(spacing: 12, children: [
          SizedBox(
            width: 72,
            child: Text(entry.token.text, style: context.title2.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: ProgressBar(value: entry.count / (maxCount < 1 ? 1 : maxCount), height: 8),
          ),
          SizedBox(
            width: 32,
            child: Text('${entry.count}', textAlign: TextAlign.end, style: context.subhead.copyWith(color: context.mutedText)),
          ),
        ]),
      ),
    );
  }
}
