import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/word_token.dart';
import '../../services/dictionary/dictionary_breakdown.dart';
import '../../services/vocabulary/saved_word_mastery.dart';
import '../../state/dictionary_provider.dart';
import '../../state/word_clip_provider.dart';
import '../../state/words_provider.dart';
import '../theme/app_colors.dart';
import 'alerts.dart';
import 'character_breakdown.dart';
import 'mastery_picker.dart';
import 'replay_clip_button.dart';
import 'section_label.dart';
import 'slow_speech_button.dart';
import 'speak_button.dart';

Future<void> showWordDetailSheet(BuildContext context, WordToken token) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => WordDetailSheet(token: token),
  );
}

/// Bottom sheet shown when a word card is tapped.
class WordDetailSheet extends ConsumerWidget {
  const WordDetailSheet({super.key, required this.token});

  final WordToken token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(wordsProvider.select((words) {
      for (final w in words) {
        if (w.word == token.text) return w;
      }
      return null;
    }));
    final glosses = ref.watch(dictionaryProvider).valueOrNull?.breakdown(token.text) ?? const [];
    final hasClip = ref.watch(wordClipProvider(token.text)).valueOrNull ?? false;
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Text(token.text, style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold)),
                      if (token.pinyin.isNotEmpty)
                        Text(token.pinyin, style: text.headlineSmall?.copyWith(color: context.accent)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 12,
                        children: [
                          SpeakButton(word: token.text, iconSize: 28),
                          if (hasClip) ReplayClipButton(word: token.text),
                        ],
                      ),
                    ],
                  ),
                ),
                const SlowSpeechButton(),
              ],
            ),
            const Divider(height: 28),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('MEANINGS'),
                    const SizedBox(height: 8),
                    if (token.meanings.isEmpty)
                      Text('No definition', style: TextStyle(color: context.mutedText))
                    else
                      for (final (i, meaning) in token.meanings.indexed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('${i + 1}. $meaning', style: text.titleMedium),
                        ),
                    if (glosses.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      CharacterBreakdown(glosses: glosses),
                    ],
                    if (saved != null) ...[
                      const SizedBox(height: 20),
                      MasteryPicker(
                        progress: saved.masteryScore,
                        onChanged: (v) => ref.read(wordsProvider.notifier).setProgress(token.text, v),
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            Semantics(
              hint: saved == null ? 'Adds this word to your quiz' : 'Deletes this word and its progress',
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: saved == null ? null : FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => saved == null ? _save(context, ref) : _confirmRemove(context, ref),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(saved == null ? 'Save to Vocabulary' : 'Remove from Vocabulary'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save(BuildContext context, WidgetRef ref) {
    ref.read(wordsProvider.notifier).toggleSaved(token);
    Navigator.pop(context);
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmAlert(
      context,
      title: 'Remove ${token.text}?',
      message: 'Its level and review history are deleted too.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (confirmed && context.mounted) {
      ref.read(wordsProvider.notifier).toggleSaved(token);
      Navigator.pop(context);
    }
  }
}
