class VaccineModel {
  final int? id;
  final String userId;
  final String name;
  final DateTime vaccineDate;
  final String? notificationTime;
  final String description;
  final String ageAtVaccine;
  final bool isDone;

  VaccineModel({
    this.id,
    required this.userId,
    required this.name,
    required this.vaccineDate,
    this.notificationTime,
    required this.description,
    required this.ageAtVaccine,
    required this.isDone,
  });

  factory VaccineModel.fromMap(Map<String, dynamic> map) {
    return VaccineModel(
      id: map['id'],
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      vaccineDate: DateTime.parse(map['vaccine_date']),
      notificationTime: map['notification_time'],
      description: map['description'] ?? '',
      ageAtVaccine: map['age_at_vaccine'] ?? '',
      isDone: map['is_done'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'vaccine_date': vaccineDate.toIso8601String().split('T')[0],
      'notification_time': notificationTime,
      'description': description,
      'age_at_vaccine': ageAtVaccine,
      'is_done': isDone,
    };
  }
}

class FeedingModel {
  final int? id;
  final String userId;
  final String type;
  final String amount;
  final String feedingTime;
  final bool isDone;
  final DateTime? createdAt;

  FeedingModel({
    this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.feedingTime,
    required this.isDone,
    this.createdAt,
  });

  factory FeedingModel.fromMap(Map<String, dynamic> map) {
    return FeedingModel(
      id: map['id'],
      userId: map['user_id'] ?? '',
      type: map['type'] ?? '',
      amount: map['amount'] ?? '',
      feedingTime: map['feeding_time'] ?? '',
      isDone: map['is_done'] ?? false,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'type': type,
      'amount': amount,
      'feeding_time': feedingTime,
      'is_done': isDone,
    };
  }
}
