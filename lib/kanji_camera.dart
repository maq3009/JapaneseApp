import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:logger/logger.dart';

class KanjiCameraWidget extends StatefulWidget {
  const KanjiCameraWidget({super.key});

  @override
  _KanjiCameraWidgetState createState() => _KanjiCameraWidgetState();
}

class _KanjiCameraWidgetState extends State<KanjiCameraWidget> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  final TextRecognizer textRecognizer = TextRecognizer(script: TextRecognitionScript.japanese);
  final OnDeviceTranslator onDeviceTranslator = OnDeviceTranslator(
    sourceLanguage: TranslateLanguage.japanese,
    targetLanguage: TranslateLanguage.english,
  );
  String _recognizedText = "";
  String _translatedText = "";
  final _logger = Logger();
  bool _isProcessingImage = false;
  bool _isProcessingEnabled = true;
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

        // Start the processing timer only after the camera is initialized
        _processingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
          if (!_isProcessingImage && _controller!.value.isInitialized && _isProcessingEnabled) {
            _processCameraImage();
          }
        });
      });
    }
  }

  void _processCameraImage() async {
    _isProcessingImage = true;
    if (!_controller!.value.isTakingPicture) {
      try {
        final image = await _controller!.takePicture();
        await _recognizeTextFromImage(image);
      } catch (e) {
        _logger.e("Failed to take a picture/recognize text: $e");
      }
    }
    _isProcessingImage = false;
  }

  Future<void> _recognizeTextFromImage(XFile file) async {
    final inputImage = InputImage.fromFilePath(file.path);
    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      setState(() {
        _recognizedText = recognizedText.text;
      });
      await _translateText(_recognizedText);
    } catch (e) {
      _logger.e('Error recognizing text: $e');
    }
  }

  Future<void> _translateText(String text) async {
    try {
      final translatedText = await onDeviceTranslator.translateText(text);
      setState(() {
        _translatedText = translatedText;
      });
    } catch (e) {
      _logger.e('Error translating text: $e');
    }
  }

  void _toggleProcessing() {
    setState(() {
      _isProcessingEnabled = !_isProcessingEnabled;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    textRecognizer.close();
    onDeviceTranslator.close();
    _processingTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
          Container(
            height: screenHeight / 3,
            width: double.infinity,
            child: _controller == null || !_controller!.value.isInitialized
                ? const Center(child: CircularProgressIndicator())
                : CameraPreview(_controller!),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isProcessingEnabled ? _toggleProcessing : null,
                child: const Text('Stop'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: !_isProcessingEnabled ? _toggleProcessing : null,
                child: const Text('Play'),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recognized Text:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _recognizedText,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Divider(height: 32, thickness: 1),
                  const Text(
                    'Translated Text:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _translatedText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
