import 'package:flutter/cupertino.dart';

import '../theme/app_shape.dart';

/// Search box shown above a results list.
class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.onChanged, this.autofocus = false});

  final ValueChanged<String> onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: CupertinoSearchTextField(
        autofocus: autofocus,
        onChanged: onChanged,
        autocorrect: false,
        borderRadius: const BorderRadius.all(controlRadius),
        padding: const EdgeInsets.all(10),
        placeholder: 'Search word, pinyin or meaning…',
      ),
    );
  }
}
