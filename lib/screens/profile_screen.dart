import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final currentUser = FirebaseService.getCurrentUser();
      if (currentUser != null) {
        final userData = await FirebaseService.getUserProfile(currentUser.uid);
        if (userData != null) {
          setState(() {
            _user = UserModel.fromMap(userData, currentUser.uid);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.headingStyle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.subheadingStyle.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.cardDecoration,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(
                      _user?.name?.substring(0, 1).toUpperCase() ?? 
                      _user?.email.substring(0, 1).toUpperCase() ?? 'U',
                      style: AppTheme.headingStyle.copyWith(
                        color: AppTheme.primaryColor,
                        fontSize: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user?.name ?? 'User',
                    style: AppTheme.headingStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user?.email ?? '',
                    style: AppTheme.subheadingStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildStatCard(
                  'Total Scans',
                  _user?.totalScans.toString() ?? '0',
                  Icons.document_scanner,
                ),
                _buildStatCard(
                  'CO₂ Saved',
                  '${_user?.co2Saved.toStringAsFixed(1) ?? '0'} kg',
                  Icons.eco,
                ),
                _buildStatCard(
                  'Reward Points',
                  _user?.rewardPoints.toString() ?? '0',
                  Icons.stars,
                ),
                _buildStatCard(
                  'Last Scan',
                  _user?.lastScanDate?.toString().split(' ')[0] ?? 'Never',
                  Icons.calendar_today,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Logout Button
            ElevatedButton.icon(
              onPressed: _handleLogout,
              style: AppTheme.buttonStyle,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}