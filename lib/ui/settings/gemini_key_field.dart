import 'package:flutter/cupertino.dart' show CupertinoTextField, OverlayVisibilityMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/gemini_key_provider.dart';

/// Saves on every change, like the Swift app.
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: CupertinoTextField(
        controller: _controller,
        placeholder: 'Gemini API key',
        obscureText: true,
        autocorrect: false,
        enableSuggestions: false,
        textCapitalization: TextCapitalization.none,
        decoration: null,
        padding: const EdgeInsets.symmetric(vertical: 12),
        clearButtonMode: OverlayVisibilityMode.editing,
        onChanged: (_) => _save(),
      ),
    );
  }
}
