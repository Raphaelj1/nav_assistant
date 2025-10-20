import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import '../utils/image_utils.dart';

class CameraService {
  CameraController? _controller;
  late CameraDescription _cameraDescription;

  bool _initialized = false;
  bool _streaming = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _initialized;

  Future<void> initialize({
    ResolutionPreset resolution = ResolutionPreset.medium,
    bool enableAudio = false,
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.yuv420,
  }) async {
    if (_initialized) return;

    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraDescription = backCamera;

    _controller = CameraController(
      backCamera,
      resolution,
      enableAudio: enableAudio,
      imageFormatGroup: imageFormatGroup,
    );

    await _controller!.initialize();
    _initialized = true;
  }

  Future<void> dispose() async {
    await stopStream();
    await _controller?.dispose();
    _controller = null;
    _initialized = false;
  }

  Widget buildPreview() {
    if (!_initialized || _controller == null) {
      return const Center(child: Text("Camera not ready"));
    }
    // return AspectRatio(
    //   aspectRatio: _controller!.value.aspectRatio,
    //   child: CameraPreview(_controller!),
    // );
    return CameraPreview(_controller!);
  }

  Future<img.Image?> captureSingleFrame({
    Duration timeout = const Duration(seconds: 2),
  }) async {
    bool tempInit = false;

    // auto init
    if (!_initialized || _controller == null) {
      await initialize();
      tempInit = true;
    }

    if (_streaming) {
      if (tempInit) await dispose();
      throw StateError('Already streaming...');
    }

    final completer = Completer<img.Image?>();
    bool completed = false;

    Future<void> completeOnce(img.Image? data) async {
      if (completed) return;
      completed = true;
      if (!completer.isCompleted) completer.complete(data);
      await stopStream();
      if (tempInit) await dispose(); // cleanup if auto-init
    }

    _streaming = true;
    await _controller!.startImageStream((CameraImage image) {
      final raw = yuvToImage(image);
      final fixed = fixOrientation(
        raw,
        _cameraDescription,
        _controller!.value.deviceOrientation,
      );
      completeOnce(fixed);
    });

    // Safety timeout
    Future.delayed(timeout, () => completeOnce(null));

    return completer.future;
  }

  Future<List<img.Image>> captureMultipleFrames(
    int n, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    bool tempInit = false;

    // auto init
    if (!_initialized || _controller == null) {
      await initialize();
      tempInit = true;
    }

    if (_streaming) {
      if (tempInit) await dispose();
      throw StateError('Already streaming...');
    }

    final frames = <img.Image>[];
    final completer = Completer<List<img.Image>>();
    bool completed = false;

    Future<void> completeOnce() async {
      if (completed) return;
      completed = true;
      if (!completer.isCompleted) completer.complete(frames);
      await stopStream();
      if (tempInit) await dispose(); // cleanup if auto-init
    }

    _streaming = true;
    await _controller!.startImageStream((CameraImage image) {
      if (!_streaming) return;
      final raw = yuvToImage(image);
      final fixed = fixOrientation(
        raw,
        _cameraDescription,
        _controller!.value.deviceOrientation,
      );
      frames.add(fixed);
      if (frames.length >= n) completeOnce();
    });

    // Timeout safety
    Future.delayed(timeout, completeOnce);

    return completer.future;
  }

  Future<void> startStream(Function(img.Image) onFrame) async {
    if (_controller == null) return;
    if (_streaming) return;

    _streaming = true;
    await _controller!.startImageStream((CameraImage image) {
      img.Image data = yuvToImage(image);
      onFrame(data);
    });
  }

  Future<void> stopStream() async {
    if (_streaming) {
      await _controller?.stopImageStream();
      _streaming = false;
    }
  }

  // Shutter in preview mode (still gives Uint8)
  Future<img.Image?> captureFromPreview({
    int skipFrames = 2, // skip the first frame for stability
    Duration timeout = const Duration(seconds: 2),
  }) async {
    if (!_initialized || _controller == null) return null;
    if (_streaming) throw StateError('Already streaming');

    final completer = Completer<img.Image?>();
    bool completed = false;
    int count = 0;

    void completeOnce(img.Image? data) {
      if (completed) return;
      completed = true;
      if (!completer.isCompleted) completer.complete(data);
      stopStream();
    }

    _streaming = true;
    await _controller!.startImageStream((CameraImage image) {
      count++;
      if (count <= skipFrames) return; // discard unstable frame(s)

      final bytes = yuvToImage(image);
      completeOnce(bytes);
    });

    // Safety timeout
    Future.delayed(timeout, () => completeOnce(null));

    return completer.future;
  }
}
