import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/app_localizations.dart';
import '../services/firebase_service.dart';
import 'language_selection_screen.dart';
import 'main_navigation_screen.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  final Function(Locale)? onLocaleChanged;
  
  const SplashScreen({super.key, this.onLocaleChanged});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack)
    );
    
    _animationController.forward();
    _checkLanguagePreference();
  }

  Future<void> _checkLanguagePreference() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? selectedLanguage = prefs.getString('selected_language');
      bool isLoggedIn = FirebaseService.isUserLoggedIn();
      
      if (!mounted) return;
      
      if (selectedLanguage == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LanguageSelectionScreen(onLocaleChanged: widget.onLocaleChanged)
          ),
        );
      } else {
        // Set locale before navigating
        if (widget.onLocaleChanged != null) {
          widget.onLocaleChanged!(Locale(selectedLanguage));
        }
        
        // Navigate based on authentication status
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => isLoggedIn ? const MainNavigationScreen() : const LoginScreen(),
          ),
        );
      }
    } catch (e) {
      print('Error checking language preference: $e');
      if (!mounted) return;
      
      // Navigate to language selection on error
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LanguageSelectionScreen(onLocaleChanged: widget.onLocaleChanged)
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.recycling,
                      size: 120,
                      color: Colors.white,
                    ),
                    SizedBox(height: 30),
                    Text(
                      'ScrapBuddy',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'AI-Powered Waste Classification',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 50),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
