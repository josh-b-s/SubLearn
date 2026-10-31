import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

/// Bottom sheet with rounded top corners and a grabber. Drag it down, or tap outside, to dismiss.
Future<T?> showAppSheet<T>(BuildContext context, {required WidgetBuilder builder}) {
  return showCupertinoModalPopup<T>(
    context: context,
    builder: (_) => CupertinoUserInterfaceLevel(
      data: CupertinoUserInterfaceLevelData.elevated,
      child: _Sheet(builder: builder),
    ),
  );
}

class _Sheet extends StatefulWidget {
  const _Sheet({required this.builder});

  final WidgetBuilder builder;

  @override
  State<_Sheet> createState() => _SheetState();
}

class _SheetState extends State<_Sheet> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(vsync: this)
    ..addListener(() => setState(() => _dy = _tween.evaluate(_anim)));

  Tween<double> _tween = Tween(begin: 0, end: 0);
  double _dy = 0;

  /// Past this fraction of the sheet's height, or a fast flick, a release dismisses it.
  static const _dismissFraction = 0.25;
  static const _dismissVelocity = 700.0;

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _animateTo(double target, {VoidCallback? onDone}) {
    _anim.duration = MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 200);
    _tween = Tween(begin: _dy, end: target);
    _anim.forward(from: 0).whenComplete(() {
      if (mounted) onDone?.call();
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _anim.stop();
    final next = _dy + details.delta.dy;
    setState(() => _dy = next < 0 ? 0 : next);
  }

  void _onDragEnd(DragEndDetails details) {
    final height = context.size?.height ?? 0;
    final flicked = (details.primaryVelocity ?? 0) > _dismissVelocity;
    if (flicked || _dy > height * _dismissFraction) {
      _animateTo(height, onDone: () => Navigator.of(context).maybePop());
    } else {
      _animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Transform.translate(
      offset: Offset(0, _dy),
      // Scrolling content wins the gesture inside it, so this only drags from the grabber, header and button.
      child: GestureDetector(
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: DefaultTextStyle(
          style: CupertinoTheme.of(context).textTheme.textStyle,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: media.size.height - media.padding.top - 10),
            child: WDiv(
              className: 'rounded-t-3xl bg-night-50 dark:bg-night-950',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 20,
                    width: double.infinity,
                    child: Center(child: WDiv(className: 'w-9 h-[5px] rounded-full bg-night-400/40')),
                  ),
                  Flexible(child: Builder(builder: widget.builder)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
