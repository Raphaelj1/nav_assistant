import 'dart:typed_data';

Float32List flattenDepthOutput(List<List<List<List<double>>>> output) {
  final H = output[0].length;
  final W = output[0][0].length;
  // final C = output[0][0][0].length; // should be 1 for MiDaS
  final flattened = Float32List(H * W);

  for (int y = 0; y < H; y++) {
    for (int x = 0; x < W; x++) {
      flattened[y * W + x] = output[0][y][x][0]; // channel 0
    }
  }
  return flattened;
}
