import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import '../config/app_theme.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomAppBar(
        height: 70,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        color: Colors.white,
        elevation: 8,
        shape: const AutomaticNotchedShape(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home, 'Home'),
            _buildNavItem(1, Icons.history, 'History'),
            _buildNavItem(2, Icons.person, 'Profile'),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () {
          // Show image source modal by navigating to home screen and triggering the modal
          setState(() {
            _currentIndex = 0;
          });
          // The home screen will handle the FAB press
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 