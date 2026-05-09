class InfantModel {
  final String? id;
  final String userId;
  final String name;
  final DateTime dateOfBirth;
  final String gender;
  final double birthWeightKg;
  final String? imageUrl;

  InfantModel({
    this.id,
    required this.userId,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.birthWeightKg,
    this.imageUrl,
  });

  factory InfantModel.fromMap(Map<String, dynamic> map) {
    return InfantModel(
      id: map['id']?.toString(),
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      dateOfBirth: DateTime.parse(map['date_of_birth']),
      gender: map['gender'] ?? 'female',
      birthWeightKg: (map['birth_weight_kg'] ?? 0.0).toDouble(),
      imageUrl: map['image_url']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
      'gender': gender,
      'birth_weight_kg': birthWeightKg,
      'image_url': imageUrl,
    };
  }

  // Helper to calculate age
  String get ageText {
    final now = DateTime.now();
    int months = (now.year - dateOfBirth.year) * 12 + (now.month - dateOfBirth.month);
    if (now.day < dateOfBirth.day) months--;

    if (months < 1) {
      final days = now.difference(dateOfBirth).inDays;
      return '$days يوم';
    } else if (months < 12) {
      return '$months شهر';
    } else {
      final years = months ~/ 12;
      final remainingMonths = months % 12;
      if (remainingMonths == 0) return '$years سنة';
      return '$years سنة و $remainingMonths شهر';
    }
  }
}
