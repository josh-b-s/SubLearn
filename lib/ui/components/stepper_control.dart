import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';

/// Minus and plus pill, like UIStepper. A null callback greys out that side.
class StepperControl extends StatelessWidget {
  const StepperControl({
    super.key,
    required this.decrementLabel,
    required this.incrementLabel,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String decrementLabel;
  final String incrementLabel;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.resolve(CupertinoColors.tertiarySystemFill),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: 94,
        height: 32,
        child: Row(children: [
          Expanded(child: _Side(icon: CupertinoIcons.minus, label: decrementLabel, onPressed: onDecrement)),
          SizedBox(width: 1 / MediaQuery.devicePixelRatioOf(context), height: 16, child: ColoredBox(color: context.hairline)),
          Expanded(child: _Side(icon: CupertinoIcons.plus, label: incrementLabel, onPressed: onIncrement)),
        ]),
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      enabled: onPressed != null,
      excludeSemantics: true,
      onTap: onPressed,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Icon(
          icon,
          size: 16,
          color: context.resolve(onPressed == null ? CupertinoColors.tertiaryLabel : CupertinoColors.label),
        ),
      ),
    );
  }
}
