import 'package:flutter/material.dart';
import 'app_localizations.dart';

class LocalizationHelper {
  // Safe method to get localized strings with fallback
  static String getString(BuildContext? context, String key, {String? fallback}) {
    if (context != null) {
      try {
        final localizations = AppLocalizations.current;
        if (localizations != null) {
          final translated = localizations.translate(key);
          if (translated != key) {
            return translated;
          }
        }
        
        // Try to get from context-based localization
        final contextLocalizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
        if (contextLocalizations != null) {
          final translated = contextLocalizations.translate(key);
          if (translated != key) {
            return translated;
          }
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
      'choose_image_source': 'Choose Image Source',
      'upload_image': 'Upload Image',
      'identify_materials': 'Identify material types and get disposal\ninstructions',
      'classification_result': 'Classification Result',
      'analyzing_with_ai': 'Analyzing with AI...',
      'please_wait': 'Please wait while we classify your waste',
      'classified_by_vertex_ai': 'Classified by ScrapBuddy',
      'classified_by_scrapbuddy': 'Classified by ScrapBuddy',
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
      'language': 'Language',
      'playing_audio': 'Playing audio in',
      'tts_unavailable': 'TTS service temporarily unavailable',
      'audio_generation_failed': 'Audio playback failed',
      'unable_to_play_audio': 'Unable to play audio',
      'share_content': 'Share content',
      'total_scans': 'Total Scans',
      'points_earned': 'Points Earned',
      'co2_saved': 'CO₂ Saved',
      'hazardous_waste': 'Hazardous Waste',
      'member_since': 'Member since',
      'your_impact': 'Your Impact',
      'daily_streak': 'Daily Streak',
      'consecutive_correct': 'Consecutive Correct',
      'change_language': 'Change Language',
      'sign_out': 'Sign Out',
      'loading': 'Loading...',
      'no_data_available': 'No data available',
      'error_loading_data': 'Error loading data',
      'language_updated': 'Language updated',
      'error_updating_language': 'Error updating language',
      'error_signing_out': 'Error signing out',
      'scan_history': 'Scan History',
      'no_scan_history': 'No scan history available',
      'timestamp': 'Timestamp',
      'points': 'Points',
      'co2_saved_kg': 'CO₂ Saved (kg)',
      'weight': 'Weight',
      'confidence': 'Confidence',
      'online': 'Online',
      'offline': 'Offline',
      'great_job': 'Great job!',
      'points_earned_label': 'Points Earned',
      'co2_saved_label': 'CO₂ Saved',
      'environmental_contribution': 'You\'ve contributed to a cleaner environment! Keep up the great work.',
      'test_credentials': 'Test Credentials:',
      'test_email': 'test@email.com',
      'test_password': '123456',
      'saving_results': 'Saving your scan results...',
      'start_scanning_message': 'Start scanning waste to see your history here',
      'streaks_achievements': 'Streaks & Achievements',
      'settings': 'Settings',
      'welcome_message': 'Welcome to ScrapBuddy',
      'scan_waste_message': 'Scan any waste item to get instant classification and recycling guidance',
      'today_stats': 'Today\'s Stats',
      'items_scanned': 'Items Scanned',
      'analyzing_waste': 'Analyzing waste...',
      'tap_to_scan': 'Tap to Scan Waste',
      'scan_description': 'Get instant classification and recycling guidance',
      'classification_failed': 'Failed to classify waste. Please try again.',
      'no_user_data_found': 'No user data found',
      'profile_title': 'Profile',
      'user': 'User',
      'minutes_ago': 'minutes ago',
      'hours_ago': 'hours ago',
      'yesterday': 'Yesterday',
      'days_ago': 'days ago',
      'unknown': 'Unknown',
      'recyclable': 'Recyclable',
      'non_recyclable': 'Non-Recyclable',
      'compostable': 'Compostable',
      'plastic': 'Plastic',
      'paper': 'Paper',
      'metal': 'Metal',
      'glass': 'Glass',
      'batteries': 'Batteries',
      'e_waste': 'E-Waste',
      'light_bulbs': 'Light Bulbs',
      'organic': 'Organic',
      'clothes': 'Clothes',
      'cardboard': 'Cardboard',
      'trash': 'Trash',
      'biological': 'Biological',
      'battery': 'Battery',
    };
    
    return englishFallbacks[key] ?? key;
  }
}
