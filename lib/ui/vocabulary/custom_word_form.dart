import 'package:flutter/cupertino.dart' show CupertinoButton, CupertinoIcons, CupertinoTextField;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/dictionary/han.dart';
import '../../state/custom_dictionary_provider.dart';
import '../../state/dictionary_provider.dart';
import '../../services/vocabulary/custom_meanings.dart';
import '../theme/app_colors.dart';

Future<void> showCustomWordForm(BuildContext context, {String initialWord = ''}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => CustomWordForm(initialWord: initialWord.runes.where(isHanRune).map(String.fromCharCode).join()),
  );
}

/// Form for adding a word to the user's own dictionary.
class CustomWordForm extends ConsumerStatefulWidget {
  const CustomWordForm({super.key, this.initialWord = ''});

  final String initialWord;

  @override
  ConsumerState<CustomWordForm> createState() => _CustomWordFormState();
}

class _CustomWordFormState extends ConsumerState<CustomWordForm> {
  late final _word = TextEditingController(text: widget.initialWord);
  final _pinyin = TextEditingController();
  final _meaning = TextEditingController();

  @override
  void dispose() {
    _word.dispose();
    _pinyin.dispose();
    _meaning.dispose();
    super.dispose();
  }

  String get _cleanWord => _word.text.trim();
  bool get _isValid => isAllHan(_cleanWord) && parseMeanings(_meaning.text).isNotEmpty;

  /// Shown as soon as an entry is wrong, so a disabled Add button is never a mystery.
  String? get _validationMessage {
    if (_cleanWord.isNotEmpty && !isAllHan(_cleanWord)) return 'The word can only use Chinese characters.';
    if (_meaning.text.isNotEmpty && parseMeanings(_meaning.text).isEmpty) return 'Enter at least one meaning.';
    return null;
  }

  void _add() {
    final typed = _pinyin.text.replaceAll(' ', '').trim();
    final dictionary = ref.read(dictionaryProvider).valueOrNull;
    final pinyin = typed.isNotEmpty ? typed : (dictionary?.fallbackPinyin(_cleanWord) ?? '');
    ref.read(customDictionaryProvider.notifier).add(word: _cleanWord, pinyin: pinyin, meaning: _meaning.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final message = _validationMessage;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Custom word', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: context.cardBackground, borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Semantics(
                    hint: 'Chinese characters only',
                    child: CupertinoTextField(
                      controller: _word,
                      placeholder: 'Word',
                      autocorrect: false,
                      decoration: null,
                      padding: const EdgeInsets.all(14),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const Divider(height: 1, thickness: 0.5, indent: 14),
                  Semantics(
                    hint: 'Filled in for you if left blank',
                    child: CupertinoTextField(
                      controller: _pinyin,
                      placeholder: 'Pinyin (optional)',
                      autocorrect: false,
                      decoration: null,
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                  const Divider(height: 1, thickness: 0.5, indent: 14),
                  Semantics(
                    hint: 'Separate several meanings with a slash',
                    child: CupertinoTextField(
                      controller: _meaning,
                      placeholder: 'Meaning',
                      decoration: null,
                      padding: const EdgeInsets.all(14),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
            if (message != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Semantics(
                  liveRegion: true,
                  label: 'Error: $message',
                  excludeSemantics: true,
                  child: Row(spacing: 6, children: [
                    Icon(CupertinoIcons.exclamationmark_triangle, size: 16, color: context.errorText),
                    Expanded(child: Text(message, style: TextStyle(color: context.errorText, fontSize: 13))),
                  ]),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Chinese characters only. Separate several meanings with a slash. Pinyin is filled in for you if you leave it blank. Adding an existing word replaces it.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.mutedText),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                Semantics(
                  hint: _isValid ? '' : 'Enter a Chinese word and a meaning first',
                  child: FilledButton(onPressed: _isValid ? _add : null, child: const Text('Add')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
