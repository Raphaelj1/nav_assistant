// import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

/// Convert a CameraImage in YUV420 format to an img.Image (RGB).
img.Image yuvToImage(CameraImage cameraImage) {
  final int width = cameraImage.width;
  final int height = cameraImage.height;

  final yPlane = cameraImage.planes[0];
  final uPlane = cameraImage.planes[1];
  final vPlane = cameraImage.planes[2];

  final imgBuffer = img.Image(width: width, height: height);

  final int uvRowStride = uPlane.bytesPerRow;
  final int uvPixelStride = uPlane.bytesPerPixel!;

  for (int y = 0; y < height; y++) {
    final int uvRow = uvRowStride * (y >> 1);

    for (int x = 0; x < width; x++) {
      final int uvIndex = uvRow + (x >> 1) * uvPixelStride;

      final int yp = yPlane.bytes[y * yPlane.bytesPerRow + x];
      final int up = uPlane.bytes[uvIndex];
      final int vp = vPlane.bytes[uvIndex];

      // YUV420 to RGB conversion (BT.601 standard)
      int r = (yp + 1.370705 * (vp - 128)).round();
      int g = (yp - 0.337633 * (up - 128) - 0.698001 * (vp - 128)).round();
      int b = (yp + 1.732446 * (up - 128)).round();

      // Clamp values into [0, 255]
      r = r.clamp(0, 255);
      g = g.clamp(0, 255);
      b = b.clamp(0, 255);

      imgBuffer.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  return imgBuffer;
}

Uint8List yuvToUint8(CameraImage image) {
  final int width = image.width;
  final int height = image.height;
  final int uvRowStride = image.planes[1].bytesPerRow;
  final int uvPixelStride = image.planes[1].bytesPerPixel!;

  final Uint8List yBuffer = image.planes[0].bytes;
  final Uint8List uBuffer = image.planes[1].bytes;
  final Uint8List vBuffer = image.planes[2].bytes;

  final Uint8List rgbBuffer = Uint8List(width * height * 3);

  int rgbIndex = 0;

  for (int y = 0; y < height; y++) {
    final int uvRow = uvRowStride * (y >> 1);

    for (int x = 0; x < width; x++) {
      final int uvIndex = uvRow + (x >> 1) * uvPixelStride;

      final int yp = yBuffer[y * image.planes[0].bytesPerRow + x];
      final int up = uBuffer[uvIndex];
      final int vp = vBuffer[uvIndex];

      // Convert YUV -> RGB (BT.601)
      int r = (yp + (1.370705 * (vp - 128))).round();
      int g = (yp - (0.337633 * (up - 128)) - (0.698001 * (vp - 128))).round();
      int b = (yp + (1.732446 * (up - 128))).round();

      // Clamp to [0, 255]
      rgbBuffer[rgbIndex++] = r.clamp(0, 255);
      rgbBuffer[rgbIndex++] = g.clamp(0, 255);
      rgbBuffer[rgbIndex++] = b.clamp(0, 255);
    }
  }

  return rgbBuffer;
}

img.Image fixOrientation(
  img.Image raw,
  CameraDescription description,
  DeviceOrientation orientation,
) {
  // Mirror front camera
  if (description.lensDirection == CameraLensDirection.front) {
    raw = img.flipHorizontal(raw);
  }

  // Rotate based on device orientation
  // switch (orientation) {
  //   case DeviceOrientation.portraitUp:
  //     return img.copyRotate(raw, angle: 90); // already upright
  //   case DeviceOrientation.landscapeLeft:
  //     return img.copyRotate(raw, angle: 90);
  //   case DeviceOrientation.portraitDown:
  //     return img.copyRotate(raw, angle: 180);
  //   case DeviceOrientation.landscapeRight:
  //     return img.copyRotate(raw, angle: -90);
  //   default:
  //     return raw;
  // }

  if (raw.width > raw.height) {
    switch (orientation) {
      case DeviceOrientation.portraitUp:
        raw = img.copyRotate(raw, angle: 90); // already upright
      case DeviceOrientation.landscapeLeft:
        raw = img.copyRotate(raw, angle: 90);
      case DeviceOrientation.portraitDown:
        raw = img.copyRotate(raw, angle: 180);
      case DeviceOrientation.landscapeRight:
        raw = img.copyRotate(raw, angle: -90);
    }
  }
  return raw;
}
