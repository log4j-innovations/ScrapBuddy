import 'package:cloud_firestore/cloud_firestore.dart';

class ScanHistory {
  final String id;
  final String userId;
  final String wasteType;
  final String itemName;
  final String recyclability;
  final double monetaryValue;
  final String disposalInstructions;
  final DateTime timestamp;
  final bool isOfflineScan;
  final double? weight;
  final double co2Saved;
  final int rewardPoints;

  ScanHistory({
    required this.id,
    required this.userId,
    required this.wasteType,
    required this.itemName,
    required this.recyclability,
    required this.monetaryValue,
    required this.disposalInstructions,
    required this.timestamp,
    this.isOfflineScan = false,
    this.weight,
    required this.co2Saved,
    required this.rewardPoints,
  });

  factory ScanHistory.fromMap(Map<String, dynamic> data, String id) {
    return ScanHistory(
      id: id,
      userId: data['userId'] ?? '',
      wasteType: data['wasteType'] ?? '',
      itemName: data['itemName'] ?? '',
      recyclability: data['recyclability'] ?? '',
      monetaryValue: (data['monetaryValue'] ?? 0).toDouble(),
      disposalInstructions: data['disposalInstructions'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isOfflineScan: data['isOfflineScan'] ?? false,
      weight: data['weight']?.toDouble(),
      co2Saved: (data['co2Saved'] ?? 0).toDouble(),
      rewardPoints: data['rewardPoints'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'wasteType': wasteType,
      'itemName': itemName,
      'recyclability': recyclability,
      'monetaryValue': monetaryValue,
      'disposalInstructions': disposalInstructions,
      'timestamp': Timestamp.fromDate(timestamp),
      'isOfflineScan': isOfflineScan,
      'weight': weight,
      'co2Saved': co2Saved,
      'rewardPoints': rewardPoints,
    };
  }

  ScanHistory copyWith({
    String? wasteType,
    String? itemName,
    String? recyclability,
    double? monetaryValue,
    String? disposalInstructions,
    DateTime? timestamp,
    bool? isOfflineScan,
    double? weight,
    double? co2Saved,
    int? rewardPoints,
  }) {
    return ScanHistory(
      id: this.id,
      userId: this.userId,
      wasteType: wasteType ?? this.wasteType,
      itemName: itemName ?? this.itemName,
      recyclability: recyclability ?? this.recyclability,
      monetaryValue: monetaryValue ?? this.monetaryValue,
      disposalInstructions: disposalInstructions ?? this.disposalInstructions,
      timestamp: timestamp ?? this.timestamp,
      isOfflineScan: isOfflineScan ?? this.isOfflineScan,
      weight: weight ?? this.weight,
      co2Saved: co2Saved ?? this.co2Saved,
      rewardPoints: rewardPoints ?? this.rewardPoints,
    );
  }
}