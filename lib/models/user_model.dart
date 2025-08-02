class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final int totalScans;
  final double co2Saved;
  final int rewardPoints;
  final DateTime? lastScanDate;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.totalScans = 0,
    this.co2Saved = 0.0,
    this.rewardPoints = 0,
    this.lastScanDate,
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
      lastScanDate: data['lastScanDate'] != null 
          ? (data['lastScanDate'] as DateTime) 
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
      'lastScanDate': lastScanDate,
    };
  }

  UserModel copyWith({
    String? name,
    String? photoUrl,
    int? totalScans,
    double? co2Saved,
    int? rewardPoints,
    DateTime? lastScanDate,
  }) {
    return UserModel(
      id: this.id,
      email: this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      totalScans: totalScans ?? this.totalScans,
      co2Saved: co2Saved ?? this.co2Saved,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      lastScanDate: lastScanDate ?? this.lastScanDate,
    );
  }
}