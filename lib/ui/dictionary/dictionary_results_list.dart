import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/dictionary_match.dart';
import '../../state/dictionary_provider.dart';
import '../../state/words_provider.dart';
import '../components/empty_state.dart';
import 'dictionary_result_row.dart';

/// Search states and results shared by the Dictionary and Add Known Word screens.
class DictionaryResultsList extends ConsumerStatefulWidget {
  const DictionaryResultsList({
    super.key,
    required this.query,
    required this.onSelect,
    required this.onAddCustom,
    this.selectedWord,
  });

  final String query;
  final String? selectedWord;
  final ValueChanged<DictionaryMatch> onSelect;
  final VoidCallback onAddCustom;

  @override
  ConsumerState<DictionaryResultsList> createState() => _DictionaryResultsListState();
}

class _DictionaryResultsListState extends ConsumerState<DictionaryResultsList> {
  /// Kept while the next search runs, so the list doesn't flash empty on each keystroke.
  List<DictionaryMatch> _previous = const [];

  @override
  Widget build(BuildContext context) {
    final query = widget.query.trim();
    if (query.isEmpty) {
      _previous = const [];
      return const EmptyState(
        icon: Icons.search,
        title: 'Search the dictionary',
        description: 'Find a word by its Chinese characters, pinyin or English meaning.',
      );
    }

    final search = ref.watch(dictionarySearchProvider(query));
    final results = search.valueOrNull ?? _previous;
    if (search.hasValue) _previous = search.value!;

    if (search.isLoading && results.isEmpty) return const Center(child: CircularProgressIndicator());
    if (results.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'No matches',
        description: 'Nothing found for "$query". You can add it yourself.',
        action: OutlinedButton(onPressed: widget.onAddCustom, child: const Text('Add as custom word')),
      );
    }

    final saved = ref.watch(savedWordSetProvider);
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) {
        final match = results[i];
        return InkWell(
          onTap: () => widget.onSelect(match),
          child: DictionaryResultRow(
            match: match,
            isSaved: saved.contains(match.word),
            isSelected: widget.selectedWord == match.word,
          ),
        );
      },
    );
  }
}
