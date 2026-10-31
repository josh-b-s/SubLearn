import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../../models/session/session_entry.dart';
import '../components/progress_bar.dart';
import '../theme/wind_classes.dart';

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
        child: WDiv(
          className: 'flex flex-row items-center gap-3 w-full',
          children: [
            WDiv(className: 'w-[72px]', child: WText(entry.token.text, className: 'text-[22px] font-bold truncate $inkTextClass')),
            Expanded(child: ProgressBar(value: entry.count / (maxCount < 1 ? 1 : maxCount), height: 8)),
            WDiv(className: 'w-8', child: WText('${entry.count}', className: 'text-[15px] text-right $mutedTextClass')),
          ],
        ),
      ),
    );
  }
}
