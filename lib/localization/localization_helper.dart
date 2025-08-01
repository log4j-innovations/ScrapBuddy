import 'package:flutter/material.dart';
import 'app_localizations.dart';

class LocalizationHelper {
  // Safe method to get localized strings with fallback
  static String getString(BuildContext? context, String key, {String? fallback}) {
    if (context != null) {
      try {
        final localizations = AppLocalizations.current;
        if (localizations != null) {
          return localizations.translate(key);
        }
      } catch (e) {
        print('Localization error for key $key: $e');
      }
    }
    
    // Return fallback or key itself
    return fallback ?? _getEnglishFallback(key);
  }

  // English fallbacks for common strings
  static String _getEnglishFallback(String key) {
    const Map<String, String> englishFallbacks = {
      'app_name': 'ScrapBuddy',
      'scan_waste': 'Scan Waste',
      'quick_info': 'Quick Info',
      'todays_points': "Today's Points",
      'recyclable_items': 'Recyclable\nItems Scanned',
      'environmental_impact': 'Environmental Impact',
      'home': 'Home',
      'history': 'History',
      'profile': 'Profile',
      'camera': 'Camera',
      'gallery': 'Gallery',
      'select_image_source': 'Select Image Source',
      'upload_image': 'Upload Image',
      'identify_materials': 'Identify material types and get disposal\ninstructions',
      'classification_result': 'Classification Result',
      'analyzing_with_ai': 'Analyzing with Vertex AI...',
      'please_wait': 'Please wait while we classify your waste',
      'classified_by_vertex_ai': 'Classified by Vertex AI',
      'select_language': 'Select Language',
      'choose_preferred_language': 'Choose your preferred language',
      'language_description': 'This will be used for waste classification results and voice feedback',
      'continue': 'Continue',
      'waste_type': 'Waste Type',
      'item_name': 'Item Name',
      'recyclability': 'Recyclability',
      'estimated_value': 'Estimated Value',
      'disposal_instructions': 'Disposal Instructions',
      'scan_another': 'Scan Another',
      'share_result': 'Share Result',
    };
    
    return englishFallbacks[key] ?? key;
  }
}
