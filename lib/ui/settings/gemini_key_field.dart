import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/gemini_key_provider.dart';

/// Saves on submit or when the field loses focus, not on every keystroke.
class GeminiKeyField extends ConsumerStatefulWidget {
  const GeminiKeyField({super.key});

  @override
  ConsumerState<GeminiKeyField> createState() => _GeminiKeyFieldState();
}

class _GeminiKeyFieldState extends ConsumerState<GeminiKeyField> {
  final _controller = TextEditingController();
  bool _loaded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() => ref.read(geminiKeyProvider.notifier).save(_controller.text);

  @override
  Widget build(BuildContext context) {
    final key = ref.watch(geminiKeyProvider);
    if (!_loaded && key.hasValue) {
      _controller.text = key.value!;
      _loaded = true;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Focus(
        onFocusChange: (focused) {
          if (!focused && _loaded) _save();
        },
        child: TextField(
          controller: _controller,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: const InputDecoration(labelText: 'Gemini API key'),
          onSubmitted: (_) => _save(),
        ),
      ),
    );
  }
}
