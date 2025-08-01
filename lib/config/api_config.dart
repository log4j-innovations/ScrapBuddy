import 'api_keys_helper.dart';

class VertexAIConfig {
  static const String baseUrl = 'https://generativelanguage.googleapis.com';
  
  static String get vertexAIKey => ApiKeysHelper.vertexAIKey;
  static String get sarvamAIKey => ApiKeysHelper.sarvamAIKey;
  
  static String get appName => 'ScrapBuddy';
  static String get appVersion => '1.0.0';
  static String get environment => 'development';
  
  static String get modelEndpoint {
    return '$baseUrl/v1beta/models/gemini-2.0-flash:generateContent?key=${vertexAIKey}';
  }
  
  static bool validateApiKeys() {
    return vertexAIKey.isNotEmpty && sarvamAIKey.isNotEmpty;
  }
}
