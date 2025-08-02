import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_theme.dart';
import '../services/firebase_service.dart';
import '../localization/localization_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _scanHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScanHistory();
  }

  Future<void> _loadScanHistory() async {
    try {
      print('Loading scan history...');
      final user = FirebaseService.getCurrentUser();
      print('Current user: ${user?.uid}');
      if (user != null) {
        final history = await FirebaseService.getScanHistory(user.uid);
        print('Scan history: ${history.length} items');
        setState(() {
          _scanHistory = history;
          _isLoading = false;
        });
      } else {
        print('No current user');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading scan history: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getWasteTypeColor(String wasteType) {
    switch (wasteType.toLowerCase()) {
      case 'plastic':
        return Colors.blue;
      case 'paper':
        return Colors.brown;
      case 'metal':
        return Colors.grey;
      case 'glass':
        return Colors.green;
      case 'batteries':
      case 'e-waste':
      case 'light bulbs':
        return Colors.red;
      case 'organic':
        return Colors.orange;
      case 'clothes':
        return Colors.purple;
      case 'cardboard':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getWasteTypeIcon(String wasteType) {
    switch (wasteType.toLowerCase()) {
      case 'plastic':
        return Icons.local_drink;
      case 'paper':
        return Icons.article;
      case 'metal':
        return Icons.hardware;
      case 'glass':
        return Icons.wine_bar;
      case 'batteries':
        return Icons.battery_charging_full;
      case 'e-waste':
        return Icons.devices;
      case 'light bulbs':
        return Icons.lightbulb;
      case 'organic':
        return Icons.eco;
      case 'clothes':
        return Icons.checkroom;
      case 'cardboard':
        return Icons.inventory_2;
      default:
        return Icons.delete;
    }
  }

  Widget _buildScanCard(Map<String, dynamic> scan) {
    final wasteType = scan['wasteType']?.toString() ?? 'Unknown';
    final points = scan['points'] ?? 0;
    final co2Saved = scan['co2Saved'] ?? 0.0;
    final timestamp = scan['timestamp'];
    final recyclability = scan['recyclability']?.toString() ?? 'Unknown';
    
    DateTime? scanDate;
    if (timestamp != null) {
      scanDate = timestamp.toDate();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with waste type and timestamp
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getWasteTypeColor(wasteType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getWasteTypeIcon(wasteType),
                    color: _getWasteTypeColor(wasteType),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wasteType.toUpperCase(),
                        style: AppTheme.headingStyle.copyWith(
                          fontSize: 16,
                          color: _getWasteTypeColor(wasteType),
                        ),
                      ),
                      if (scanDate != null)
                        Text(
                          _formatDate(scanDate),
                          style: AppTheme.subheadingStyle.copyWith(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: recyclability.toLowerCase() == 'recyclable' 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recyclability,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: recyclability.toLowerCase() == 'recyclable' 
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Stats row
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    LocalizationHelper.getString(context, 'points', fallback: 'Points'),
                    points.toString(),
                    Icons.stars,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    LocalizationHelper.getString(context, 'co2_saved', fallback: 'CO₂ Saved'),
                    '${co2Saved.toStringAsFixed(2)} kg',
                    Icons.eco,
                    Colors.green,
                  ),
                ),
              ],
            ),
            
            // Disposal instructions
            if (scan['disposalInstructions'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        scan['disposalInstructions'].toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
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
        title: Text(LocalizationHelper.getString(context, 'scan_history', fallback: 'Scan History')),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadScanHistory,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _scanHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        LocalizationHelper.getString(context, 'no_scan_history', fallback: 'No scan history yet'),
                        style: AppTheme.headingStyle.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        LocalizationHelper.getString(context, 'start_scanning_message', fallback: 'Start scanning waste to see your history here'),
                        style: AppTheme.subheadingStyle.copyWith(
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadScanHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _scanHistory.length,
                    itemBuilder: (context, index) {
                      return _buildScanCard(_scanHistory[index]);
                    },
                  ),
                ),
    );
  }
}