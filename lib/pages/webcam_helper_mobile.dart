// Webcam helper untuk MOBILE (menggunakan camera package)
import 'dart:typed_data';
import 'package:camera/camera.dart';

class WebCamera {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) {
      throw Exception('No camera available');
    }

    _controller = CameraController(
      _cameras![0],
      ResolutionPreset.medium,
    );

    await _controller!.initialize();
  }

  Future<Uint8List> capture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    final image = await _controller!.takePicture();
    return await image.readAsBytes();
  }

  void dispose() {
    _controller?.dispose();
  }

  CameraController? get controller => _controller;
}
