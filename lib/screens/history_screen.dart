import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/firebase_service.dart';
import '../models/scan_history.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ScanHistory> _scanHistory = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadScanHistory();
  }

  Future<void> _loadScanHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final currentUser = FirebaseService.getCurrentUser();
      if (currentUser != null) {
        final historyData = await FirebaseService.getScanHistory(currentUser.uid);
        final history = historyData.map((data) {
          return ScanHistory.fromMap(data, data['id'] ?? '');
        }).toList();

        setState(() {
          _scanHistory = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading scan history: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
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
        return Colors.cyan;
      case 'cardboard':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: AppTheme.subheadingStyle),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadScanHistory,
              style: AppTheme.buttonStyle,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_scanHistory.isEmpty) {
      return Center(
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
              'No scan history yet',
              style: AppTheme.headingStyle.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start scanning waste items to build your history',
              style: AppTheme.subheadingStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadScanHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _scanHistory.length,
        itemBuilder: (context, index) {
          final scan = _scanHistory[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: AppTheme.cardDecoration,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getWasteTypeColor(scan.wasteType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: _getWasteTypeColor(scan.wasteType),
                ),
              ),
              title: Text(
                scan.itemName,
                style: AppTheme.headingStyle.copyWith(fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    scan.wasteType,
                    style: AppTheme.subheadingStyle.copyWith(
                      color: _getWasteTypeColor(scan.wasteType),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getTimeAgo(scan.timestamp),
                    style: AppTheme.subheadingStyle.copyWith(fontSize: 12),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${scan.monetaryValue}',
                    style: AppTheme.headingStyle.copyWith(
                      fontSize: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: scan.recyclability.toLowerCase() == 'recyclable'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      scan.recyclability,
                      style: TextStyle(
                        color: scan.recyclability.toLowerCase() == 'recyclable'
                            ? Colors.green
                            : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}