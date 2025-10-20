import 'dart:typed_data';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

class ImagePreprocessor {
  // Decode Uint8List → [img.Image]
  static img.Image decodeImage(Uint8List imageBytes) {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw Exception("Failed to decode image");
    }
    return decoded;
  }

  // Resize to target size. If [letterbox] is true, pad to keep aspect ratio.
  static img.Image resize(
    img.Image image,
    int dstW,
    int dstH, {
    bool letterbox = false,
    bool grayBg = false,
  }) {
    if (!letterbox) {
      return img.copyResize(image, width: dstW, height: dstH);
    }

    final scale = math.min(dstW / image.width, dstH / image.height);
    final newW = (image.width * scale).round();
    final newH = (image.height * scale).round();

    final resized = img.copyResize(image, width: newW, height: newH);

    // Black canvas
    final canvas = img.Image(width: dstW, height: dstH);
    if (grayBg) {
      canvas.clear(img.ColorRgb8(114, 114, 114));
    } else {
      canvas.clear(img.ColorRgb8(0, 0, 0));
    }

    // Center the resized image
    final xOff = ((dstW - newW) / 2).round();
    final yOff = ((dstH - newH) / 2).round();

    img.compositeImage(canvas, resized, dstX: xOff, dstY: yOff);

    return canvas;
  }

  // YOLO preprocessing: normalize [0–255] → [0–1] and pack Float32List [1,H,W,3]
  static Float32List normalizeFloat(
    img.Image image, {
    double scale = 1 / 255.0,
  }) {
    final h = image.height;
    final w = image.width;
    final input = Float32List(1 * h * w * 3);

    int i = 0;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final p = image.getPixel(x, y); // Pixel object
        input[i++] = p.r * scale;
        input[i++] = p.g * scale;
        input[i++] = p.b * scale;
      }
    }
    return input;
  }

  // MiDaS preprocessing: normalize with mean/std and pack Float32List [1,H,W,3]
  static Float32List normalizeMeanStd(
    img.Image image,
    List<double> mean,
    List<double> std,
  ) {
    final h = image.height;
    final w = image.width;
    final input = Float32List(1 * h * w * 3);

    int i = 0;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final p = image.getPixel(x, y);
        input[i++] = (p.r / 255.0 - mean[0]) / std[0];
        input[i++] = (p.g / 255.0 - mean[1]) / std[1];
        input[i++] = (p.b / 255.0 - mean[2]) / std[2];
      }
    }
    return input;
  }
}
