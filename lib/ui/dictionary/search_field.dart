import 'package:flutter/material.dart';

/// Search box shown above a results list.
class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.onChanged, this.autofocus = false});

  final ValueChanged<String> onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        autofocus: autofocus,
        onChanged: onChanged,
        autocorrect: false,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search word, pinyin or meaning…',
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
          isDense: true,
        ),
      ),
    );
  }
}
