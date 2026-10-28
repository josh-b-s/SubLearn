import 'package:flutter/cupertino.dart' show CupertinoButton, CupertinoIcons, CupertinoTextField;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/dictionary_provider.dart';
import '../../state/settings_provider.dart';
import '../../state/translate_controller.dart';
import '../../state/words_provider.dart';
import '../components/alerts.dart';
import '../components/pill_chip.dart';
import '../components/section_label.dart';
import '../components/word_card.dart';
import '../components/word_detail_sheet.dart';
import '../theme/app_colors.dart';
import 'listening_bar.dart';

class TranslateScreen extends ConsumerStatefulWidget {
  const TranslateScreen({super.key});

  @override
  ConsumerState<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends ConsumerState<TranslateScreen> with WidgetsBindingObserver {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) ref.read(translateControllerProvider.notifier).stopListening();
  }

  /// Follows the live transcript while recording.
  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(translateControllerProvider.notifier);
    final state = ref.watch(translateControllerProvider);
    final tokens = ref.watch(translateTokensProvider);
    final hideLearned = ref.watch(settingsProvider.select((s) => s.hideLearnedInTranslate));

    ref.listen(wordsProvider.select((w) => w.length), (_, __) => HapticFeedback.selectionClick());

    // Speech updates the text from outside the field, so mirror it in.
    ref.listen(translateControllerProvider.select((s) => s.inputText), (_, text) {
      if (_input.text != text) _input.text = text;
      if (ref.read(translateControllerProvider).isListening) _scrollToEnd();
    });
    ref.listen(translateControllerProvider.select((s) => s.speechError), (_, error) {
      if (error == null) return;
      showMessageAlert(context, title: 'Speech input', message: error).then((_) => controller.clearError());
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Translate')),
      bottomNavigationBar: state.isListening
          ? ListeningBar(
              hasTranscript: tokens.isNotEmpty,
              hideLearned: hideLearned,
              onHideLearnedChanged: ref.read(settingsProvider.notifier).setHideLearnedInTranslate,
              onStop: controller.stopListening,
            )
          : null,
      body: SingleChildScrollView(
        controller: _scroll,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!state.isListening) _InputCard(controller: _input, onChanged: controller.setInput, onMic: controller.startListening),
            const SizedBox(height: 20),
            _Breakdown(isListening: state.isListening, hasInput: state.inputText.trim().isNotEmpty),
          ],
        ),
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({required this.controller, required this.onChanged, required this.onMic});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onMic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
      decoration: BoxDecoration(color: context.cardBackground, borderRadius: BorderRadius.circular(24)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              onChanged: onChanged,
              minLines: 1,
              maxLines: 6,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              placeholder: 'Paste or type Chinese text…',
              decoration: null,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          Semantics(
            button: true,
            label: 'Speak Chinese',
            hint: 'Starts the microphone and turns what you say into text',
            excludeSemantics: true,
            onTap: onMic,
            child: CupertinoButton.filled(
              padding: const EdgeInsets.all(10),
              borderRadius: BorderRadius.circular(20),
              onPressed: () {
                FocusScope.of(context).unfocus();
                onMic();
              },
              child: const Icon(CupertinoIcons.mic_fill, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _Breakdown extends ConsumerWidget {
  const _Breakdown({required this.isListening, required this.hasInput});

  final bool isListening;
  final bool hasInput;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictionary = ref.watch(dictionaryProvider);
    final tokens = ref.watch(translateTokensProvider);
    final saved = ref.watch(savedWordSetProvider);
    final hideLearned = ref.watch(settingsProvider.select((s) => s.hideLearnedInTranslate));

    if (dictionary.hasError) {
      return Text(
        "The dictionary couldn't be loaded. Check that assets/zh-en.tsv is listed in pubspec.yaml.",
        style: TextStyle(color: context.errorText),
      );
    }
    if (!dictionary.hasValue) {
      return const Row(children: [
        SizedBox(width: 20, height: 20, child: CircularProgressIndicator.adaptive(strokeWidth: 2)),
        SizedBox(width: 8),
        Text('Loading dictionary…'),
      ]);
    }
    if (hasInput && tokens.isEmpty) {
      return Text('No Chinese characters found.', style: TextStyle(color: context.mutedText));
    }
    if (tokens.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isListening)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionLabel('INTERACTIVE BREAKDOWN'),
              PillChip(
                icon: CupertinoIcons.eye_slash,
                label: 'Hide learned',
                selected: hideLearned,
                onTap: () => ref.read(settingsProvider.notifier).setHideLearnedInTranslate(!hideLearned),
                hint: 'Hides the pinyin and meaning of words you already know',
              ),
            ],
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final token in tokens)
              WordCard(
                key: ValueKey(token.id),
                token: token,
                isSaved: saved.contains(token.text),
                onTap: () => showWordDetailSheet(context, token),
              ),
          ],
        ),
      ],
    );
  }
}
