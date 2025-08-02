import 'package:flutter/services.dart';

class OfflineResources {
  static const Map<String, Map<String, String>> wasteTypeTranslations = {
    'plastic': {
      'hi': 'प्लास्टिक',
      'ta': 'பிளாஸ்டிக்',
      'te': 'ప్లాస్టిక్',
    },
    'paper': {
      'hi': 'कागज',
      'ta': 'காகிதம்',
      'te': 'కాగితం',
    },
    'metal': {
      'hi': 'धातु',
      'ta': 'உலோகம்',
      'te': 'లోహం',
    },
    'glass': {
      'hi': 'कांच',
      'ta': 'கண்ணாடி',
      'te': 'గాజు',
    },
    'cardboard': {
      'hi': 'गत्ता',
      'ta': 'அட்டை',
      'te': 'కార్డ్‌బోర్డ్',
    }
  };

  static const Map<String, Map<String, String>> disposalInstructions = {
    'plastic': {
      'en': 'Plastic can be recycled if it\'s clean. Keep water and cold drink bottles separate from shampoo or oil bottles. Keep food wrappers like chips packets in a different bag.',
      'hi': 'प्लास्टिक साफ़ प्लास्टिक को रिसायकल किया जा सकता है। पानी और कोल्ड ड्रिंक की बोतलें शैम्पू या तेल की बोतलों से अलग रखें। चिप्स जैसे खाने के रैपर अलग बैग में रखें।',
      'ta': 'பிளாஸ்டிக் சுத்தமான பிளாஸ்டிக் மறுசுழற்சி செய்யலாம். தண்ணீர் மற்றும் குளிர்பான பாட்டில்களை, ஷாம்பு அல்லது எண்ணெய் பாட்டில்களிலிருந்து தனியாக வையுங்கள். சிப்ஸ் பேக்கெட்டுகள் போன்ற உணவு ரப்பர்களை வேறொரு பையில் வையுங்கள்.',
      'te': 'ప్లాస్టిక్ శుభ్రంగా ఉన్న ప్లాస్టిక్ రీసైకిల్ చేయవచ్చు. నీరు లేదా శీతల పానీయాల బాటిల్స్‌ను, షాంపూ లేదా ఆయిల్ బాటిల్స్ నుంచి వేరు పెట్టండి. చిప్స్ వంటి ప్యాకెట్లు వేరే సంచిలో వేసేయండి.',
      'hinglish': 'Plastic Saaf plastic recycle ho sakta hai. Pani aur cold drink ki bottles alag rakhni chahiye shampoo ya tel ki bottles se. Chips ke wrappers ko ek alag bag mein daalna better hota hai.',
    },
    'metal': {
      'en': 'Separate aluminum cans from heavy items like utensils or tins. Remove rubber or plastic if attached. Keep metals dry for better value.',
      'hi': 'धातु (मेटल) एलुमिनियम के डिब्बों को भारी सामान जैसे बर्तनों से अलग करें। यदि धातु में रबर या प्लास्टिक जुड़ा हो तो निकाल दें। धातु को सूखा रखें ताकि ज़्यादा पैसे मिलें।',
      'ta': 'லோஹம் (Metal) அலுமினியம் டின்களை, பானைகள் அல்லது கனமான உபகரணங்களில் இருந்து பிரித்துவையுங்கள். ரப்பர் அல்லது பிளாஸ்டிக் இருந்தால் அதை அகற்றுங்கள். லோகங்களை வற்றவையாக வைத்தால் மதிப்பு அதிகம் கிடைக்கும்.',
      'te': 'లోహం (Metal) అల్యూమినియం డబ్బాలను బరువు సామగ్రి నుండి వేరు చేయండి. ప్లాస్టిక్ లేదా రబ్బరు ఉంటే తీసేయండి. లోహాలను పొడి గానీ శుభ్రంగా ఉంచితే మంచి ధర వస్తుంది.',
      'hinglish': 'Metal Aluminum cans ko heavy cheezon jaise bartans se alag rakho. Agar rubber ya plastic laga ho toh nikaal do. Metal ko dry rakhna accha rehta hai — price bhi better milta hai.',
    },
    'paper': {
      'en': 'Only collect dry and clean paper. Separate white paper, newspaper, and glossy magazine paper. Do not collect oily or wet paper.',
      'hi': 'कागज़ सिर्फ़ सूखा और साफ़ कागज़ ही इकट्ठा करें। सादा कागज़, अख़बार और चमकदार (ग्लॉसी) कागज़ अलग-अलग रखें। गीला या तेल वाला कागज़ न उठाएँ।',
      'ta': 'காகிதம் சுத்தமான, உலர்ந்த காகிதங்களையே சேகரிக்கவும். வெள்ளை காகிதம், செய்தித்தாள் மற்றும் பளபளப்பான மாகஸின் காகிதங்களை தனித்து வையுங்கள். ஈரமான அல்லது எண்ணெய் சாய்ந்த காகிதங்களை எடுக்க வேண்டாம்.',
      'te': 'కాగితం కేవలం పొడి మరియు శుభ్రమైన కాగితమే తీసుకోండి. తెల్ల కాగితం, పత్రికలు, మెరిసే పత్రాలు వేరుగా ఉంచండి. తేమతో ఉన్న కాగితాన్ని తీసుకోవద్దు.',
      'hinglish': 'Paper Sirf dry aur clean paper uthana chahiye. White paper, newspaper, aur glossy magazine paper ko alag-alag rakhna helpful hota hai. Wet ya oily paper ka koi use nahi hota.',
    },
    'cardboard': {
      'en': 'Fold boxes flat to save space. Clean and dry cardboard is recyclable. Avoid collecting food-stained cardboard.',
      'hi': 'गत्ते (कार्डबोर्ड) डिब्बों को मोड़कर सपाट कर लें ताकि जगह बचे। साफ़ और सूखा गत्ता रिसायकल किया जा सकता है। तेल या खाने से गंदा हुआ गत्ता न लें।',
      'ta': 'கார்ட்போர்ட் பெட்டிகளை மடித்து செங்கோணமாக வையுங்கள். சுத்தமான, உலர்ந்த கார்ட்போர்டு மறுசுழற்சி செய்யலாம். உணவால் களங்கம் அடைந்த கார்ட்போர்டுகளை தவிர்க்கவும்.',
      'te': 'కార్డ్బోర్డు బాక్సులను మడతపెట్టి నిల్వచేయండి. శుభ్రంగా ఉన్న, పొడి కార్డ్బోర్డ్ రీసైకిల్ చేయవచ్చు. ఆహారంతో నిండిన లేదా నూనెతడి కార్డ్బోర్డును తీసుకోవద్దు.',
      'hinglish': 'Cardboard Boxes ko fold kar lena chahiye taaki space bache. Clean aur dry cardboard recycle hota hai. Jo cardboard oily ho ya food laga ho, usse avoid karna better hota hai.',
    },
    'glass': {
      'en': 'Collect unbroken, clean bottles. Separate by color if possible — clear, green, brown. Do not mix glass with ceramics or tiles.',
      'hi': 'काँच (ग्लास) साफ़ और साबुत बोतलें ही उठाएँ। संभव हो तो रंग के अनुसार अलग रखें — सफ़ेद, हरा, भूरा। काँच को टाइल्स या सिरेमिक के साथ न मिलाएँ।',
      'ta': 'கண்ணாடி முறிவில்லாத, சுத்தமான பாட்டில்களை மட்டும் சேகரிக்கவும். வண்ணத்தின்படி பிரிக்க முடிந்தால் — வெண்மையானது, பச்சை, பழுப்பு. கண்ணாடியை சீராமிக் அல்லது டைல்ஸுடன் கலக்க வேண்டாம்.',
      'te': 'గాజు పగలకుండా ఉన్న, శుభ్రమైన బాటిళ్లను మాత్రమే తీసుకోండి. వర్ణాల ప్రకారం వేరు చేయగలిగితే — తెల్ల, ఆకుపచ్చ, గోధుమ రంగు. సిరామిక్ లేదా టైల్స్‌తో కలపవద్దు.',
      'hinglish': 'Glass Clean aur unbroken bottles hi lena chahiye. Agar ho sake toh clear, green aur brown glass ko alag karo. Glass ko tiles ya ceramic ke saath mix mat karo.',
    }
  };

