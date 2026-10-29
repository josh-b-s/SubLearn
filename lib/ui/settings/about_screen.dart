import 'package:flutter/cupertino.dart';

import '../components/pushed_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PushedPage(
      title: 'About',
      backLabel: 'Settings',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Heading('App'),
          const Text('Subtitle Learn 1.0.0'),
          const SizedBox(height: 4),
          const Text(
            'Learn Mandarin from the video and audio you already watch. Live subtitles appear as tappable word cards, saved words go into a spaced repetition quiz.',
          ),
          const _Heading('Author'),
          const Text('Josh Brian Saputra'),
          const _Heading('Acknowledgements'),
          const _Credit(
            'CedPane',
            'Chinese-English Dictionary Public-domain Additions for Names Etc, by ssb22. Source of words and definitions (PD-English-Definitions.tsv).',
            'https://github.com/ssb22/CedPane',
          ),
          const _Credit(
            'CC-CEDICT',
            'Community Chinese-English dictionary from MDBG, used for pinyin. Licensed under CC BY-SA.',
            'https://cc-cedict.org',
          ),
          const _Credit(
            'pypinyin',
            'Python library that filled in pinyin for words missing from CC-CEDICT when the word list was built.',
            'https://github.com/mozillazg/python-pinyin',
          ),
          const _Credit(
            'Google Gemini API',
            'Writes the example sentences for level 3 quiz questions.',
            'https://ai.google.dev',
          ),
          const _Credit(
            'Flutter and platform frameworks',
            'Flutter for the interface, speech_to_text and flutter_tts for speech, fl_chart for the stats screen. On iOS, Speech, ReplayKit and AVKit power Screen Share.',
            null,
          ),
          const _Credit(
            'AI assistance',
            'Some code was written with help from Claude (Anthropic). I reviewed and can explain all of it.',
            null,
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 6),
        child: Text(text, style: context.headline.copyWith(fontWeight: FontWeight.bold)),
      );
}

class _Credit extends StatelessWidget {
  const _Credit(this.title, this.detail, this.link);

  final String title;
  final String detail;
  final String? link;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.subhead.copyWith(fontWeight: FontWeight.bold)),
          Text(detail, style: context.subhead.copyWith(color: context.mutedText)),
          if (link != null) Text(link!, style: context.footnote.copyWith(color: context.accent)),
        ],
      ),
    );
  }
}
