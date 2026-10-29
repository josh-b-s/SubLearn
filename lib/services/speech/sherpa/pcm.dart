import 'dart:typed_data';

/// Little-endian 16-bit mono PCM to the floats in [-1, 1) that Sherpa takes.
Float32List pcm16ToFloat32(Uint8List bytes) {
  final view = ByteData.sublistView(bytes);
  final samples = Float32List(bytes.length ~/ 2);
  for (var i = 0; i < samples.length; i++) {
    samples[i] = view.getInt16(i * 2, Endian.little) / 32768.0;
  }
  return samples;
}