  static const Map<String, Map<String, String>> recyclabilityTranslations = {
    'recyclable': {
      'hi': 'पुनर्चक्रण योग्य',
      'ta': 'மறுசுழற்சி செய்யக்கூடியது',
      'te': 'రీసైక్లింగ్ చేయదగినది',
    },
    'non-recyclable': {
      'hi': 'गैर-पुनर्चक्रण योग्य',
      'ta': 'மறுசுழற்சி செய்ய முடியாதது',
      'te': 'రీసైక్లింగ్ చేయలేనిది',
    }
  };

  static Future<String?> getOfflineAudioPath(String text, String language) async {
    try {
      // First, try to find a matching waste type
      String? wasteType;
      for (var type in wasteTypeTranslations.keys) {
        if (text.toLowerCase().contains(type) || 
            text.toLowerCase().contains(wasteTypeTranslations[type]?[language]?.toLowerCase() ?? '')) {
          wasteType = type;
          break;
        }
      }

      if (wasteType != null) {
        // Map the audio file names based on the provided files
        String audioFileName;
        switch (wasteType) {
          case 'plastic':
            audioFileName = 'plastic.mp3';
            break;
          case 'metal':
            audioFileName = 'metal.mp3';
            break;
          case 'paper':
            audioFileName = 'paper.mp3';
            break;
          case 'cardboard':
            audioFileName = 'cardboard.mp3';
            break;
          case 'glass':
            audioFileName = 'glass.mp3';
            break;
          default:
            audioFileName = '${wasteType}_instructions.mp3';
        }
        return 'assets/audio/$language/$audioFileName';
      }

      // If no waste type found, try to find a matching instruction
      for (var type in disposalInstructions.keys) {
        if (text == disposalInstructions[type]?[language]) {
          String audioFileName;
          switch (type) {
            case 'plastic':
              audioFileName = 'plastic.mp3';
              break;
            case 'metal':
              audioFileName = 'metal.mp3';
              break;
            case 'paper':
              audioFileName = 'paper.mp3';
              break;
            case 'cardboard':
              audioFileName = 'cardboard.mp3';
              break;
            case 'glass':
              audioFileName = 'glass.mp3';
              break;
            default:
              audioFileName = '${type}_instructions.mp3';
          }
          return 'assets/audio/$language/$audioFileName';
        }
      }
    } catch (e) {
      print('Error getting offline audio path: $e');
    }
    return null;
  }
}