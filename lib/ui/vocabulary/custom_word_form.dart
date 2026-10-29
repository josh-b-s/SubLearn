import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/dictionary/han.dart';
import '../../state/custom_dictionary_provider.dart';
import '../../state/dictionary_provider.dart';
import '../../services/vocabulary/custom_meanings.dart';
import '../components/app_sheet.dart';
import '../components/hairline.dart';
import '../components/nav_text_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_shape.dart';
import '../theme/app_text.dart';

Future<void> showCustomWordForm(BuildContext context, {String initialWord = ''}) {
  return showAppSheet<void>(
    context,
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
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  NavTextButton(label: 'Cancel', onPressed: () => Navigator.pop(context)),
                  Expanded(child: Text('Custom Word', textAlign: TextAlign.center, style: context.headline)),
                  Semantics(
                    hint: _isValid ? '' : 'Enter a Chinese word and a meaning first',
                    child: NavTextButton(label: 'Add', bold: true, onPressed: _isValid ? _add : null),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: const BorderRadius.all(cardRadius),
                child: ColoredBox(
                  color: context.cardBackground,
                  child: Column(
                    children: [
                      Semantics(
                        hint: 'Chinese characters only',
                        child: CupertinoTextField(
                          controller: _word,
                          placeholder: 'Word',
                          autocorrect: false,
                          decoration: null,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const Hairline(indent: 20),
                      Semantics(
                        hint: 'Filled in for you if left blank',
                        child: CupertinoTextField(
                          controller: _pinyin,
                          placeholder: 'Pinyin (optional)',
                          autocorrect: false,
                          decoration: null,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                      const Hairline(indent: 20),
                      Semantics(
                        hint: 'Separate several meanings with a slash',
                        child: CupertinoTextField(
                          controller: _meaning,
                          placeholder: 'Meaning',
                          decoration: null,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 16),
                  child: Semantics(
                    liveRegion: true,
                    label: 'Error: $message',
                    excludeSemantics: true,
                    child: Row(spacing: 6, children: [
                      Icon(CupertinoIcons.exclamationmark_triangle, size: 16, color: context.errorText),
                      Expanded(child: Text(message, style: context.footnote.copyWith(color: context.errorText))),
                    ]),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  'Chinese characters only. Separate several meanings with a slash. Pinyin is filled in for you if you leave it blank. Adding an existing word replaces it.',
                  style: context.footnote.copyWith(color: context.mutedText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
