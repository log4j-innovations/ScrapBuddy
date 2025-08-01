class WasteClassification {
  final String wasteType;
  final String itemName;
  final String recyclability;
  final int monetaryValue;
  final String disposalInstructions;
  final String? translatedName;
  final String? translatedInstructions; // Added this field

  WasteClassification({
    required this.wasteType,
    required this.itemName,
    required this.recyclability,
    required this.monetaryValue,
    required this.disposalInstructions,
    this.translatedName,
    this.translatedInstructions, // Added this parameter
  });

  factory WasteClassification.fromJson(Map<String, dynamic> json) {
    return WasteClassification(
      wasteType: json['wasteType']?.toString() ?? 'Unknown',
      itemName: json['itemName']?.toString() ?? 'Unknown Item',
      recyclability: json['recyclability']?.toString() ?? 'Unknown',
      monetaryValue: int.tryParse(json['monetaryValue']?.toString() ?? '0') ?? 0,
      disposalInstructions: json['disposalInstructions']?.toString() ?? 'No instructions available',
      translatedName: json['translatedName']?.toString(),
      translatedInstructions: json['translatedInstructions']?.toString(),
    );
  }
}
