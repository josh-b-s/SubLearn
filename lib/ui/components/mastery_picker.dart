import 'package:flutter/cupertino.dart';

import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../../services/learning/mastery.dart';
import '../theme/wind_classes.dart';
import 'section_label.dart';

/// Manual mastery control. The slider moves in half levels, so 2.5 means level 2 with one pass done.
class MasteryPicker extends StatefulWidget {
  const MasteryPicker({super.key, required this.progress, required this.onChanged});

  final double progress;
  final ValueChanged<double> onChanged;

  @override
  State<MasteryPicker> createState() => _MasteryPickerState();
}

class _MasteryPickerState extends State<MasteryPicker> {
  /// A drag only saves on release, so passing the mastered end doesn't stamp a mastered date on the way.
  double? _draft;

  double get _shown => _draft ?? widget.progress;

  String get _caption => switch (Mastery.stateForScore(_shown).level) {
        1 => 'Subtitles show its meaning and pinyin.',
        2 => 'Subtitles hide its meaning.',
        3 => 'Subtitles hide its meaning and pinyin.',
        _ => 'Hidden in subtitles and never quizzed.',
      };

  @override
  Widget build(BuildContext context) {
    final summary = Mastery.summaryForScore(_shown);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionLabel('Mastery'),
            ExcludeSemantics(child: WText(summary, className: 'text-[17px] font-semibold $inkTextClass')),
          ],
        ),
        Semantics(
          label: 'Mastery',
          value: summary,
          hint: _caption,
          child: CupertinoSlider(
            value: _shown.clamp(1, Mastery.masteredLevel.toDouble()).toDouble(),
            min: 1,
            max: Mastery.masteredLevel.toDouble(),
            divisions: ((Mastery.masteredLevel - 1) / Mastery.scoreStep).round(),
            onChanged: (v) => setState(() => _draft = v),
            onChangeEnd: (v) {
              setState(() => _draft = null);
              widget.onChanged(v);
            },
          ),
        ),
        ExcludeSemantics(
          child: WText(_caption, className: 'text-[13px] $mutedTextClass'),
        ),
      ],
    );
  }
}
