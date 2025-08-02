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
                  _isOnline ? LocalizationHelper.getString(context, 'online', fallback: 'Online') : LocalizationHelper.getString(context, 'offline', fallback: 'Offline'),
                  style: TextStyle(
                    fontSize: 12,
                    color: _isOnline ? const Color(0xFF2E7D32) : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    LocalizationHelper.getString(context, 'analyzing_waste', fallback: 'Analyzing waste...'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(),
                  const SizedBox(height: 32),
                  _buildStatsSection(),
                  const SizedBox(height: 32),
                  _buildScanSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationHelper.getString(context, 'welcome_message', fallback: 'Welcome to ScrapBuddy'),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          LocalizationHelper.getString(context, 'scan_waste_message', 
              fallback: 'Scan any waste item to get instant classification and recycling guidance'),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationHelper.getString(context, 'today_stats', fallback: 'Today\'s Stats'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: LocalizationHelper.getString(context, 'points_earned', fallback: 'Points Earned'),
                value: todaysPoints.toString(),
                icon: Icons.stars,
                color: const Color(0xFFFF9800),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatsCard(
                title: LocalizationHelper.getString(context, 'items_scanned', fallback: 'Items Scanned'),
                value: recyclableItemsScanned.toString(),
                icon: Icons.camera_alt,
                color: const Color(0xFF2196F3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StatsCard(
          title: LocalizationHelper.getString(context, 'environmental_impact', fallback: 'Environmental Impact'),
          value: environmentalImpact,
          icon: Icons.eco,
          color: const Color(0xFF4CAF50),
        ),
      ],
    );
  }

  Widget _buildScanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationHelper.getString(context, 'scan_waste', fallback: 'Scan Waste'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildImageSourceModal(),
      ],
    );
  }

  Widget _buildImageSourceModal() {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: _showImageSourceModal,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.camera_alt, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  LocalizationHelper.getString(context, 'tap_to_scan', fallback: 'Tap to Scan Waste'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  LocalizationHelper.getString(context, 'scan_description', 
                      fallback: 'Get instant classification and recycling guidance'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildImageSourceBottomSheet(),
    );
  }

  Widget _buildImageSourceBottomSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
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
                LocalizationHelper.getString(context, 'choose_image_source', fallback: 'Choose Image Source'),
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
                          color: const Color(0xFF2E7D32).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
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
                          color: const Color(0xFF1976D2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
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
        ),
      ),
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
