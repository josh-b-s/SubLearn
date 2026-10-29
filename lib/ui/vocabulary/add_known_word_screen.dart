import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/dictionary_match.dart';
import '../../services/learning/mastery.dart';
import '../../services/vocabulary/saved_word_mastery.dart';
import '../../state/words_provider.dart';
import '../components/app_button.dart';
import '../components/icon_action.dart';
import '../components/mastery_picker.dart';
import '../components/pushed_page.dart';
import '../dictionary/dictionary_results_list.dart';
import '../dictionary/search_field.dart';
import '../theme/app_colors.dart';
import '../theme/app_shape.dart';
import '../theme/app_text.dart';
import 'custom_word_form.dart';

/// Pick any dictionary word and add it to Vocabulary at the level you already know it.
class AddKnownWordScreen extends ConsumerStatefulWidget {
  const AddKnownWordScreen({super.key});

  @override
  ConsumerState<AddKnownWordScreen> createState() => _AddKnownWordScreenState();
}

class _AddKnownWordScreenState extends ConsumerState<AddKnownWordScreen> {
  String _query = '';
  DictionaryMatch? _selected;
  double _progress = 3;

  void _select(DictionaryMatch match) {
    final existing = ref.read(wordsProvider.notifier).find(match.word);
    setState(() {
      _selected = match;
      _progress = existing?.masteryScore ?? 3;
    });
  }

  void _add(DictionaryMatch match) {
    ref.read(wordsProvider.notifier).addKnown(match, _progress);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return PushedPage(
      title: 'Add Known Word',
      backLabel: 'Vocabulary',
      safeBottom: false,
      child: Column(
        children: [
          SearchField(onChanged: (v) => setState(() => _query = v)),
          Expanded(
            child: DictionaryResultsList(
              query: _query,
              selectedWord: selected?.word,
              onSelect: _select,
              onAddCustom: () => showCustomWordForm(context, initialWord: _query),
            ),
          ),
          if (selected != null) _gradePanel(selected),
        ],
      ),
    );
  }

  Widget _gradePanel(DictionaryMatch match) {
    final exists = ref.watch(savedWordSetProvider).contains(match.word);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: cardRadius),
      child: ColoredBox(
        color: context.cardBackground,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(match.word, style: context.title2.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(match.entry.pinyin, style: TextStyle(color: context.accent)),
                    const Spacer(),
                    IconAction(
                      label: 'Clear selection',
                      icon: CupertinoIcons.xmark_circle_fill,
                      onPressed: () => setState(() => _selected = null),
                    ),
                  ],
                ),
                MasteryPicker(progress: _progress, onChanged: (v) => setState(() => _progress = v)),
                const SizedBox(height: 8),
                Semantics(
                  hint: 'Saves ${match.word} at ${Mastery.summaryForScore(_progress).toLowerCase()}',
                  child: AppButton(
                    label: exists ? 'Update Level' : 'Add to Vocabulary',
                    onPressed: () => _add(match),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
