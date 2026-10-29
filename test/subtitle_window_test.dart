import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtitle_learn/models/session/pip_line.dart';
import 'package:subtitle_learn/models/word_token.dart';
import 'package:subtitle_learn/ui/subtitle_window/subtitle_window.dart';

void main() {
  const lines = [
    PipLine(id: 0, tokens: [
      WordToken(id: 0, text: '我', pinyin: 'wǒ', meanings: ['I', 'me']),
      WordToken(id: 1, text: '喜欢', pinyin: 'xǐhuān', meanings: ['like'], hidePinyin: true),
    ]),
  ];

  Future<List<String>> pump(WidgetTester tester, {List<PipLine> shown = lines}) async {
    final log = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 320,
          height: 200,
          child: SubtitleWindow(
            lines: shown,
            onGestureStart: (g) => log.add('start ${g.name}'),
            onGestureUpdate: (g, delta) => log.add('update ${g.name}'),
            onGestureEnd: () => log.add('end'),
            onOpenApp: () => log.add('open'),
          ),
        ),
      ),
    ));
    return log;
  }

  testWidgets('shows cards and respects hidden pinyin', (tester) async {
    await pump(tester);

    expect(find.text('我'), findsOneWidget);
    expect(find.text('wǒ'), findsOneWidget);
    expect(find.text('xǐhuān'), findsNothing);
    expect(find.text('like'), findsOneWidget);
  });

  testWidgets('shows a waiting message with no lines', (tester) async {
    await pump(tester, shown: const []);

    expect(find.text('Listening…'), findsOneWidget);
  });

  testWidgets('title bar reports resize, move and open', (tester) async {
    final semantics = tester.ensureSemantics();
    final log = await pump(tester);

    await tester.drag(find.bySemanticsLabel('Resize subtitle window'), const Offset(20, 20));
    await tester.drag(find.bySemanticsLabel('Move subtitle window'), const Offset(20, 20));
    await tester.tap(find.bySemanticsLabel('Open Subtitle Learn'));

    expect(log, containsAllInOrder(['start resize', 'end', 'start move', 'end', 'open']));
    semantics.dispose();
  });
}
