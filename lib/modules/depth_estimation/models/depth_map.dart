import 'dart:typed_data';

class DepthMap {
  final Float32List data;
  final int width;
  final int height;

  DepthMap({required this.data, required this.width, required this.height});

  double getValue(int x, int y) => data[y * width + x];
}
