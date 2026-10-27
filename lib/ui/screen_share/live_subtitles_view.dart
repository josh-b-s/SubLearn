import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/screen_share_controller.dart';
import '../../state/settings_provider.dart';
import '../../state/words_provider.dart';
import '../components/word_card.dart';
import '../components/word_detail_sheet.dart';
import '../theme/app_colors.dart';
import 'transcript_screen.dart';

/// Word cards for the line being heard, with controls for the running session.
class LiveSubtitlesView extends ConsumerWidget {
  const LiveSubtitlesView({super.key, required this.state});

  final ScreenShareState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(screenShareControllerProvider.notifier);
    final saved = ref.watch(savedWordSetProvider);
    final hideLearned = ref.watch(settingsProvider.select((s) => s.hideLearnedInSubtitles));

    return Column(
      children: [
        Expanded(
          child: state.lines.isEmpty
              ? Center(
                  child: Text('Listening for Mandarin…', style: TextStyle(color: context.mutedText)),
                )
              : ListView(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // reverse keeps the newest line at the bottom as lines arrive.
                    for (final line in state.lines.reversed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (final token in line.tokens)
                              WordCard(
                                key: ValueKey('${line.id}-${token.id}'),
                                token: token,
                                isSaved: saved.contains(token.text),
                                onTap: () => showWordDetailSheet(context, token),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        if (state.notice != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(state.notice!, style: TextStyle(color: context.warningText)),
          ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(mainAxisSize: MainAxisSize.min, spacing: 8, children: [
              Row(children: [
                FilterChip(
                  avatar: const Icon(Icons.visibility_off, size: 18),
                  label: const Text('Hide learned'),
                  selected: hideLearned,
                  onSelected: ref.read(settingsProvider.notifier).setHideLearnedInSubtitles,
                  tooltip: 'Hides the pinyin and meaning of words you already know, from the next line on',
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Transcript',
                  icon: const Icon(Icons.subject),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const TranscriptScreen()),
                  ),
                ),
                IconButton(
                  tooltip: 'Show floating window',
                  icon: Icon(state.pipActive ? Icons.picture_in_picture : Icons.picture_in_picture_alt_outlined),
                  onPressed: controller.presentPip,
                ),
              ]),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: controller.stop,
                  icon: const Icon(Icons.stop),
                  label: const Padding(padding: EdgeInsets.all(8), child: Text('Stop')),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
