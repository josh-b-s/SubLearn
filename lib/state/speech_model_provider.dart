import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/speech/sherpa/sherpa_model_store.dart';
import 'screen_share_backend_provider.dart';

final sherpaModelStoreProvider = Provider<SherpaModelStore>((ref) => SherpaModelStore());

enum SpeechModelStatus { checking, missing, downloading, installed }

class SpeechModelState {
  const SpeechModelState({this.status = SpeechModelStatus.checking, this.progress, this.error});

  final SpeechModelStatus status;

  /// 0 to 1 while downloading, or null when the size isn't known.
  final double? progress;
  final String? error;
}

class SpeechModelController extends Notifier<SpeechModelState> {
  @override
  SpeechModelState build() {
    Future.microtask(refresh);
    return const SpeechModelState();
  }

  SherpaModelStore get _store => ref.read(sherpaModelStoreProvider);

  Future<void> refresh() async {
    final files = await _store.installed();
    state = SpeechModelState(status: files == null ? SpeechModelStatus.missing : SpeechModelStatus.installed);
    // Screen Share on Android reads whether the model exists from its capabilities.
    ref.invalidate(screenShareCapabilitiesProvider);
  }

  Future<void> download() async {
    if (state.status == SpeechModelStatus.downloading) return;
    state = const SpeechModelState(status: SpeechModelStatus.downloading);
    try {
      await for (final progress in _store.download()) {
        state = SpeechModelState(status: SpeechModelStatus.downloading, progress: progress);
      }
      await refresh();
    } on Exception catch (e) {
      state = SpeechModelState(status: SpeechModelStatus.missing, error: e is SpeechModelException ? e.message : "The download failed. Check your connection and try again.");
    }
  }

  Future<void> remove() async {
    await _store.delete();
    await refresh();
  }
}

final speechModelProvider = NotifierProvider<SpeechModelController, SpeechModelState>(SpeechModelController.new);
