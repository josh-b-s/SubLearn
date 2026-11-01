import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../../services/learning/mastery.dart';
import '../theme/app_colors.dart';
import '../theme/wind_classes.dart';

/// Full-width slider from level 1 to mastered, with a notch and label at each level.
/// Values snap to [Mastery.scoreStep]. [onChanged] fires while dragging and [onChangeEnd] on release.
class MasterySlider extends StatelessWidget {
  const MasterySlider({super.key, required this.value, required this.onChanged, required this.onChangeEnd});

  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  static const _thumb = 28.0;
  static const _trackHeight = 10.0;
  static const _min = 1.0;
  static const _labels = {1: 'New', 2: '2', 3: '3', Mastery.masteredLevel: 'Mastered'};

  static final _max = Mastery.masteredLevel.toDouble();

  double _snap(double x, double width) {
    final fraction = ((x - _thumb / 2) / (width - _thumb)).clamp(0.0, 1.0);
    final raw = _min + fraction * (_max - _min);
    return (_min + ((raw - _min) / Mastery.scoreStep).round() * Mastery.scoreStep).clamp(_min, _max).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final shown = value.clamp(_min, _max).toDouble();
    return Semantics(
      slider: true,
      label: 'Mastery',
      value: Mastery.summaryForScore(shown),
      increasedValue: Mastery.summaryForScore(shown + Mastery.scoreStep),
      decreasedValue: Mastery.summaryForScore(shown - Mastery.scoreStep),
      onIncrease: shown < _max ? () => onChangeEnd(shown + Mastery.scoreStep) : null,
      onDecrease: shown > _min ? () => onChangeEnd(shown - Mastery.scoreStep) : null,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            double xOf(double score) => _thumb / 2 + (score - _min) / (_max - _min) * (width - _thumb);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) => onChanged(_snap(d.localPosition.dx, width)),
              onTapUp: (d) => onChangeEnd(_snap(d.localPosition.dx, width)),
              onHorizontalDragUpdate: (d) => onChanged(_snap(d.localPosition.dx, width)),
              onHorizontalDragEnd: (_) => onChangeEnd(shown),
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      bottom: 28,
                      child: CustomPaint(
                        painter: _TrackPainter(
                          fraction: (shown - _min) / (_max - _min),
                          notches: [for (var level = 1; level <= Mastery.masteredLevel; level++) (level - _min) / (_max - _min)],
                          track: context.chipBackground,
                          fill: context.accent,
                          notch: context.mutedText,
                          thumb: context.resolve(CupertinoColors.white),
                          thumbDiameter: _thumb,
                          trackHeight: _trackHeight,
                        ),
                      ),
                    ),
                    for (final entry in _labels.entries)
                      Positioned(
                        left: xOf(entry.key.toDouble()),
                        bottom: 0,
                        child: FractionalTranslation(
                          translation: const Offset(-0.5, 0),
                          child: WText(
                            entry.value,
                            className: Mastery.stateForScore(shown).level == entry.key
                                ? 'text-[13px] font-semibold $inkTextClass'
                                : 'text-[13px] $mutedTextClass',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TrackPainter extends CustomPainter {
  const _TrackPainter({
    required this.fraction,
    required this.notches,
    required this.track,
    required this.fill,
    required this.notch,
    required this.thumb,
    required this.thumbDiameter,
    required this.trackHeight,
  });

  final double fraction;
  final List<double> notches;
  final Color track;
  final Color fill;
  final Color notch;
  final Color thumb;
  final double thumbDiameter;
  final double trackHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = thumbDiameter / 2;
    final usable = size.width - thumbDiameter;
    final cy = size.height / 2;
    final trackRect = RRect.fromLTRBR(inset, cy - trackHeight / 2, size.width - inset, cy + trackHeight / 2, Radius.circular(trackHeight / 2));
    canvas.drawRRect(trackRect, Paint()..color = track);

    final thumbX = inset + fraction * usable;
    canvas.save();
    canvas.clipRRect(trackRect);
    canvas.drawRect(Rect.fromLTRB(inset, cy - trackHeight / 2, thumbX, cy + trackHeight / 2), Paint()..color = fill);
    canvas.restore();

    for (final n in notches) {
      final x = inset + n * usable;
      canvas.drawCircle(Offset(x, cy), 2.5, Paint()..color = x <= thumbX ? thumb.withValues(alpha: 0.9) : notch.withValues(alpha: 0.6));
    }

    canvas.drawShadow(Path()..addOval(Rect.fromCircle(center: Offset(thumbX, cy), radius: inset)), const Color(0xFF000000), 3, true);
    canvas.drawCircle(Offset(thumbX, cy), inset, Paint()..color = thumb);
    canvas.drawCircle(Offset(thumbX, cy), inset - 1, Paint()..color = fill..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_TrackPainter old) =>
      old.fraction != fraction || old.track != track || old.fill != fill || old.notch != notch || old.thumb != thumb;
}
