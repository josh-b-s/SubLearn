import 'package:flutter/foundation.dart';

/// True on iOS devices. Checks the web flag first because mobile Safari reports iOS.
bool get isIos => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
