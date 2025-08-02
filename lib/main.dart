import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'localization/app_localizations.dart';
import 'config/api_keys_helper.dart';
import 'services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  await FirebaseService.initializeFirebase();
  
  // Enable offline persistence
  await FirebaseService.enableOfflinePersistence();
  
  // Load API keys from Android secrets.xml
  await ApiKeysHelper.loadApiKeys();
  
  runApp(const ScrapBuddyApp());
}

class ScrapBuddyApp extends StatefulWidget {
  const ScrapBuddyApp({Key? key}) : super(key: key);

  @override
  _ScrapBuddyAppState createState() => _ScrapBuddyAppState();
}

class _ScrapBuddyAppState extends State<ScrapBuddyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedLanguage = prefs.getString('selected_language');
    if (selectedLanguage != null) {
      setState(() {
        _locale = Locale(selectedLanguage);
      });
    }
  }

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    
    return MaterialApp(
      title: 'ScrapBuddy',
      debugShowCheckedModeBanner: false,
      
      // Localization configuration
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: GoogleFonts.inter().fontFamily,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: SplashScreen(onLocaleChanged: _setLocale),
    );
  }
}
