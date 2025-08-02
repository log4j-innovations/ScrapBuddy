import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import '../services/offline_classifier_service.dart';
import '../services/vertex_ai_service.dart';
import '../widgets/stats_card.dart';
import '../localization/localization_helper.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOnline = true;
  Timer? _connectivityTimer;

  @override
  void initState() {
    super.initState();
    _initializeOfflineClassifier();
    _startConnectivityCheck();
  }

  @override
  void dispose() {
    _connectivityTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeOfflineClassifier() async {
    await OfflineClassifierService.initialize();
  }

  void _startConnectivityCheck() {
    _checkConnectivity();
    _connectivityTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkConnectivity());
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (mounted) {
        setState(() {
          _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        });
      }
    } on SocketException catch (_) {
      if (mounted) {
        setState(() {
          _isOnline = false;
        });
      }
    }
  }
  final ImagePicker _picker = ImagePicker();
  final VertexAIService _vertexAIService = VertexAIService();
  bool _isLoading = false;
  int _currentIndex = 0;
  
  int todaysPoints = 25;
  int recyclableItemsScanned = 12;
  String environmentalImpact = "5";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isOnline ? const Color(0xFF2E7D32).withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isOnline ? const Color(0xFF2E7D32).withOpacity(0.3) : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isOnline ? Icons.cloud_done : Icons.cloud_off,
                  size: 16,
                  color: _isOnline ? const Color(0xFF2E7D32) : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isOnline ? const Color(0xFF2E7D32) : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: _isLoading ? _buildLoadingView() : _buildMainView(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _isLoading ? null : _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 4.0,
        color: Colors.white,
        elevation: 0,
        height: 70,
        child: Container(
          height: 70,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
            left: 12,
            right: 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                Icons.home_outlined, 
                Icons.home, 
                LocalizationHelper.getString(context, 'home', fallback: 'Home'), 
                0
              ),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(
                Icons.history_outlined, 
                Icons.history, 
                LocalizationHelper.getString(context, 'history', fallback: 'History'), 
                2
              ),
              _buildNavItem(
                Icons.person_outline, 
                Icons.person, 
                LocalizationHelper.getString(context, 'profile', fallback: 'Profile'), 
                3
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData outlinedIcon, IconData filledIcon, String label, int index) {
    final bool isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
          _handleNavigation(index, label);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? filledIcon : outlinedIcon,
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade500,
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade500,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNavigation(int index, String label) {
    switch (index) {
      case 0:
        break;
      case 2:
        _showSnackBar(LocalizationHelper.getString(context, 'feature_coming_soon', 
            fallback: '$label feature coming soon!'));
        break;
      case 3:
        _showSnackBar(LocalizationHelper.getString(context, 'feature_coming_soon', 
            fallback: '$label feature coming soon!'));
        break;
    }
  }

  Widget _buildFloatingActionButton() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity( 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _showImageSourceDialog(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        heroTag: "scan_fab",
        child: const Icon(
          Icons.qr_code_scanner,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              color: Color(0xFF2E7D32),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            LocalizationHelper.getString(context, 'analyzing_with_ai', 
                fallback: 'Analyzing with Vertex AI...'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            LocalizationHelper.getString(context, 'please_wait', 
                fallback: 'Please wait while we classify your waste'),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildScanWasteCard(),
                  const SizedBox(height: 32),
                  _buildQuickInfoSection(),
                  const SizedBox(height: 20), // Reduced padding for bottom nav
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: Color(0xFF2E7D32),
          child: Icon(Icons.person, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocalizationHelper.getString(context, 'app_name', fallback: 'ScrapBuddy'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                LocalizationHelper.getString(context, 'ai_powered_subtitle', 
                    fallback: 'AI-Powered by Vertex AI'),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            _showSnackBar(LocalizationHelper.getString(context, 'notifications_coming_soon', 
                fallback: 'Notifications feature coming soon!'));
          },
          icon: const Icon(Icons.notifications_outlined, size: 24),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanWasteCard() {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFB5B5), Color(0xFFFFCCCC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB5B5).withOpacity( 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Camera Icon (same as before)
            Container(
              width: 140,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity( 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade400, width: 2),
                    ),
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    child: Container(
                      width: 20,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              LocalizationHelper.getString(context, 'scan_waste', fallback: 'Scan Waste'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              LocalizationHelper.getString(context, 'identify_materials', 
                  fallback: 'Identify material types and get disposal\ninstructions'),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity( 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity( 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.upload, color: Colors.black54, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    LocalizationHelper.getString(context, 'upload_image', fallback: 'Upload Image'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationHelper.getString(context, 'quick_info', fallback: 'Quick Info'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: LocalizationHelper.getString(context, 'todays_points', fallback: "Today's Points"),
                value: todaysPoints.toString(),
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatsCard(
                title: LocalizationHelper.getString(context, 'recyclable_items', 
                    fallback: "Recyclable\nItems Scanned"),
                value: recyclableItemsScanned.toString(),
                color: const Color(0xFF1976D2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity( 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocalizationHelper.getString(context, 'environmental_impact', 
                    fallback: 'Environmental Impact'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.eco,
                    color: Color(0xFF4CAF50),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$environmentalImpact ${LocalizationHelper.getString(context, 'kg_co2_saved', fallback: 'kg CO2 saved')}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                LocalizationHelper.getString(context, 'select_image_source', 
                    fallback: 'Select Image Source'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity( 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF2E7D32).withOpacity( 0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.camera_alt, size: 32, color: Color(0xFF2E7D32)),
                            const SizedBox(height: 8),
                            Text(
                              LocalizationHelper.getString(context, 'camera', fallback: 'Camera'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2).withOpacity( 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1976D2).withOpacity( 0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.photo_library, size: 32, color: Color(0xFF1976D2)),
                            const SizedBox(height: 8),
                            Text(
                              LocalizationHelper.getString(context, 'gallery', fallback: 'Gallery'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _isLoading = true;
        });

        final result = await _vertexAIService.classifyWaste(File(image.path));

        setState(() {
          _isLoading = false;
        });

        if (result != null) {
          setState(() {
            todaysPoints += 5;
            recyclableItemsScanned += 1;
            if (result.recyclability.toLowerCase().contains('recyclable')) {
              environmentalImpact = "${int.parse(environmentalImpact) + 1}";
            }
          });
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                classification: result,
                imageFile: File(image.path),
              ),
            ),
          );
        } else {
          _showSnackBar(LocalizationHelper.getString(context, 'classification_failed', 
              fallback: 'Failed to classify waste with Vertex AI. Please try again.'));
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
