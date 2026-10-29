import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/dictionary_match.dart';
import '../../state/dictionary_provider.dart';
import '../../state/words_provider.dart';
import '../components/app_button.dart';
import '../components/empty_state.dart';
import '../components/hairline.dart';
import '../components/tap_row.dart';
import '../theme/app_colors.dart';
import '../theme/app_shape.dart';
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
        icon: CupertinoIcons.search,
        title: 'Search the dictionary',
        description: 'Find a word by its Chinese characters, pinyin or English meaning.',
      );
    }

    final search = ref.watch(dictionarySearchProvider(query));
    final results = search.valueOrNull ?? _previous;
    if (search.hasValue) _previous = search.value!;

    if (search.isLoading && results.isEmpty) return const Center(child: CupertinoActivityIndicator());
    if (results.isEmpty) {
      return EmptyState(
        icon: CupertinoIcons.search,
        title: 'No matches',
        description: 'Nothing found for "$query". You can add it yourself.',
        action: AppButton(
          label: 'Add as Custom Word',
          style: AppButtonStyle.tinted,
          expand: false,
          onPressed: widget.onAddCustom,
        ),
      );
    }

    final saved = ref.watch(savedWordSetProvider);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: results.length,
      separatorBuilder: (_, __) => ColoredBox(color: context.cardBackground, child: const Hairline(indent: 16)),
      itemBuilder: (context, i) {
        final match = results[i];
        return ClipRRect(
          borderRadius: cornersAt(i, results.length),
          child: TapRow(
            onTap: () => widget.onSelect(match),
            child: Semantics(
              hint: 'Opens the word details',
              child: DictionaryResultRow(
                match: match,
                isSaved: saved.contains(match.word),
                isSelected: widget.selectedWord == match.word,
              ),
            ),
          ),
        );
      },
    );
  }
}
