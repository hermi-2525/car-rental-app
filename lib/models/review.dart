import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String bookingId;
  final String carId;
  final String ownerId;
  final String userId;
  final String userName;
  final double carRating;
  final double ownerRating;
  final double cleanliness;
  final double accuracy;
  final double communication;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.bookingId,
    required this.carId,
    required this.ownerId,
    required this.userId,
    required this.userName,
    required this.carRating,
    required this.ownerRating,
    required this.cleanliness,
    required this.accuracy,
    required this.communication,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> data, String id) {
    return Review(
      id: id,
      bookingId: data['bookingId'] ?? '',
      carId: data['carId'] ?? '',
      ownerId: data['ownerId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      carRating: (data['carRating'] ?? 0).toDouble(),
      ownerRating: (data['ownerRating'] ?? 0).toDouble(),
      cleanliness: (data['cleanliness'] ?? 0).toDouble(),
      accuracy: (data['accuracy'] ?? 0).toDouble(),
      communication: (data['communication'] ?? 0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'carId': carId,
      'ownerId': ownerId,
      'userId': userId,
      'userName': userName,
      'carRating': carRating,
      'ownerRating': ownerRating,
      'cleanliness': cleanliness,
      'accuracy': accuracy,
      'communication': communication,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
