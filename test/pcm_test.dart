import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:subtitle_learn/services/speech/sherpa/pcm.dart';

void main() {
  test('converts little-endian 16-bit samples to floats', () {
    final bytes = Uint8List.fromList([0x00, 0x00, 0x00, 0x40, 0x00, 0x80, 0xFF, 0x7F]);

    final samples = pcm16ToFloat32(bytes);

    expect(samples.length, 4);
    expect(samples[0], 0);
    expect(samples[1], 0.5);
    expect(samples[2], -1);
    expect(samples[3], closeTo(0.99997, 0.0001));
  });

  test('works on a view that starts at an odd offset', () {
    final backing = Uint8List.fromList([9, 0x00, 0x40]);

    final samples = pcm16ToFloat32(Uint8List.sublistView(backing, 1));

    expect(samples, [0.5]);
  });

  test('ignores a trailing half sample', () {
    expect(pcm16ToFloat32(Uint8List.fromList([0x00, 0x40, 0x01])).length, 1);
  });
}
