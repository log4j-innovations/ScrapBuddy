import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/waste_classification.dart';
import '../config/api_config.dart';

class VertexAIService {
  // Language mapping for Sarvam API
  static const Map<String, String> _languageCodeMap = {
    'hi': 'hi-IN',
    'en': 'en-IN',
    'ta': 'ta-IN',
    'te': 'te-IN',
    'bn': 'bn-IN',
    'mr': 'mr-IN',
    'gu': 'gu-IN',
    'kn': 'kn-IN',
  };

  // Prompts in user's native language for better classification
  static const Map<String, String> _classificationPrompts = {
    'hi': '''इस कचरे की तस्वीर का विश्लेषण करें और वर्गीकरण करें:

1. कचरे का प्रकार (प्लास्टिक, कांच, धातु, कागज, जैविक, इलेक्ट्रॉनिक, कपड़ा आदि)
2. विशिष्ट वस्तु का नाम (जैसे "प्लास्टिक की पानी की बोतल", "कांच का जार")
3. पुनर्चक्रण स्थिति (पुनर्चक्रण योग्य/गैर-पुनर्चक्रण योग्य/कंपोस्ट योग्य)
4. भारतीय रुपये में अनुमानित मूल्य (0-100 की रेंज में)
5. निपटान निर्देश (1-2 वाक्यों में)

JSON प्रारूप में उत्तर दें: wasteType, itemName, recyclability, monetaryValue, disposalInstructions''',
    
    'ta': '''இந்த கழிவுப் படத்தை பகுப்பாய்வு செய்து வகைப்படுத்தவும்:

1. கழிவு வகை (பிளாஸ்டிக், கண்ணாடி, உலோகம், காகிதம், இயற்கை, மின்னணு, துணி போன்றவை)
2. குறிப்பிட்ட பொருளின் பெயர்
3. மறுசுழற்சி நிலை
4. இந்திய ரூபாயில் மதிப்பீட்டு மூல்য (0-100 வரம்பில்)
5. அகற்றல் வழிமுறைகள் (1-2 வாக்கியங்களில்)

JSON வடிவத்தில் பதிலளிக்கவும்: wasteType, itemName, recyclability, monetaryValue, disposalInstructions''',
    
    'te': '''ఈ వ్యర్థ చిత్రాన్ని విశ్లేషించి వర్గీకరించండి:

1. వ్యర్థ రకం (ప్లాస్టిక్, గ్లాస్, లోహం, కాగితం, సేంద్రీయ, ఎలక్ట్రానిక్, వస్త్రం మొదలైనవి)
2. నిర్దిష్ట వస్తువు పేరు
3. రీసైక్లింగ్ స్థితి
4. భారతీయ రూపాయలలో అంచనా విలువ (0-100 పరిధిలో)
5. పారవేయడం సూచనలు (1-2 వాక్యాలలో)

JSON ఆకృతిలో సమాధానం ఇవండి: wasteType, itemName, recyclability, monetaryValue, disposalInstructions''',
    
    'en': '''Analyze this waste image and provide detailed classification:

1. Waste type (plastic, glass, metal, paper, organic, e-waste, textile, etc.)
2. Specific item name (e.g., "Plastic Water Bottle", "Glass Jar", "Aluminum Can")
3. Recyclability status (recyclable/non-recyclable/compostable)
4. Estimated monetary value in INR (0-100 range)
5. Disposal instructions in 1-2 sentences

Format your response as JSON with keys: wasteType, itemName, recyclability, monetaryValue, disposalInstructions''',
  };

  Future<WasteClassification?> classifyWaste(File imageFile) async {
    try {
      // Validate API keys before making requests
      if (!VertexAIConfig.validateApiKeys()) {
        throw Exception('API keys not configured. Please check .env file.');
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String selectedLanguage = prefs.getString('selected_language') ?? 'hi';
      print('Selected language from preferences: $selectedLanguage');

      String base64Image = base64Encode(await imageFile.readAsBytes());
      
      // Use classification prompt in user's selected language
      String prompt = _classificationPrompts[selectedLanguage] ?? _classificationPrompts['en']!;
      
      // Call Vertex AI (Gemini 2.0 Flash) for classification
      final vertexResponse = await http.post(
        Uri.parse(VertexAIConfig.modelEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [{
            'parts': [
              {
                'text': prompt
              },
              {
                'inlineData': {
                  'mimeType': 'image/jpeg',
                  'data': base64Image
                }
              }
            ]
          }],
          'generationConfig': {
            'temperature': 0.1,
            'topK': 32,
            'topP': 1,
            'maxOutputTokens': 2048,
          }
        }),
      );

      if (vertexResponse.statusCode != 200) {
        throw Exception('Vertex AI API failed: ${vertexResponse.statusCode}');
      }

      final vertexData = json.decode(vertexResponse.body);
      
      if (vertexData['candidates'] == null || vertexData['candidates'].isEmpty) {
        throw Exception('No classification results from Vertex AI');
      }
      
      final responseText = vertexData['candidates'][0]['content']['parts'][0]['text'];
      print('Vertex AI Response: $responseText');
      
      WasteClassification classification;
      try {
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(responseText);
        if (jsonMatch != null) {
          final jsonStr = jsonMatch.group(0)!;
          final classificationJson = json.decode(jsonStr);
          classification = WasteClassification.fromJson(classificationJson);
        } else {
          throw Exception('No JSON found in Vertex AI response');
        }
      } catch (e) {
        print('JSON parsing error: $e');
        classification = WasteClassification(
          wasteType: "Mixed Waste",
          itemName: responseText.length > 50 ? responseText.substring(0, 50) : responseText,
          recyclability: "check local guidelines",
          monetaryValue: 5,
          disposalInstructions: "Sort items properly before disposal according to local guidelines.",
        );
      }

      // If response is already in target language, use it directly
      // Otherwise, translate using fallback system
      String? translatedName = classification.itemName;
      String? translatedInstructions = classification.disposalInstructions;

      if (selectedLanguage != 'en') {
        // Try to use Sarvam AI for translation first
        try {
          translatedName = await _translateText(classification.itemName, selectedLanguage);
          translatedInstructions = await _translateText(classification.disposalInstructions, selectedLanguage);
        } catch (e) {
          print('Sarvam translation failed, using fallback: $e');
          // Use fallback translations
          translatedName = _getFallbackTranslation(classification.itemName, selectedLanguage);
          translatedInstructions = _getFallbackTranslation(classification.disposalInstructions, selectedLanguage);
        }
      }

      return WasteClassification(
        wasteType: classification.wasteType,
        itemName: classification.itemName,
        recyclability: classification.recyclability,
        monetaryValue: classification.monetaryValue,
        disposalInstructions: classification.disposalInstructions,
        translatedName: translatedName ?? classification.itemName,
        translatedInstructions: translatedInstructions ?? classification.disposalInstructions,
      );

    } catch (e) {
      print('Vertex AI classification error: $e');
      return null;
    }
  }

