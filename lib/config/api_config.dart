import 'package:flutter_dotenv/flutter_dotenv.dart';

class VertexAIConfig {
  // Using Gemini API endpoint but maintaining Vertex AI naming
  static const String baseUrl = 'https://generativelanguage.googleapis.com';
  
  static String get vertexAIKey {
    return dotenv.env['VERTEX_AI_API_KEY'] ?? '';
  }
  
  static String get sarvamAIKey {
    return dotenv.env['SARVAM_API_KEY'] ?? '';
  }
  
  static String get appName {
    return dotenv.env['APP_NAME'] ?? 'ScrapBuddy';
  }
  
  static String get appVersion {
    return dotenv.env['APP_VERSION'] ?? '1.0.0';
  }
  
  static String get environment {
    return dotenv.env['ENVIRONMENT'] ?? 'development';
  }
  
  // Vertex AI model endpoint (using Gemini 2.0 Flash)
  static String get modelEndpoint {
    return '$baseUrl/v1beta/models/gemini-2.0-flash:generateContent?key=${vertexAIKey}';
  }
  
  // Validation method
  static bool validateApiKeys() {
    return vertexAIKey.isNotEmpty && sarvamAIKey.isNotEmpty;
  }
}
