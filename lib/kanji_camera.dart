import "dart:async";

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:logger/logger.dart';

class KanjiCameraWidget extends StatefulWidget {
  const KanjiCameraWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _KanjiCameraWidgetState createState() => _KanjiCameraWidgetState();
}

class _KanjiCameraWidgetState extends State<KanjiCameraWidget> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  final TextRecognizer textRecognizer = TextRecognizer(script: TextRecognitionScript.japanese);
  String _recognizedText = "";
  final _logger = Logger();
  bool _isProcessingImage = false;
  late Timer _processingTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _controller = CameraController(_cameras[0], ResolutionPreset.medium);
      await _controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });

      _processingTimer = Timer.periodic(const Duration(seconds: 500), (timer) {
        if (!_isProcessingImage && _controller!.value.isInitialized) {
          _processCameraImage();
        }
      });
    }
  }

  void _processCameraImage() async {
    _isProcessingImage = true;
    final image = await _controller!.takePicture();
    _recognizeTextFromImage(image);

    // Reset the flag after processing
    _isProcessingImage = false;
  }

  Future<void> _recognizeTextFromImage(XFile file) async {
    final inputImage = InputImage.fromFilePath(file.path);
    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      setState(() {
        _recognizedText = recognizedText.text;
      });
    } catch (e) {
      _logger.e('Error recognizing text: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    textRecognizer.close();
    _processingTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanji Camera'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _controller == null || !_controller!.value.isInitialized
              ? const Center(child: CircularProgressIndicator())
              : CameraPreview(_controller!),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _recognizedText,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
