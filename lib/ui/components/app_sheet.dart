import 'package:flutter/cupertino.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';


/// Bottom sheet with rounded top corners and a grabber. Dismiss it with a tap outside or a swipe down on the grabber.
Future<T?> showAppSheet<T>(BuildContext context, {required WidgetBuilder builder}) {
  return showCupertinoModalPopup<T>(
    context: context,
    builder: (_) => CupertinoUserInterfaceLevel(
      data: CupertinoUserInterfaceLevelData.elevated,
      child: _Sheet(builder: builder),
    ),
  );
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return DefaultTextStyle(
      style: CupertinoTheme.of(context).textTheme.textStyle,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height - media.padding.top - 10),
        child: WDiv(
          className: 'rounded-t-3xl bg-night-50 dark:bg-night-950',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragEnd: (details) {
                  if ((details.primaryVelocity ?? 0) > 600) Navigator.of(context).maybePop();
                },
                child: SizedBox(
                  height: 20,
                  width: double.infinity,
                  child: Center(
                    child: const WDiv(className: 'w-9 h-[5px] rounded-full bg-night-400/40'),
                  ),
                ),
              ),
              Flexible(child: Builder(builder: builder)),
            ],
          ),
        ),
      ),
    );
  }
}
