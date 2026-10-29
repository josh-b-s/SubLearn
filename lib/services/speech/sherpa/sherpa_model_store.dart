import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class SpeechModelException implements Exception {
  const SpeechModelException(this.message);
  final String message;

  @override
  String toString() => message;
}

class SherpaModelFiles {
  const SherpaModelFiles({required this.encoder, required this.decoder, required this.tokens});

  final String encoder;
  final String decoder;
  final String tokens;
}

/// Downloads the streaming Paraformer model (Mandarin and English) into the app's support folder.
class SherpaModelStore {
  SherpaModelStore({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl =
      'https://huggingface.co/csukuangfj/sherpa-onnx-streaming-paraformer-bilingual-zh-en/resolve/main';
  static const _names = ['encoder.int8.onnx', 'decoder.int8.onnx', 'tokens.txt'];

  final http.Client _client;

  Future<Directory> _directory() async {
    final support = await getApplicationSupportDirectory();
    return Directory('${support.path}/speech_model');
  }

  /// The model's files, or null when any of them is missing.
  Future<SherpaModelFiles?> installed() async {
    final dir = await _directory();
    final paths = [for (final name in _names) '${dir.path}/$name'];
    for (final path in paths) {
      final file = File(path);
      if (!await file.exists() || await file.length() == 0) return null;
    }
    return SherpaModelFiles(encoder: paths[0], decoder: paths[1], tokens: paths[2]);
  }

  /// Downloads every file and reports progress from 0 to 1, or nothing when the sizes are unknown.
  /// A file gets its real name only once it is complete, so a dropped connection never leaves a broken model.
  Stream<double> download() async* {
    final dir = await _directory();
    await dir.create(recursive: true);

    final sizes = await Future.wait(_names.map(_size));
    final total = sizes.fold<int>(0, (sum, size) => sum + size);
    var received = 0;

    for (var i = 0; i < _names.length; i++) {
      final target = File('${dir.path}/${_names[i]}');
      final part = File('${target.path}.part');
      final sink = part.openWrite();
      try {
        final response = await _client.send(http.Request('GET', Uri.parse('$_baseUrl/${_names[i]}')));
        if (response.statusCode != 200) {
          throw SpeechModelException('The download failed (HTTP ${response.statusCode}).');
        }
        await for (final chunk in response.stream) {
          sink.add(chunk);
          received += chunk.length;
          if (total > 0) yield received / total;
        }
      } finally {
        await sink.close();
      }
      if (sizes[i] > 0 && await part.length() != sizes[i]) {
        throw const SpeechModelException('The download was cut short. Try again.');
      }
      await part.rename(target.path);
    }
  }

  Future<void> delete() async {
    final dir = await _directory();
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  Future<int> _size(String name) async {
    try {
      final response = await _client.head(Uri.parse('$_baseUrl/$name'));
      return int.tryParse(response.headers['content-length'] ?? '') ?? 0;
    } on Exception {
      return 0; // Progress becomes unknown. The download itself can still work.
    }
  }
}
