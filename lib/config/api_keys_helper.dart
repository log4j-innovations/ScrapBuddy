import 'package:flutter/services.dart';

class ApiKeysHelper {
  static const MethodChannel _channel = MethodChannel('api_keys_channel');
  
  static String? _vertexAIKey;
  static String? _sarvamAIKey;
  
  // Load API keys from Android resources
  static Future<void> loadApiKeys() async {
    try {
      _vertexAIKey = await _channel.invokeMethod('getVertexAIKey');
      _sarvamAIKey = await _channel.invokeMethod('getSarvamAIKey');
      print('✅ API keys loaded successfully from secrets.xml');
    } catch (e) {
      print('❌ Error loading API keys: $e');
      // Use fallback keys if loading fails
      _vertexAIKey = 'AIzaSyCVOs81A4E9PTELfPjbq3Aodo42vXWc_YE';
      _sarvamAIKey = 'sk_lv0yw89o_t9ka4hdg9HMfP4RsC854EL7O';
    }
  }
  
  static String get vertexAIKey => _vertexAIKey ?? 'AIzaSyCVOs81A4E9PTELfPjbq3Aodo42vXWc_YE';
  static String get sarvamAIKey => _sarvamAIKey ?? 'sk_lv0yw89o_t9ka4hdg9HMfP4RsC854EL7O';
}
