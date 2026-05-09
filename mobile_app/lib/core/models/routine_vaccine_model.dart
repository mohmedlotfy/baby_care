import 'package:cloud_firestore/cloud_firestore.dart';

class RoutineVaccineModel {
  final String? id;
  final String userId;
  final String infantId;
  final String name;
  final String description;
  final DateTime vaccineDate;
  final String ageAtVaccine;
  final bool isDone;
  final int notificationId;

  RoutineVaccineModel({
    this.id,
    required this.userId,
    required this.infantId,
    required this.name,
    required this.description,
    required this.vaccineDate,
    required this.ageAtVaccine,
    this.isDone = false,
    required this.notificationId,
  });

  factory RoutineVaccineModel.fromMap(Map<String, dynamic> map, String id) {
    return RoutineVaccineModel(
      id: id,
      userId: map['user_id'] ?? '',
      infantId: map['infant_id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      vaccineDate: map['vaccine_date'] != null
          ? (map['vaccine_date'] as Timestamp).toDate()
          : DateTime.now(),
      ageAtVaccine: map['age_at_vaccine'] ?? '',
      isDone: map['is_done'] ?? false,
      notificationId: map['notification_id'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'infant_id': infantId,
      'name': name,
      'description': description,
      'vaccine_date': Timestamp.fromDate(vaccineDate),
      'age_at_vaccine': ageAtVaccine,
      'is_done': isDone,
      'notification_id': notificationId,
    };
  }
}
