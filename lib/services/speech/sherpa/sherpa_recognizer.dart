import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

import 'pcm.dart';
import 'sherpa_model_store.dart';

class SherpaException implements Exception {
  const SherpaException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// The text of the utterance being spoken. [utteranceEnded] means it is final and the next result starts a new one.
class SherpaResult {
  const SherpaResult(this.text, {required this.utteranceEnded});

  final String text;
  final bool utteranceEnded;
}

/// Streaming speech recognition in a background isolate, so loading the model and decoding never block the UI.
class SherpaRecognizer {
  SherpaRecognizer._(this._commands, this._fromWorker, this._results);

  static const sampleRate = 16000;

  final SendPort _commands;
  final ReceivePort _fromWorker;
  final StreamController<SherpaResult> _results;

  Stream<SherpaResult> get results => _results.stream;

  /// Loads the model, which takes a few seconds. Throws [SherpaException] if it can't.
  static Future<SherpaRecognizer> start(SherpaModelFiles files) async {
    final fromWorker = ReceivePort();
    final results = StreamController<SherpaResult>.broadcast();
    final ready = Completer<SendPort>();

    fromWorker.listen((message) {
      if (message is SendPort) {
        ready.complete(message);
      } else if (message is String) {
        final error = SherpaException(message);
        if (ready.isCompleted) {
          results.addError(error);
        } else {
          ready.completeError(error);
        }
      } else if (message is List) {
        results.add(SherpaResult(message[0] as String, utteranceEnded: message[1] as bool));
      }
    });

    await Isolate.spawn(_work, _Start(files, fromWorker.sendPort));
    try {
      return SherpaRecognizer._(await ready.future, fromWorker, results);
    } on SherpaException {
      fromWorker.close();
      await results.close();
      rethrow;
    }
  }

  /// [pcm16] is 16 kHz mono little-endian 16-bit audio. The list must not be reused afterwards.
  void feed(Uint8List pcm16) => _commands.send(TransferableTypedData.fromList([pcm16]));

  Future<void> dispose() async {
    _commands.send(null);
    _fromWorker.close();
    await _results.close();
  }
}

class _Start {
  const _Start(this.files, this.replyTo);

  final SherpaModelFiles files;
  final SendPort replyTo;
}

void _work(_Start start) {
  final commands = ReceivePort();
  late final sherpa.OnlineRecognizer recognizer;
  late final sherpa.OnlineStream stream;
  try {
    sherpa.initBindings();
    recognizer = sherpa.OnlineRecognizer(
      sherpa.OnlineRecognizerConfig(
        model: sherpa.OnlineModelConfig(
          paraformer: sherpa.OnlineParaformerModelConfig(encoder: start.files.encoder, decoder: start.files.decoder),
          tokens: start.files.tokens,
          numThreads: 2,
          debug: false,
        ),
        ruleFsts: '',
      ),
    );
    stream = recognizer.createStream();
  } catch (e) {
    start.replyTo.send("Couldn't load the speech model: $e");
    return;
  }
  start.replyTo.send(commands.sendPort);

  var lastText = '';
  commands.listen((message) {
    if (message is! TransferableTypedData) {
      stream.free();
      recognizer.free();
      commands.close();
      return;
    }
    try {
      final samples = pcm16ToFloat32(message.materialize().asUint8List());
      stream.acceptWaveform(samples: samples, sampleRate: SherpaRecognizer.sampleRate);
      while (recognizer.isReady(stream)) {
        recognizer.decode(stream);
      }
      final text = recognizer.getResult(stream).text;
      final ended = recognizer.isEndpoint(stream);
      if (ended) recognizer.reset(stream);
      if (ended || text != lastText) start.replyTo.send([text, ended]);
      lastText = ended ? '' : text;
    } catch (e) {
      start.replyTo.send('Speech recognition failed: $e');
    }
  });
}
