import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttersdk_wind/fluttersdk_wind.dart';

import '../../models/word_token.dart';
import '../../services/dictionary/dictionary_breakdown.dart';
import '../../services/vocabulary/saved_word_mastery.dart';
import '../../state/dictionary_provider.dart';
import '../../state/word_clip_provider.dart';
import '../../state/words_provider.dart';
import '../theme/app_text.dart';
import '../theme/wind_classes.dart';
import 'alerts.dart';
import 'app_button.dart';
import 'app_sheet.dart';
import 'character_breakdown.dart';
import 'hairline.dart';
import 'mastery_picker.dart';
import 'replay_clip_button.dart';
import 'section_label.dart';
import 'slow_speech_button.dart';
import 'speak_button.dart';
import 'pinyin.dart';

Future<void> showWordDetailSheet(BuildContext context, WordToken token) {
  return showAppSheet<void>(context, builder: (_) => WordDetailSheet(token: token));
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

    return SafeArea(
      top: false,
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
                      WText(token.text, className: 'text-[56px] font-semibold $inkTextClass'),
                      if (token.pinyin.isNotEmpty)
                        Pinyin(token.pinyin, style: context.title2.copyWith(fontWeight: FontWeight.w600)),
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
            const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Hairline()),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Meanings'),
                    const SizedBox(height: 8),
                    if (token.meanings.isEmpty)
                      const WText('No definition', className: mutedTextClass)
                    else
                      for (final (i, meaning) in token.meanings.indexed)
                        WDiv(
                          className: 'pb-1',
                          child: WText('${i + 1}. $meaning', className: 'text-[17px] $inkTextClass'),
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
              child: AppButton(
                label: saved == null ? 'Save to Vocabulary' : 'Remove from Vocabulary',
                style: saved == null ? AppButtonStyle.filled : AppButtonStyle.destructive,
                onPressed: () => saved == null ? _save(context, ref) : _confirmRemove(context, ref),
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
