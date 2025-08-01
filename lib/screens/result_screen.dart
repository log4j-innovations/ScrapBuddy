import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../models/waste_classification.dart';
import '../services/vertex_ai_service.dart';
import '../services/firebase_service.dart';
import '../localization/localization_helper.dart';

class ResultScreen extends StatefulWidget {
  final WasteClassification classification;
  final File imageFile;

  const ResultScreen({
    super.key,
    required this.classification,
    required this.imageFile,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  final VertexAIService _vertexAIService = VertexAIService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingItemAudio = false;
  bool _isPlayingInstructionAudio = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String selectedLanguage = 'en';
  bool _isSavingToFirebase = false;
  int _pointsEarned = 0;
  double _co2Saved = 0.0;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn)
    );
    _animationController.forward();
    _calculateAndSaveResults();
  }

  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selected_language') ?? 'en';
    });
    print('Loaded selected language: $selectedLanguage');
  }

  Future<void> _calculateAndSaveResults() async {
    setState(() => _isSavingToFirebase = true);
    
    try {
      // Calculate points and CO2 saved
      final wasteType = widget.classification.wasteType.toLowerCase();
      
      // Calculate points based on waste type
      final basePoints = {
        'organic': 2,
        'paper': 2,
        'plastic': 2,
        'clothes': 3,
        'glass': 3,
        'metal': 4,
        'light bulbs': 6,
        'batteries': 8,
        'e-waste': 8,
        'cardboard': 2,
      };
      
      _pointsEarned = basePoints[wasteType] ?? 0;
      
      // Calculate CO2 saved
      final co2SavingsPerKg = {
        'plastic': 2.0,
        'metal': 5.0,
        'paper': 1.5,
        'e-waste': 0.4,
        'glass': 0.3,
        'batteries': 0.0,
        'light bulbs': 0.0,
        'organic': 0.0,
        'clothes': 0.0,
        'cardboard': 1.2,
      };
      
      final weight = 0.1; // Default weight in kg
      _co2Saved = (co2SavingsPerKg[wasteType] ?? 0.0) * weight;
      
      // Save to Firebase
      final user = FirebaseService.getCurrentUser();
      if (user != null) {
        await FirebaseService.saveScanHistory(user.uid, {
          'wasteType': widget.classification.wasteType,
          'itemName': widget.classification.itemName,
          'translatedName': widget.classification.translatedName,
          'recyclability': widget.classification.recyclability,
          'monetaryValue': widget.classification.monetaryValue,
          'disposalInstructions': widget.classification.disposalInstructions,
          'confidence': widget.classification.confidence,
          'points': _pointsEarned,
          'co2Saved': _co2Saved,
          'weight': weight,
          'imagePath': widget.imageFile.path,
        });
      }
      
      setState(() => _isSavingToFirebase = false);
    } catch (e) {
      print('Error saving scan results: $e');
      setState(() => _isSavingToFirebase = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          LocalizationHelper.getString(context, 'classification_result', fallback: 'Classification Result'),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              const SizedBox(height: 24),
              _buildVertexAIBadge(),
              const SizedBox(height: 24),
              _buildFeedbackSection(),
              const SizedBox(height: 24),
              _buildClassificationResults(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          widget.imageFile,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildVertexAIBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.psychology, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            '${LocalizationHelper.getString(context, 'classified_by_scrapbuddy', fallback: 'Classified by ScrapBuddy')} • ${LocalizationHelper.getString(context, 'language', fallback: 'Language')}: ${LocalizationHelper.getString(context, selectedLanguage, fallback: _getLanguageName(selectedLanguage))}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    return LocalizationHelper.getString(context, code, fallback: {
      'hi': 'हिंदी',
      'ta': 'தமிழ்', 
      'te': 'తెలుగు',
      'bn': 'বাংলা',
      'mr': 'मराठी',
      'gu': 'ગુજરાતી',
      'kn': 'ಕನ್ನಡ',
      'en': 'English',
    }[code] ?? 'English');
  }

  Widget _buildFeedbackSection() {
    if (_isSavingToFirebase) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              LocalizationHelper.getString(context, 'saving_results', fallback: 'Saving your scan results...'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.celebration,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                LocalizationHelper.getString(context, 'great_job', fallback: 'Great job!'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFeedbackItem(
                  LocalizationHelper.getString(context, 'points_earned_label', fallback: 'Points Earned'),
                  '+$_pointsEarned',
                  Icons.stars,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeedbackItem(
                  LocalizationHelper.getString(context, 'co2_saved_label', fallback: 'CO₂ Saved'),
                  '${_co2Saved.toStringAsFixed(2)} kg',
                  Icons.eco,
                  Colors.lightGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    LocalizationHelper.getString(context, 'environmental_contribution', fallback: 'You\'ve contributed to a cleaner environment! Keep up the great work.'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildClassificationResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationHelper.getString(context, 'classification_result', fallback: 'Classification Results'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        _buildResultCard(
          LocalizationHelper.getString(context, 'waste_type', fallback: 'Waste Type'),
          LocalizationHelper.getString(context, widget.classification.wasteType.toLowerCase(), fallback: widget.classification.wasteType),
          Icons.category_outlined,
          const Color(0xFF2196F3),
        ),
        _buildResultCard(
          LocalizationHelper.getString(context, 'item_name', fallback: 'Item Name'),
          widget.classification.translatedName ?? widget.classification.itemName,
          Icons.label_outline,
          const Color(0xFF4CAF50),
          showSpeaker: true,
          onSpeakerTap: _playItemNameAudio,
          isPlaying: _isPlayingItemAudio,
        ),
        _buildResultCard(
          LocalizationHelper.getString(context, 'recyclability', fallback: 'Recyclability'),
          LocalizationHelper.getString(context, widget.classification.recyclability.toLowerCase(), fallback: widget.classification.recyclability),
          Icons.recycling,
          _getRecyclabilityColor(),
        ),
        _buildResultCard(
          LocalizationHelper.getString(context, 'estimated_value', fallback: 'Estimated Value'),
          '₹${widget.classification.monetaryValue}',
          Icons.currency_rupee,
          const Color(0xFFFF9800),
        ),
        _buildInstructionCard(),
      ],
    );
  }

  Widget _buildResultCard(
    String title, 
    String value, 
    IconData icon, 
    Color color, {
    bool showSpeaker = false,
    VoidCallback? onSpeakerTap,
    bool isPlaying = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity( 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (showSpeaker && onSpeakerTap != null)
            IconButton(
              onPressed: onSpeakerTap,
              icon: Icon(
                isPlaying ? Icons.volume_up : Icons.volume_off_outlined,
                color: const Color(0xFF2E7D32),
              ),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32).withOpacity( 0.1),
                padding: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withOpacity( 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.info_outline, color: Color(0xFF9C27B0), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  LocalizationHelper.getString(context, 'disposal_instructions', fallback: 'Disposal Instructions'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: _playInstructionAudio,
                icon: Icon(
                  _isPlayingInstructionAudio ? Icons.volume_up : Icons.volume_off_outlined,
                  color: const Color(0xFF9C27B0),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0).withOpacity( 0.1),
                  padding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.classification.translatedInstructions ?? widget.classification.disposalInstructions,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.camera_alt, size: 20),
            label: Text(
              LocalizationHelper.getString(context, 'scan_another', fallback: 'Scan Another'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _shareResult,
            icon: const Icon(Icons.share, size: 20),
            label: Text(
              LocalizationHelper.getString(context, 'share_result', fallback: 'Share Result'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF2E7D32)),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Color _getRecyclabilityColor() {
    final recyclability = widget.classification.recyclability.toLowerCase();
    switch (recyclability) {
      case 'recyclable':
        return const Color(0xFF4CAF50);
      case 'non-recyclable':
        return const Color(0xFFF44336);
      case 'compostable':
        return const Color(0xFFFF9800);
      default:
        return Colors.grey;
    }
  }

  Future<void> _playItemNameAudio() async {
    if (_isPlayingItemAudio) return;
    
    try {
      setState(() {
        _isPlayingItemAudio = true;
      });

      String textToSpeak = widget.classification.translatedName ?? 
                          widget.classification.itemName;

      await _playTTSAudio(textToSpeak);

    } catch (e) {
      _showSnackBar(LocalizationHelper.getString(context, 'unable_to_play_audio', 
          fallback: 'Unable to play audio: ${e.toString()}'), Colors.red);
    } finally {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isPlayingItemAudio = false;
          });
        }
      });
    }
  }

  Future<void> _playInstructionAudio() async {
    if (_isPlayingInstructionAudio) return;
    
    try {
      setState(() {
        _isPlayingInstructionAudio = true;
      });

      String textToSpeak = widget.classification.translatedInstructions ?? 
                          widget.classification.disposalInstructions;

      await _playTTSAudio(textToSpeak);

    } catch (e) {
      _showSnackBar(LocalizationHelper.getString(context, 'unable_to_play_audio', 
          fallback: 'Unable to play instruction audio: ${e.toString()}'), Colors.red);
    } finally {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _isPlayingInstructionAudio = false;
          });
        }
      });
    }
  }

  Future<void> _playTTSAudio(String text) async {
    try {
      String? base64Audio = await _vertexAIService.getTextToSpeechBase64(text, selectedLanguage);
      
      if (base64Audio != null) {
        Uint8List audioBytes = base64Decode(base64Audio);
        
        Directory tempDir = await getTemporaryDirectory();
        String audioPath = '${tempDir.path}/tts_audio_${DateTime.now().millisecondsSinceEpoch}.wav';
        File audioFile = File(audioPath);
        await audioFile.writeAsBytes(audioBytes);
        
        await _audioPlayer.play(DeviceFileSource(audioPath));
        
        Future.delayed(const Duration(seconds: 10), () {
          if (audioFile.existsSync()) {
            audioFile.deleteSync();
          }
        });
        
        _showSnackBar('🔊 ${LocalizationHelper.getString(context, 'playing_audio', fallback: 'Playing audio in')} ${LocalizationHelper.getString(context, selectedLanguage, fallback: _getLanguageName(selectedLanguage))}', const Color(0xFF2E7D32));
      } else {
        _showSnackBar(LocalizationHelper.getString(context, 'tts_unavailable', fallback: 'TTS service temporarily unavailable'), Colors.orange);
      }
    } catch (e) {
      print('TTS playback error: $e');
      _showSnackBar(LocalizationHelper.getString(context, 'audio_generation_failed', fallback: 'Audio playback failed'), Colors.red);
    }
  }

  void _shareResult() {
    final String shareText = '''
🤖 ScrapBuddy ${LocalizationHelper.getString(context, 'classification_result', fallback: 'Classification Results')}

📦 ${LocalizationHelper.getString(context, 'waste_type', fallback: 'Waste Type')}: ${LocalizationHelper.getString(context, widget.classification.wasteType.toLowerCase(), fallback: widget.classification.wasteType)}
🏷️ ${LocalizationHelper.getString(context, 'item_name', fallback: 'Item')}: ${widget.classification.translatedName ?? widget.classification.itemName}
♻️ ${LocalizationHelper.getString(context, 'recyclability', fallback: 'Recyclability')}: ${LocalizationHelper.getString(context, widget.classification.recyclability.toLowerCase(), fallback: widget.classification.recyclability)}
💰 ${LocalizationHelper.getString(context, 'estimated_value', fallback: 'Est. Value')}: ₹${widget.classification.monetaryValue}
📋 ${LocalizationHelper.getString(context, 'disposal_instructions', fallback: 'Instructions')}: ${widget.classification.translatedInstructions ?? widget.classification.disposalInstructions}

${LocalizationHelper.getString(context, 'language', fallback: 'Language')}: ${_getLanguageName(selectedLanguage)}
#ScrapBuddy #WasteManagement #Recycling #SustainableLiving
    ''';
    
    _showSnackBar('${LocalizationHelper.getString(context, 'share_content', fallback: 'Share content')}: $shareText', const Color(0xFF2E7D32));
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
