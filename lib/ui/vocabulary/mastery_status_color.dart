import 'package:flutter/cupertino.dart';

import '../../models/mastery_status.dart';

/// Dynamic colours, so resolve them with `context.resolve`.
extension MasteryStatusColor on MasteryStatus {
  CupertinoDynamicColor get color => switch (this) {
        MasteryStatus.newWord => CupertinoColors.systemGrey,
        MasteryStatus.learning => CupertinoColors.systemOrange,
        MasteryStatus.mastered => CupertinoColors.systemGreen,
      };
}
