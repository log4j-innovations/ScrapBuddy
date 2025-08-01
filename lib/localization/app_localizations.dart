import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  static AppLocalizations? _current;
  static AppLocalizations get current => _current!;
  
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static List<Locale> get supportedLocales => [
    const Locale('en', ''),
    const Locale('hi', ''),
    const Locale('ta', ''),
    const Locale('te', ''),
    const Locale('bn', ''),
    const Locale('mr', ''),
    const Locale('gu', ''),
    const Locale('kn', ''),
  ];

  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString('lib/localization/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      
      _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
      _current = this;
      return true;
    } catch (e) {
      print('Error loading localization for ${locale.languageCode}: $e');
      // Load English as fallback
      if (locale.languageCode != 'en') {
        String jsonString = await rootBundle.loadString('lib/localization/en.json');
        Map<String, dynamic> jsonMap = json.decode(jsonString);
        _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
        _current = this;
      }
      return false;
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  static String of(BuildContext context, String key) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)?.translate(key) ?? key;
  }

  // Common translations
  String get appName => translate('app_name');
  String get scanWaste => translate('scan_waste');
  String get quickInfo => translate('quick_info');
  String get todaysPoints => translate('todays_points');
  String get recyclableItems => translate('recyclable_items');
  String get environmentalImpact => translate('environmental_impact');
  String get home => translate('home');
  String get history => translate('history');
  String get profile => translate('profile');
  String get camera => translate('camera');
  String get gallery => translate('gallery');
  String get selectImageSource => translate('select_image_source');
  String get uploadImage => translate('upload_image');
  String get identifyMaterials => translate('identify_materials');
  String get classificationResult => translate('classification_result');
  String get wasteType => translate('waste_type');
  String get itemName => translate('item_name');
  String get recyclability => translate('recyclability');
  String get estimatedValue => translate('estimated_value');
  String get disposalInstructions => translate('disposal_instructions');
  String get scanAnother => translate('scan_another');
  String get shareResult => translate('share_result');
  String get analyzingWithAI => translate('analyzing_with_ai');
  String get pleaseWait => translate('please_wait');
  String get classifiedByVertexAI => translate('classified_by_vertex_ai');
  String get language => translate('language');
  String get selectLanguage => translate('select_language');
  String get choosePreferredLanguage => translate('choose_preferred_language');
  String get languageDescription => translate('language_description');
  String get continueBtn => translate('continue');
  
  // Waste types
  String get plastic => translate('plastic');
  String get paper => translate('paper');
  String get metal => translate('metal');
  String get trash => translate('trash');
  String get biological => translate('biological');
  String get glass => translate('glass');
  String get battery => translate('battery');
  String get eWaste => translate('e_waste');
  
  // Recyclability
  String get recyclable => translate('recyclable');
  String get nonRecyclable => translate('non_recyclable');
  String get compostable => translate('compostable');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any((supportedLocale) => 
        supportedLocale.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
