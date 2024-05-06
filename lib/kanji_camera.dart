import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class KanjiCameraWidget extends StatefulWidget {
  const KanjiCameraWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _KanjiCameraWidgetState createState() => _KanjiCameraWidgetState();
}

class _KanjiCameraWidgetState extends State<KanjiCameraWidget> {
  CameraController? controller;
  List<CameraDescription> cameras = [];
  final TextRecognizer textRecognizer = TextRecognizer(script: TextRecognitionScript.japanese);
  String recognizedText = "";

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      controller = CameraController(cameras[0], ResolutionPreset.high);
      await controller?.initialize();
      setState(() {});
      controller?.startImageStream((CameraImage image) async {
        // Process image for text recognition
        recognizeTextFromImage(image);
      });
    }
  }

  Future<void> recognizeTextFromImage(CameraImage cameraImage) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());
    final InputImageRotation imageRotation = InputImageRotationMethods.fromRawValue(controller!.description.sensorOrientation) ?? InputImageRotation.rotation0deg;
    final InputImageFormat imageFormat = InputImageFormatMethods.fromRawValue(cameraImage.format.raw) ?? InputImageFormat.nv21;
    final int bytesPerRow = cameraImage.planes.first.bytesPerRow;

    // Prepare metadata for the image
    final inputImageMetadata = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: imageFormat,
      bytesPerRow: bytesPerRow,
    );

    // Create an InputImage for text recognition
    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: inputImageMetadata
    );

    try {
      final RecognizedText results = await textRecognizer.processImage(inputImage);
      setState(() {
        recognizedText = results.text;
      });
    } catch (e) {
      print('Error recognizing text: $e');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kanji Camera"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: controller == null || !controller!.value.isInitialized
              ? const Center(child: CircularProgressIndicator())
              : AspectRatio(
                  aspectRatio: controller!.value.aspectRatio,
                  child: CameraPreview(controller!),
                ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              recognizedText,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class InputImageRotationMethods {
  static InputImageRotation? fromRawValue(int? sensorOrientation) {
    switch (sensorOrientation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return null;
    }
  }
}

class InputImageFormatMethods {
  static InputImageFormat? fromRawValue(int? rawValue) {
    switch (rawValue) {
      case 35: // YUV_420_888 on Android
        return InputImageFormat.yuv420;
      default:
        return InputImageFormat.nv21; // A common format as fallback
    }
  }
}
