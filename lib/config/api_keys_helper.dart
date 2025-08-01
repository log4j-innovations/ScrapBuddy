import 'package:flutter/services.dart';

class ApiKeysHelper {
  static const MethodChannel _channel = MethodChannel('api_keys_channel');
  
  static String? _vertexAIKey;
  static String? _sarvamAIKey;
  
  // Load API keys from Android resources
  static Future<void> loadApiKeys() async {
    try {
      // Try to load from native platform
      final vertexKey = await _channel.invokeMethod<String>('getVertexAIKey');
      final sarvamKey = await _channel.invokeMethod<String>('getSarvamAIKey');
      
      if (vertexKey != null && sarvamKey != null) {
        _vertexAIKey = vertexKey;
        _sarvamAIKey = sarvamKey;
        print('✅ API keys loaded successfully from secrets.xml');
        return;
      }
    } catch (e) {
      print('❌ Error loading API keys from platform: $e');
    }

    // Use fallback keys if loading fails
    print('⚠️ Using fallback API keys');
    _vertexAIKey = 'AIzaSyCVOs81A4E9PTELfPjbq3Aodo42vXWc_YE';
    _sarvamAIKey = 'sk_lv0yw89o_t9ka4hdg9HMfP4RsC854EL7O';
  }
  
  static String get vertexAIKey => _vertexAIKey ?? 'AIzaSyCVOs81A4E9PTELfPjbq3Aodo42vXWc_YE';
  static String get sarvamAIKey => _sarvamAIKey ?? 'sk_lv0yw89o_t9ka4hdg9HMfP4RsC854EL7O';
}
