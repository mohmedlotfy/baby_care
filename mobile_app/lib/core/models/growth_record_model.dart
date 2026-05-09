import 'package:cloud_firestore/cloud_firestore.dart';

class GrowthRecordModel {
  final String? id;
  final String userId;
  final String infantId;
  final double weight;
  final double height;
  final int ageInMonths;
  final DateTime date;

  GrowthRecordModel({
    this.id,
    required this.userId,
    required this.infantId,
    required this.weight,
    required this.height,
    required this.ageInMonths,
    required this.date,
  });

  factory GrowthRecordModel.fromMap(Map<String, dynamic> map, String id) {
    return GrowthRecordModel(
      id: id,
      userId: map['user_id'] ?? '',
      infantId: map['infant_id'] ?? '',
      weight: (map['weight'] ?? 0.0).toDouble(),
      height: (map['height'] ?? 0.0).toDouble(),
      ageInMonths: map['age_in_months'] ?? 0,
      date: map['date'] != null 
          ? (map['date'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'infant_id': infantId,
      'weight': weight,
      'height': height,
      'age_in_months': ageInMonths,
      'date': Timestamp.fromDate(date),
    };
  }
}
