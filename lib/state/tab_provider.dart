import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom navigation tabs, in display order.
enum AppTab { screenShare, translate, vocabulary, quiz, settings }

/// Lives in a provider so other screens can switch tabs, such as a review after a screen share.
class TabNotifier extends Notifier<AppTab> {
  @override
  AppTab build() => AppTab.translate;

  void select(AppTab tab) => state = tab;
}

final tabProvider = NotifierProvider<TabNotifier, AppTab>(TabNotifier.new);
