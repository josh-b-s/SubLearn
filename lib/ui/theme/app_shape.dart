import 'package:flutter/widgets.dart';

const cardRadius = Radius.circular(30);

/// Corners for row [index] of a lazy list that reads as one rounded card.
BorderRadius cornersAt(int index, int count) => BorderRadius.vertical(
      top: index == 0 ? cardRadius : Radius.zero,
      bottom: index == count - 1 ? cardRadius : Radius.zero,
    );
