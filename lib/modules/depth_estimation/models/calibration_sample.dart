import 'package:image/image.dart' as img;

class CalibrationSample {
  final img.Image image;
  final double realDistance; // in meters
  
  CalibrationSample({required this.image, required this.realDistance});
}
