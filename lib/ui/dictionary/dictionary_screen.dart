import 'package:flutter/cupertino.dart';

import '../components/icon_action.dart';
import '../components/pushed_page.dart';
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
    return PushedPage(
      title: 'Dictionary',
      backLabel: 'Vocabulary',
      trailing: IconAction(
        label: 'Add custom word',
        icon: CupertinoIcons.add,
        onPressed: () => showCustomWordForm(context, initialWord: _query),
      ),
      child: Column(
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
