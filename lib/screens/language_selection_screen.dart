import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/localization_helper.dart';
import '../services/firebase_service.dart';
import 'main_navigation_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final Function(Locale)? onLocaleChanged;
  
  const LanguageSelectionScreen({super.key, this.onLocaleChanged});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? selectedLanguage;

  final List<Map<String, String>> languages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'hi', 'name': 'हिंदी', 'native': 'हिंदी'},
    {'code': 'ta', 'name': 'தமிழ்', 'native': 'தமிழ்'},
    {'code': 'te', 'name': 'తెలుగు', 'native': 'తెలుగు'},
    {'code': 'bn', 'name': 'বাংলা', 'native': 'বাংলা'},
    {'code': 'mr', 'name': 'मराठी', 'native': 'मराठी'},
    {'code': 'gu', 'name': 'ગુજરાતી', 'native': 'ગુજરાતી'},
    {'code': 'kn', 'name': 'ಕನ್ನಡ', 'native': 'ಕನ್ನಡ'},
  ];

  String _getLanguageName(String languageCode) {
    return LocalizationHelper.getString(context, languageCode, fallback: {
      'en': 'English',
      'hi': 'हिंदी',
      'ta': 'தமிழ்',
      'te': 'తెలుగు',
    }[languageCode] ?? 'English');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          LocalizationHelper.getString(context, 'select_language', fallback: 'Select Language'),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationHelper.getString(context, 'choose_preferred_language', 
                  fallback: 'Choose your preferred language'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              LocalizationHelper.getString(context, 'language_description', 
                  fallback: 'This will be used for waste classification results and voice feedback'),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  final isSelected = selectedLanguage == language['code'];
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2E7D32).withOpacity( 0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: const Color(0xFF2E7D32).withOpacity( 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ] : [],
                    ),
                    child: RadioListTile<String>(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocalizationHelper.getString(context, language['code']!, fallback: language['name']!),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            language['native']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      value: language['code']!,
                      groupValue: selectedLanguage,
                      onChanged: (value) {
                        setState(() {
                          selectedLanguage = value;
                        });
                      },
                      activeColor: const Color(0xFF2E7D32),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: selectedLanguage != null ? _saveLanguageAndContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Text(
                  LocalizationHelper.getString(context, 'continue', fallback: 'Continue'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveLanguageAndContinue() async {
    if (!mounted) return; // Check if widget is still mounted
    
    try {
      // Save to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', selectedLanguage!);
      
      // Save to Firebase for the current user
      final user = FirebaseService.getCurrentUser();
      if (user != null) {
        await FirebaseService.updateUserProfile(user.uid, {
          'language': selectedLanguage!,
          'updatedAt': DateTime.now(),
        });
      }
      
      // Update app locale
      if (widget.onLocaleChanged != null) {
        widget.onLocaleChanged!(Locale(selectedLanguage!));
      }
      
      if (!mounted) return; // Check again before navigation
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    } catch (e) {
      // Using debugPrint instead of print for better practice
      debugPrint('Error saving language preference: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving language preference: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}
