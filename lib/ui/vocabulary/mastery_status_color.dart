import 'package:flutter/material.dart';

import '../../models/mastery_status.dart';

extension MasteryStatusColor on MasteryStatus {
  Color get color => switch (this) {
        MasteryStatus.newWord => Colors.grey,
        MasteryStatus.learning => Colors.orange,
        MasteryStatus.mastered => Colors.green,
      };
}
