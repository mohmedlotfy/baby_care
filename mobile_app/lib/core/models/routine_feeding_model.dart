import 'package:cloud_firestore/cloud_firestore.dart';

class RoutineFeedingModel {
  final String? id;
  final String userId;
  final String infantId;
  final String type;
  final String amount;
  final DateTime feedingTime;

  RoutineFeedingModel({
    this.id,
    required this.userId,
    required this.infantId,
    required this.type,
    required this.amount,
    required this.feedingTime,
  });

  factory RoutineFeedingModel.fromMap(Map<String, dynamic> map, String id) {
    return RoutineFeedingModel(
      id: id,
      userId: map['user_id'] ?? '',
      infantId: map['infant_id'] ?? '',
      type: map['type'] ?? '',
      amount: map['amount'] ?? '',
      feedingTime: map['feeding_time'] != null
          ? (map['feeding_time'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'infant_id': infantId,
      'type': type,
      'amount': amount,
      'feeding_time': Timestamp.fromDate(feedingTime),
    };
  }
}
