import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_theme.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../localization/localization_helper.dart';
import 'auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_navigation_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _userData;
  bool _isLoading = true;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      print('Loading user data...');
      final user = FirebaseService.getCurrentUser();
      print('Current user: ${user?.uid}');
      if (user != null) {
        final userData = await FirebaseService.getUserProfile(user.uid);
        print('User data: $userData');
        if (userData != null) {
          setState(() {
            _userData = UserModel.fromMap(userData, user.uid);
            _selectedLanguage = _userData!.language;
            _isLoading = false;
          });
        } else {
          print('No user data found');
          setState(() => _isLoading = false);
        }
      } else {
        print('No current user');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateLanguage(String language) async {
    try {
      final user = FirebaseService.getCurrentUser();
      if (user != null) {
        // Update Firebase
        await FirebaseService.updateUserProfile(user.uid, {'language': language});
        
        // Update SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('selected_language', language);
        
        setState(() => _selectedLanguage = language);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language updated to ${_getLanguageName(language)}'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Trigger app rebuild with new locale
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating language: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getLanguageName(String languageCode) {
    return LocalizationHelper.getString(context, languageCode, fallback: {
      'en': 'English',
      'hi': 'हिंदी',
      'ta': 'தமிழ்',
      'te': 'తెలుగు',
    }[languageCode] ?? 'English');
  }

  Future<void> _signOut() async {
    try {
      await FirebaseService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.headingStyle.copyWith(
              fontSize: 24,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.subheadingStyle.copyWith(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(LocalizationHelper.getString(context, 'profile_title', fallback: 'Profile')),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _userData == null
              ? Center(child: Text(LocalizationHelper.getString(context, 'no_user_data_found', fallback: 'No user data found')))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Info Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Profile Picture
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Image.asset(
                                  'assets/icons/app_logo.png',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // User Name
                            Text(
                              _userData!.name ?? LocalizationHelper.getString(context, 'user', fallback: 'User'),
                              style: AppTheme.headingStyle.copyWith(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            
                            // Email
                            Text(
                              _userData!.email,
                              style: AppTheme.subheadingStyle.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Member Since
                            Text(
                              '${LocalizationHelper.getString(context, 'member_since', fallback: 'Member since')} ${_userData!.createdAt?.year ?? DateTime.now().year}',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Stats Grid
                      Text(
                        LocalizationHelper.getString(context, 'your_impact', fallback: 'Your Impact'),
                        style: AppTheme.headingStyle.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 16),
                      
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                        children: [
                          _buildStatCard(
                            LocalizationHelper.getString(context, 'total_scans', fallback: 'Total Scans'),
                            _userData!.totalScans.toString(),
                            Icons.camera_alt,
                            AppTheme.primaryColor,
                          ),
                          _buildStatCard(
                            LocalizationHelper.getString(context, 'points_earned', fallback: 'Points Earned'),
                            _userData!.rewardPoints.toString(),
                            Icons.stars,
                            Colors.amber,
                          ),
                          _buildStatCard(
                            LocalizationHelper.getString(context, 'co2_saved_kg', fallback: 'CO₂ Saved (kg)'),
                            _userData!.co2Saved.toStringAsFixed(1),
                            Icons.eco,
                            Colors.green,
                          ),
                          _buildStatCard(
                            LocalizationHelper.getString(context, 'hazardous_waste', fallback: 'Hazardous Waste'),
                            _userData!.hazardousWasteHandled.toString(),
                            Icons.warning,
                            Colors.orange,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Streaks Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocalizationHelper.getString(context, 'streaks_achievements', fallback: 'Streaks & Achievements'),
                              style: AppTheme.headingStyle.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    LocalizationHelper.getString(context, 'daily_streak', fallback: 'Daily Streak'),
                                    _userData!.dailyStreak.toString(),
                                    Icons.local_fire_department,
                                    Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatCard(
                                    LocalizationHelper.getString(context, 'consecutive_correct', fallback: 'Consecutive Scans'),
                                    _userData!.consecutiveCorrectScans.toString(),
                                    Icons.trending_up,
                                    Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Settings Section
                      Text(
                        LocalizationHelper.getString(context, 'settings', fallback: 'Settings'),
                        style: AppTheme.headingStyle.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 16),
                      
                      // Language Selection
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocalizationHelper.getString(context, 'language', fallback: 'Language'),
                              style: AppTheme.headingStyle.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            
                            DropdownButtonFormField<String>(
                              value: _selectedLanguage,
                              decoration: AppTheme.inputDecoration.copyWith(
                                labelText: LocalizationHelper.getString(context, 'select_language', fallback: 'Select Language'),
                              ),
                              items: [
                                DropdownMenuItem(value: 'en', child: Text(LocalizationHelper.getString(context, 'en', fallback: 'English'))),
                                DropdownMenuItem(value: 'hi', child: Text(LocalizationHelper.getString(context, 'hi', fallback: 'हिंदी'))),
                                DropdownMenuItem(value: 'ta', child: Text(LocalizationHelper.getString(context, 'ta', fallback: 'தமிழ்'))),
                                DropdownMenuItem(value: 'te', child: Text(LocalizationHelper.getString(context, 'te', fallback: 'తెలుగు'))),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  _updateLanguage(value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signOut,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            LocalizationHelper.getString(context, 'sign_out', fallback: 'Sign Out'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }
}