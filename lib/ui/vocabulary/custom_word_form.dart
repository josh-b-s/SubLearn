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
            TextField(
              controller: _word,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Word'),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: _pinyin,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Pinyin (optional)'),
            ),
            TextField(
              controller: _meaning,
              decoration: const InputDecoration(labelText: 'Meaning'),
              onChanged: (_) => setState(() {}),
            ),
            if (message != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Semantics(
                  liveRegion: true,
                  child: Text(message, style: TextStyle(color: context.errorText)),
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
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                FilledButton(onPressed: _isValid ? _add : null, child: const Text('Add')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
