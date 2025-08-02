import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/waste_classification.dart';

class OfflineClassifierService {
  static Interpreter? _interpreter;
  static List<String>? _labels;
  static const int INPUT_SIZE = 224;

  static Future<void> initialize() async {
    try {
      // Load TFLite model
      //_interpreter = await Interpreter.fromAsset('assets/models/model_unquant.tflite');
      _interpreter = await Interpreter.fromAsset('assets/tflite/model_unquant.tflite');

      
      // Load labels
      //final labelFile = await File('assets/models/labels.txt').readAsString();
      final labelFile = await rootBundle.loadString('assets/tflite/labels.txt');

      _labels = labelFile.split('\n');
      
      print('✅ Offline classifier initialized successfully');
    } catch (e) {
      print('❌ Error initializing offline classifier: $e');
      _interpreter = null;
      _labels = null;
    }
  }

  static bool get isInitialized => _interpreter != null && _labels != null;

  static Future<WasteClassification?> classifyImage(File imageFile) async {
    if (!isInitialized) {
      print('❌ Offline classifier not initialized');
      return null;
    }

    try {
      // Load and preprocess image
      final image = img.decodeImage(await imageFile.readAsBytes());
      if (image == null) return null;

      // Resize image to 224x224
      final resizedImage = img.copyResize(image, width: INPUT_SIZE, height: INPUT_SIZE);
      
      // Convert to float32 array and normalize to [0,1]
      var input = List.generate(
        1,
        (index) => List.generate(
          INPUT_SIZE,
          (y) => List.generate(
            INPUT_SIZE,
            (x) {
              final pixel = resizedImage.getPixel(x, y);
              return [
                pixel.r.toDouble() / 255.0,  // Red
                pixel.g.toDouble() / 255.0,  // Green
                pixel.b.toDouble() / 255.0,  // Blue
              ];
            },
          ),
        ),
      );

      // Output tensor shape [1, NUM_CLASSES]
      final output = List.filled(1 * _labels!.length, 0).reshape([1, _labels!.length]);

      // Run inference
      _interpreter!.run(input, output);

      // Get prediction
      final result = List<double>.from(output[0]);
      final maxScore = result.reduce((a, b) => a > b ? a : b);
      final predictedIndex = result.indexOf(maxScore);
      final predictedLabel = _labels![predictedIndex].trim();

      // Map to waste classification
      final disposalInstructions = _getDisposalInstructions(predictedLabel);
      final monetaryValue = _getEstimatedValue(predictedLabel);

      return WasteClassification(
        wasteType: predictedLabel.toLowerCase(),
        itemName: 'Detected ${predictedLabel.toLowerCase()} waste',
        recyclability: _getRecyclability(predictedLabel),
        monetaryValue: monetaryValue,
        disposalInstructions: disposalInstructions,
        confidence: maxScore,
      );

    } catch (e) {
      print('❌ Error during offline classification: $e');
      return null;
    }
  }

  static String _getRecyclability(String wasteType) {
    switch (wasteType.toLowerCase()) {
      case 'plastic':
      case 'glass':
      case 'metal':
      case 'paper':
      case 'cardboard':
        return 'recyclable';
      default:
        return 'non-recyclable';
    }
  }

  static int _getEstimatedValue(String wasteType) {
    switch (wasteType.toLowerCase()) {
      case 'plastic':
        return 5;
      case 'glass':
        return 3;
      case 'metal':
        return 10;
      case 'paper':
      case 'cardboard':
        return 2;
      default:
        return 0;
    }
  }

  static String _getDisposalInstructions(String wasteType) {
    switch (wasteType.toLowerCase()) {
      case 'plastic':
        return 'Clean the plastic item thoroughly to remove any contaminants. Check for recycling number and place in designated plastic recycling bin. If not recyclable locally, dispose in regular waste.';
      case 'glass':
        return 'Handle glass items with care. Remove any non-glass components. Rinse thoroughly and place in glass recycling bin. Avoid breaking to prevent injury.';
      case 'metal':
        return 'Clean metal items and remove any non-metal parts. Check if item is magnetic (ferrous) or non-magnetic (non-ferrous). Place in appropriate metal recycling bin.';
      case 'paper':
        return 'Keep paper dry and clean. Remove any plastic or metal attachments. Flatten cardboard boxes. Place in paper recycling bin.';
      case 'cardboard':
        return 'Break down cardboard boxes to save space. Remove any tape, staples, or plastic. Keep dry and clean. Place in cardboard recycling bin.';
      default:
        return 'Check local waste management guidelines for proper disposal instructions.';
    }
  }
}