  Future<String?> _translateText(String text, String targetLanguage) async {
    try {
      final targetLangCode = _languageCodeMap[targetLanguage] ?? 'hi-IN';
      
      final translationResponse = await http.post(
        Uri.parse('https://api.sarvam.ai/translate'),
        headers: {
          'api-subscription-key': VertexAIConfig.sarvamAIKey, // Using config
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'input': text,
          'source_language_code': 'en-IN',
          'target_language_code': targetLangCode,
          'speaker_gender': 'Male',
          'mode': 'formal'
        }),
      );

      if (translationResponse.statusCode == 200) {
        final translationData = json.decode(translationResponse.body);
        print('Translation successful: ${translationData['translated_text']}');
        return translationData['translated_text'];
      } else {
        print('Translation failed: ${translationResponse.statusCode} - ${translationResponse.body}');
      }
      return null;
    } catch (e) {
      print('Translation error: $e');
      return null;
    }
  }

  // Fallback translation system
  String? _getFallbackTranslation(String text, String language) {
    final Map<String, Map<String, String>> fallbackTranslations = {
      'hi': {
        'Plastic Water Bottle': 'प्लास्टिक पानी की बोतल',
        'Glass Jar': 'कांच का जार',
        'Aluminum Can': 'एल्युमिनियम कैन',
        'Paper': 'कागज़',
        'Cardboard': 'गत्ता',
        'Metal': 'धातु',
        'Glass': 'कांच',
        'Plastic': 'प्लास्टिक',
        'Organic': 'जैविक',
        'E-waste': 'इलेक्ट्रॉनिक कचरा',
        'Textile': 'कपड़ा',
        'Empty and rinse the bottle. Dispose of it in a designated recycling bin.': 'बोतल को खाली करके धो लें। इसे निर्दिष्ट रीसाइक्लिंग बिन में डालें।',
      },
      'ta': {
        'Plastic Water Bottle': 'பிளாஸ்டிக் தண்ணீர் பாட்டில்',
        'Glass Jar': 'கண்ணாடி ஜார்',
        'Aluminum Can': 'அலுமினியம் கேன்',
        'Paper': 'காகிதம்',
        'Cardboard': 'அட்டை',
      },
      'te': {
        'Plastic Water Bottle': 'ప్లాస్టిక్ వాటర్ బాటిల్',
        'Glass Jar': 'గ్లాస్ జార్',
        'Aluminum Can': 'అల్యూమినియం క్యాన్',
        'Paper': 'కాగితం',
        'Cardboard': 'కార్డ్‌బోర్డ్',
      },
    };

    if (fallbackTranslations.containsKey(language)) {
      return fallbackTranslations[language]![text];
    }
    return null;
  }

  Future<String?> getTextToSpeechBase64(String text, String language) async {
    try {
      final languageCode = _languageCodeMap[language] ?? 'hi-IN';
      print('Getting TTS for text: "$text" in language: $languageCode');

      final ttsResponse = await http.post(
        Uri.parse('https://api.sarvam.ai/text-to-speech'),
        headers: {
          'api-subscription-key': VertexAIConfig.sarvamAIKey,  // Using config
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'text': text,
          'target_language_code': languageCode,
          'speaker': 'manisha',  // Use valid speaker name
          'model': 'bulbul:v2',  // Use v2 model
          'output_audio_codec': 'wav'  // Specify audio format
        }),
      );

      print('TTS Response Status: ${ttsResponse.statusCode}');
      print('TTS Response Body: ${ttsResponse.body}');

      if (ttsResponse.statusCode == 200) {
        final ttsData = json.decode(ttsResponse.body);
        if (ttsData['audios'] != null && ttsData['audios'].isNotEmpty) {
          return ttsData['audios'][0];  // Returns base64 encoded audio
        }
      } else {
        print('TTS API Error: ${ttsResponse.statusCode} - ${ttsResponse.body}');
      }
      return null;
    } catch (e) {
      print('Sarvam AI TTS error: $e');
      return null;
    }
  }
}
