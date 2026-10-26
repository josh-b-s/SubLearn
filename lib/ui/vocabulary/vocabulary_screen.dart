import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/mastery_filter.dart';
import '../../models/saved_word.dart';
import '../../models/vocabulary_sort.dart';
import '../../services/vocabulary/saved_word_mastery.dart';
import '../../services/vocabulary/saved_word_review.dart';
import '../../services/vocabulary/saved_word_search.dart';
import '../../state/clock_provider.dart';
import '../../state/review_logs_provider.dart';
import '../../state/settings_provider.dart';
import '../../state/words_provider.dart';
import '../components/empty_state.dart';
import '../components/word_detail_sheet.dart';
import '../dictionary/dictionary_screen.dart';
import 'add_known_word_screen.dart';
import 'mastery_filter_bar.dart';
import 'vocabulary_row.dart';

class VocabularyScreen extends ConsumerStatefulWidget {
  const VocabularyScreen({super.key});

  @override
  ConsumerState<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends ConsumerState<VocabularyScreen> {
  String _query = '';
  MasteryFilter? _filter;
  bool _dueOnly = false;
  bool _isSelecting = false;
  final Set<String> _picked = {};

  List<SavedWord> _filtered(List<SavedWord> words) {
    final now = ref.read(clockProvider)();
    final matching = words
        .where((w) =>
            (_filter?.matches(w.level) ?? true) &&
            (!_dueOnly || (!w.isMastered && w.isDue(now))) &&
            w.matches(_query))
        .toList();
    final sort = ref.watch(settingsProvider.select((s) => s.vocabularySort));
    return sort.sorted(matching, ref.watch(reviewLogsProvider));
  }

  void _endSelecting() => setState(() {
        _isSelecting = false;
        _picked.clear();
      });

  Future<bool> _confirmDelete(List<SavedWord> doomed) async {
    final title = doomed.length == 1 ? 'Delete this word?' : 'Delete ${doomed.length} words?';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('Their level and review history are deleted too.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return false;
    ref.read(wordsProvider.notifier).remove({for (final w in doomed) w.word});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final words = ref.watch(wordsProvider);
    final filtered = _filtered(words);
    // Checked words still in the list, so a search can't leave hidden words queued for deletion.
    final picked = filtered.where((w) => _picked.contains(w.word)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary'),
        leading: _isSelecting
            ? TextButton(onPressed: _endSelecting, child: const Text('Cancel'))
            : (words.isEmpty ? null : TextButton(onPressed: () => setState(() => _isSelecting = true), child: const Text('Select'))),
        leadingWidth: 80,
        actions: _isSelecting
            ? [
                TextButton(
                  onPressed: picked.isEmpty
                      ? null
                      : () async {
                          if (await _confirmDelete(picked)) _endSelecting();
                        },
                  child: Text(picked.isEmpty ? 'Delete' : 'Delete (${picked.length})'),
                ),
              ]
            : [
                IconButton(
                  tooltip: 'Dictionary',
                  icon: const Icon(Icons.translate),
                  onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const DictionaryScreen())),
                ),
                IconButton(
                  tooltip: 'Add known word',
                  icon: const Icon(Icons.add),
                  onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const AddKnownWordScreen())),
                ),
              ],
      ),
      body: words.isEmpty
          ? const EmptyState(
              icon: Icons.bookmark_border,
              title: 'No saved words yet',
              description: 'Tap a word on the Translate tab, or tap + to add a word you already know.',
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search vocabulary…',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                      isDense: true,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: MasteryFilterBar(
                        selection: _filter,
                        dueOnly: _dueOnly,
                        onSelection: (f) => setState(() => _filter = f),
                        onDueOnly: (v) => setState(() => _dueOnly = v),
                      ),
                    ),
                    _SortMenu(),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? EmptyState(
                          icon: Icons.search,
                          title: 'No words found',
                          description: _query.isNotEmpty
                              ? 'No matches for "$_query".'
                              : (_dueOnly ? 'Nothing is due for review today.' : 'No words at this stage yet.'),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, i) => _row(filtered[i]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _row(SavedWord word) {
    final tile = InkWell(
      onTap: () {
        if (!_isSelecting) {
          showWordDetailSheet(context, word.token);
          return;
        }
        setState(() => _picked.contains(word.word) ? _picked.remove(word.word) : _picked.add(word.word));
      },
      child: VocabularyRow(word: word, isPicked: _isSelecting ? _picked.contains(word.word) : null),
    );
    if (_isSelecting) return tile;
    return Dismissible(
      key: ValueKey(word.word),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete([word]),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: tile,
    );
  }
}

class _SortMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(settingsProvider.select((s) => s.vocabularySort));
    return PopupMenuButton<VocabularySort>(
      tooltip: 'Sort: ${sort.label}',
      icon: const Icon(Icons.swap_vert),
      initialValue: sort,
      onSelected: ref.read(settingsProvider.notifier).setVocabularySort,
      itemBuilder: (_) => [
        for (final option in VocabularySort.values) PopupMenuItem(value: option, child: Text(option.label)),
      ],
    );
  }
}
