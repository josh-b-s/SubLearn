import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/dictionary_provider.dart';
import '../../state/session_transcript_provider.dart';
import '../../state/words_provider.dart';
import '../components/empty_state.dart';
import '../components/word_card.dart';
import '../components/word_detail_sheet.dart';
import '../theme/app_colors.dart';

/// What the latest session heard, line by line. Tap a word to look it up or save it.
class TranscriptScreen extends ConsumerWidget {
  const TranscriptScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(sessionTranscriptProvider)?.lines ?? const <String>[];
    final dictionary = ref.watch(dictionaryProvider).valueOrNull;
    final saved = ref.watch(savedWordSetProvider);
    ref.listen(wordsProvider.select((w) => w.length), (_, __) => HapticFeedback.selectionClick());

    return Scaffold(
      backgroundColor: context.groupedBackground,
      appBar: AppBar(
        title: const Text('Transcript'),
        automaticallyImplyLeading: false,
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
      ),
      body: lines.isEmpty
          ? const EmptyState(
              icon: Icons.notes,
              title: 'No transcript yet',
              description: 'Lines appear here as they are heard.',
            )
          : dictionary == null
              ? const Center(child: CircularProgressIndicator.adaptive())
              : ListView.separated(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: lines.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 24),
                  // Reversed so the newest line sits at the bottom and the list opens there.
                  itemBuilder: (context, i) {
                    final index = lines.length - 1 - i;
                    return Semantics(
                      container: true,
                      label: 'Line ${index + 1}',
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final token in dictionary.tokens(lines[index]))
                            WordCard(
                              key: ValueKey(token.id),
                              token: token,
                              isSaved: saved.contains(token.text),
                              onTap: () => showWordDetailSheet(context, token),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
