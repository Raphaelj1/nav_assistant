import 'dart:typed_data';

class SegmentationMask {
  final int width;
  final int height;
  final Uint8List data;

  SegmentationMask({required this.width, required this.height, required this.data});

  int at(int x, int y) => data[y * width + x];
}
