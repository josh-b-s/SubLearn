import 'package:flutter/material.dart';

import '../components/word_detail_sheet.dart';
import '../vocabulary/custom_word_form.dart';
import 'dictionary_results_list.dart';
import 'search_field.dart';

/// Search the whole dictionary, open a word, save it, or add your own words.
class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dictionary'),
        actions: [
          IconButton(
            tooltip: 'Add custom word',
            icon: const Icon(Icons.add),
            onPressed: () => showCustomWordForm(context, initialWord: _query),
          ),
        ],
      ),
      body: Column(
        children: [
          SearchField(onChanged: (v) => setState(() => _query = v)),
          Expanded(
            child: DictionaryResultsList(
              query: _query,
              onSelect: (match) => showWordDetailSheet(context, match.token),
              onAddCustom: () => showCustomWordForm(context, initialWord: _query),
            ),
          ),
        ],
      ),
    );
  }
}
