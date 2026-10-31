import 'package:flutter/widgets.dart';

/// Large surfaces: grouped lists, input cards, sheets.
const cardRadius = Radius.circular(22);

/// Buttons, answer rows and other controls.
const controlRadius = Radius.circular(14);

/// Corners for row [index] of a lazy list that reads as one rounded card.
BorderRadius cornersAt(int index, int count) => BorderRadius.vertical(
      top: index == 0 ? cardRadius : Radius.zero,
      bottom: index == count - 1 ? cardRadius : Radius.zero,
    );
