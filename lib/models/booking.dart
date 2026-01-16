import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String carId;
  final String carName;
  final String carImage;
  final String userId;
  final String userName;
  final String ownerId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String
  status; // 'pending' | 'approved' | 'rejected' | 'completed' | 'paid'
  final String tripType;
  final bool isReviewed;

  Booking({
    required this.id,
    required this.carId,
    required this.carName,
    required this.carImage,
    required this.userId,
    required this.userName,
    required this.ownerId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.tripType,
    this.isReviewed = false,
  });

  factory Booking.fromMap(Map<String, dynamic> data, String id) {
    return Booking(
      id: id,
      carId: data['carId'] ?? '',
      carName: data['carName'] ?? 'Unknown Car',
      carImage: data['carImage'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'User',
      ownerId: data['ownerId'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      tripType: data['tripType'] ?? '',
      isReviewed: data['isReviewed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'carName': carName,
      'carImage': carImage,
      'userId': userId,
      'userName': userName,
      'ownerId': ownerId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'totalPrice': totalPrice,
      'status': status,
      'tripType': tripType,
      'isReviewed': isReviewed,
    };
  }
}
