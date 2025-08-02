import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final int totalScans;
  final double co2Saved;
  final int rewardPoints;
  final int hazardousWasteHandled;
  final String language;
  final int dailyStreak;
  final int consecutiveCorrectScans;
  final DateTime? lastScanDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.totalScans = 0,
    this.co2Saved = 0.0,
    this.rewardPoints = 0,
    this.hazardousWasteHandled = 0,
    this.language = 'en',
    this.dailyStreak = 0,
    this.consecutiveCorrectScans = 0,
    this.lastScanDate,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      name: data['name'],
      photoUrl: data['photoUrl'],
      totalScans: data['totalScans'] ?? 0,
      co2Saved: (data['co2Saved'] ?? 0).toDouble(),
      rewardPoints: data['rewardPoints'] ?? 0,
      hazardousWasteHandled: data['hazardousWasteHandled'] ?? 0,
      language: data['language'] ?? 'en',
      dailyStreak: data['dailyStreak'] ?? 0,
      consecutiveCorrectScans: data['consecutiveCorrectScans'] ?? 0,
      lastScanDate: data['lastScanDate'] != null 
          ? (data['lastScanDate'] as Timestamp).toDate() 
          : null,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'totalScans': totalScans,
      'co2Saved': co2Saved,
      'rewardPoints': rewardPoints,
      'hazardousWasteHandled': hazardousWasteHandled,
      'language': language,
      'dailyStreak': dailyStreak,
      'consecutiveCorrectScans': consecutiveCorrectScans,
      'lastScanDate': lastScanDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserModel copyWith({
    String? name,
    String? photoUrl,
    int? totalScans,
    double? co2Saved,
    int? rewardPoints,
    int? hazardousWasteHandled,
    String? language,
    int? dailyStreak,
    int? consecutiveCorrectScans,
    DateTime? lastScanDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: this.id,
      email: this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      totalScans: totalScans ?? this.totalScans,
      co2Saved: co2Saved ?? this.co2Saved,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      hazardousWasteHandled: hazardousWasteHandled ?? this.hazardousWasteHandled,
      language: language ?? this.language,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      consecutiveCorrectScans: consecutiveCorrectScans ?? this.consecutiveCorrectScans,
      lastScanDate: lastScanDate ?? this.lastScanDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}