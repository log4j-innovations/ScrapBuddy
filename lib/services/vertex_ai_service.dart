import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/waste_classification.dart';
import '../config/api_config.dart';

class VertexAIService {
  // Restricted waste classes
  static const List<String> _allowedWasteTypes = [
    'plastic',
    'paper', 
    'metal',
    'trash',
    'biological',
    'glass',
    'battery',
    'e-waste'
  ];

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

  // Updated classification prompts with restricted categories
  static const Map<String, String> _classificationPrompts = {
    'hi': '''इस कचरे की तस्वीर का विश्लेषण करें और केवल इन श्रेणियों में से एक में वर्गीकृत करें:

ALLOWED CATEGORIES ONLY: plastic, paper, metal, trash, biological, glass, battery, e-waste

1. कचरे का प्रकार (केवल ऊपर दी गई 8 श्रेणियों में से एक चुनें)
2. विशिष्ट वस्तु का नाम (जैसे "प्लास्टिक की पानी की बोतल")
3. पुनर्चक्रण स्थिति (पुनर्चक्रण योग्य/गैर-पुनर्चक्रण योग्य/कंपोस्ट योग्य)
4. भारतीय रुपये में अनुमानित मूल्य (0-100 की रेंज में)
5. निपटान निर्देश (1-2 वाक्यों में)

JSON प्रारूप में उत्तर दें: wasteType, itemName, recyclability, monetaryValue, disposalInstructions

महत्वपूर्ण: wasteType में केवल ये शब्द उपयोग करें: plastic, paper, metal, trash, biological, glass, battery, e-waste''',
    
    'ta': '''இந்த கழிவுப் படத்தை பகுப்பாய்வு செய்து கீழ்கண்ட வகைகளில் மட்டும் வகைப்படுத்தவும்:

ALLOWED CATEGORIES ONLY: plastic, paper, metal, trash, biological, glass, battery, e-waste

1. கழிவு வகை (மேலே உள்ள 8 வகைகளில் ஒன்றை மட்டும் தேர்ந்தெடுக்கவும்)
2. குறிப்பிட்ட பொருளின் பெயர்
3. மறுசுழற்சி நிலை
4. இந்திய ரூபாயில் மதிப்பீட்டு மூல்य (0-100 வரம்பில்)
5. அகற்றல் வழிமுறைகள் (1-2 வாக்கியங்களில்)

JSON வடிவத்தில் பதிலளிக்கவும்: wasteType, itemName, recyclability, monetaryValue, disposalInstructions

முக்கியமானது: wasteType இல் இந்த வார்த்தைகளை மட்டும் பயன்படுத்தவும்: plastic, paper, metal, trash, biological, glass, battery, e-waste''',
    
    'te': '''ఈ వ్యర్థ చిత్రాన్ని విశ్లేషించి కింది వర్గాలలో మాత్రమే వర్గీకరించండి:

ALLOWED CATEGORIES ONLY: plastic, paper, metal, trash, biological, glass, battery, e-waste

1. వ్యర్థ రకం (పైన ఉన్న 8 వర్గాలలో ఒకదాన్ని మాత్రమే ఎంచుకోండి)
2. నిర్దిష్ట వస్తువు పేరు
3. రీసైక్లింగ్ స్థితి
4. భారతీయ రూపాయలలో అంచనా విలువ (0-100 పరిధిలో)
5. పారవేయడం సూచనలు (1-2 వాక్యాలలో)

JSON ఆకృతిలో సమాధానం ఇవండి: wasteType, itemName, recyclability, monetaryValue, disposalInstructions

ముఖ్యమైనది: wasteType లో ఈ పదాలను మాత్రమే ఉపయోగించండి: plastic, paper, metal, trash, biological, glass, battery, e-waste''',
    
    'en': '''Analyze this waste image and classify it into ONE of these categories ONLY:

ALLOWED CATEGORIES ONLY: plastic, paper, metal, trash, biological, glass, battery, e-waste

1. Waste type (choose only from the 8 categories above)
2. Specific item name (e.g., "Plastic Water Bottle")
3. Recyclability status (recyclable/non-recyclable/compostable)
4. Estimated monetary value in INR (0-100 range)
5. Disposal instructions in 1-2 sentences

Format your response as JSON with keys: wasteType, itemName, recyclability, monetaryValue, disposalInstructions

IMPORTANT: Use only these exact words for wasteType: plastic, paper, metal, trash, biological, glass, battery, e-waste''',
  };

  Future<WasteClassification?> classifyWaste(File imageFile) async {
    try {
      if (!VertexAIConfig.validateApiKeys()) {
        throw Exception('API keys not configured. Please check secrets.xml file.');
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String selectedLanguage = prefs.getString('selected_language') ?? 'hi';
      print('Selected language from preferences: $selectedLanguage');

      String base64Image = base64Encode(await imageFile.readAsBytes());
      
      String prompt = _classificationPrompts[selectedLanguage] ?? _classificationPrompts['en']!;
      
      // Call Vertex AI
      final vertexResponse = await http.post(
        Uri.parse(VertexAIConfig.modelEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [{
            'parts': [
              {'text': prompt},
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
          
          // Validate waste type against allowed categories
          if (!_allowedWasteTypes.contains(classification.wasteType.toLowerCase())) {
            print('Invalid waste type: ${classification.wasteType}, defaulting to trash');
            classification = WasteClassification(
              wasteType: "trash",
              itemName: classification.itemName,
              recyclability: classification.recyclability,
              monetaryValue: classification.monetaryValue,
              disposalInstructions: classification.disposalInstructions,
            );
          }
        } else {
          throw Exception('No JSON found in Vertex AI response');
        }
      } catch (e) {
        print('JSON parsing error: $e');
        classification = WasteClassification(
          wasteType: "trash",
          itemName: "Mixed Waste Item",
          recyclability: "check local guidelines",
          monetaryValue: 5,
          disposalInstructions: "Sort items properly before disposal according to local guidelines.",
        );
      }

      // Translate results
      String? translatedName = classification.itemName;
      String? translatedInstructions = classification.disposalInstructions;

      if (selectedLanguage != 'en') {
        try {
          translatedName = await _translateText(classification.itemName, selectedLanguage);
          translatedInstructions = await _translateText(classification.disposalInstructions, selectedLanguage);
        } catch (e) {
          print('Translation failed, using fallback: $e');
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
          'api-subscription-key': VertexAIConfig.sarvamAIKey,
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
        return translationData['translated_text'];
      }
      return null;
    } catch (e) {
      print('Translation error: $e');
      return null;
    }
  }

  String? _getFallbackTranslation(String text, String language) {
    final Map<String, Map<String, String>> fallbackTranslations = {
      'hi': {
        'Plastic Water Bottle': 'प्लास्टिक पानी की बोतल',
        'Glass Jar': 'कांच का जार',
        'Aluminum Can': 'एल्युमिनियम कैन',
        'Paper': 'कागज़',
        'Metal': 'धातु',
        'Glass': 'कांच',
        'Plastic': 'प्लास्टिक',
        'Battery': 'बैटरी',
        'E-waste': 'इलेक्ट्रॉनिक कचरा',
        'Biological': 'जैविक',
        'Trash': 'कचरा',
      },
      'ta': {
        'Plastic Water Bottle': 'பிளாஸ்டிக் தண்ணீர் பாட்டில்',
        'Glass Jar': 'கண்ணாடி ஜார்',
        'Aluminum Can': 'அலுமினியம் கேன்',
        'Paper': 'காகிதம்',
        'Metal': 'உலோகம்',
        'Glass': 'கண்ணாடி',
        'Plastic': 'பிளாஸ்டிக்',
        'Battery': 'பேட்டரி',
        'E-waste': 'மின்னணு கழிவு',
        'Biological': 'இயற்கை',
        'Trash': 'குப்பை',
      },
      'te': {
        'Plastic Water Bottle': 'ప్లాస్టిక్ వాటర్ బాటిల్',
        'Glass Jar': 'గ్లాస్ జార్',
        'Aluminum Can': 'అల్యూమినియం క్యాన్',
        'Paper': 'కాగితం',
        'Metal': 'లోహం',
        'Glass': 'గాజు',
        'Plastic': 'ప్లాస్టిక్',
        'Battery': 'బ్యాటరీ',
        'E-waste': 'ఎలక్ట్రానిక్ వ్యర్థాలు',
        'Biological': 'సేంద్రీయ',
        'Trash': 'చెత్త',
      },
    };

    return fallbackTranslations[language]?[text];
  }

  Future<String?> getTextToSpeechBase64(String text, String language) async {
    try {
      final languageCode = _languageCodeMap[language] ?? 'hi-IN';
      
      final ttsResponse = await http.post(
        Uri.parse('https://api.sarvam.ai/text-to-speech'),
        headers: {
          'api-subscription-key': VertexAIConfig.sarvamAIKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'text': text,
          'target_language_code': languageCode,
          'speaker': 'manisha',
          'model': 'bulbul:v2',
          'output_audio_codec': 'wav'
        }),
      );

      if (ttsResponse.statusCode == 200) {
        final ttsData = json.decode(ttsResponse.body);
        if (ttsData['audios'] != null && ttsData['audios'].isNotEmpty) {
          return ttsData['audios'][0];
        }
      }
      return null;
    } catch (e) {
      print('TTS error: $e');
      return null;
    }
  }
}
