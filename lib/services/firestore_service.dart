import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car.dart';
import '../models/booking.dart';
import '../models/chat_model.dart';
import '../models/review.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // -- CARS --

  // Get cars owned by specific user
  Stream<List<Car>> getOwnerCars(String ownerId) {
    return _db
        .collection('cars')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Car.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Create a new car
  Future<void> createCar(Car car) async {
    final docRef = _db.collection('cars').doc(car.id);
    await docRef.set(car.toMap());
  }

  // Update an existing car
  Future<void> updateCar(Car car) async {
    await _db.collection('cars').doc(car.id).update(car.toMap());
  }

  // Delete a car
  Future<void> deleteCar(String carId) async {
    await _db.collection('cars').doc(carId).delete();
  }

  // Get all cars (optional filter)
  Stream<List<Car>> getCars({String? category}) {
    Query query = _db.collection('cars');
    if (category != null && category != 'All') {
      query = query.where('type', isEqualTo: category);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Car.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // Get specific car
  Stream<Car> getCar(String id) {
    return _db.collection('cars').doc(id).snapshots().map((doc) {
      return Car.fromMap(doc.data()!, doc.id);
    });
  }

  // -- BOOKINGS --

  // Get bookings for an owner's cars
  Stream<List<Booking>> getOwnerBookings(String ownerId) {
    return _db
        .collection('bookings')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Booking.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Get user bookings
  Stream<List<Booking>> getUserBookings(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Booking.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Create Booking
  Future<void> createBooking(Booking booking) {
    return _db.collection('bookings').doc(booking.id).set(booking.toMap());
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _db.collection('bookings').doc(bookingId).update({'status': status});
  }

  // -- CHATS --

  // Get User Chats
  Stream<List<Chat>> getUserChats(String userId) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Chat.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Get Messages
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatMessage.fromMap(doc.data()))
              .toList();
        });
  }

  // Send Message
  Future<void> sendMessage(String chatId, String senderId, String text) async {
    final message = ChatMessage(
      senderId: senderId,
      text: text,
      timestamp: DateTime.now(),
    );

    // Add message
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());

    // Update Chat with last message
    await _db.collection('chats').doc(chatId).set({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Start Chat (or get existing) - Now requires emails for display
  Future<String> startChat({
    required String myId,
    required String myName,
    required String myEmail,
    required String ownerId,
    required String ownerName,
    required String ownerEmail,
  }) async {
    // Attempt to find existing chat between these two users
    final query = await _db
        .collection('chats')
        .where('participants', arrayContains: myId)
        .get();

    final existing = query.docs.where((doc) {
      final participants = List<String>.from(doc.data()['participants']);
      return participants.contains(ownerId);
    });

    if (existing.isNotEmpty) {
      return existing.first.id;
    }

    // Create New Chat
    final chatRef = await _db.collection('chats').add({
      'participants': [myId, ownerId],
      'participantNames': {myId: myName, ownerId: ownerName},
      'participantEmails': {myId: myEmail, ownerId: ownerEmail},
      'initiatorId': myId, // The renter who started the chat
      'ownerId': ownerId, // The car owner
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
    return chatRef.id;
  }

  // Get chats where user is the RENTER (they initiated)
  Stream<List<Chat>> getRenterChats(String userId) {
    return _db
        .collection('chats')
        .where('initiatorId', isEqualTo: userId)
        // Removing orderBy to avoid index requirement for now
        .snapshots()
        .map((snapshot) {
          final chats = snapshot.docs
              .map((doc) => Chat.fromMap(doc.data(), doc.id))
              .toList();
          // Sort in-memory to fix [cloud_firestore/failed-precondition]
          chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
          return chats;
        });
  }

  // Get chats where user is the OWNER (they received contact)
  Stream<List<Chat>> getOwnerChats(String userId) {
    return _db
        .collection('chats')
        .where('ownerId', isEqualTo: userId)
        // Removing orderBy to avoid index requirement for now
        .snapshots()
        .map((snapshot) {
          final chats = snapshot.docs
              .map((doc) => Chat.fromMap(doc.data(), doc.id))
              .toList();
          // Sort in-memory to fix [cloud_firestore/failed-precondition]
          chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
          return chats;
        });
  }

  // Get User Details
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Update User Profile
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    // Use set with merge: true to avoid "not-found" error if doc doesn't exist
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>?> userStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data());
  }

  // -- REVIEWS --

  // Create a new review
  Future<void> createReview(Review review) async {
    final batch = _db.batch();

    // 1. Save review
    final reviewRef = _db.collection('reviews').doc(review.id);
    batch.set(reviewRef, review.toMap());

    // 2. Mark booking as reviewed
    final bookingRef = _db.collection('bookings').doc(review.bookingId);
    batch.update(bookingRef, {'isReviewed': true});

    await batch.commit();
  }

  // Get reviews for a specific car
  Stream<List<Review>> getCarReviews(String carId) {
    return _db
        .collection('reviews')
        .where('carId', isEqualTo: carId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Review.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Get reviews for a specific owner
  Stream<List<Review>> getOwnerReviews(String ownerId) {
    return _db
        .collection('reviews')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Review.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Get average rating for an owner
  Stream<Map<String, dynamic>> getOwnerRatingInfo(String ownerId) {
    return _db
        .collection('reviews')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return {'average': 0.0, 'count': 0};
          }
          double total = 0;
          for (var doc in snapshot.docs) {
            total += (doc.data()['ownerRating'] ?? 0).toDouble();
          }
          return {
            'average': total / snapshot.docs.length,
            'count': snapshot.docs.length,
          };
        });
  }

  // Get detailed breakdown for an owner
  Stream<Map<String, double>> getOwnerDetailedRating(String ownerId) {
    return _db
        .collection('reviews')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return {'cleanliness': 0.0, 'accuracy': 0.0, 'communication': 0.0};
          }
          double c = 0, a = 0, com = 0;
          for (var doc in snapshot.docs) {
            final data = doc.data();
            c += (data['cleanliness'] ?? 0).toDouble();
            a += (data['accuracy'] ?? 0).toDouble();
            com += (data['communication'] ?? 0).toDouble();
          }
          final count = snapshot.docs.length;
          return {
            'cleanliness': c / count,
            'accuracy': a / count,
            'communication': com / count,
          };
        });
  }

  // Check if car is available (no 'approved' bookings overlapping current time)
  Stream<bool> getCarAvailability(String carId) {
    final now = DateTime.now();
    return _db
        .collection('bookings')
        .where('carId', isEqualTo: carId)
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) {
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final start = (data['startDate'] as Timestamp).toDate();
            final end = (data['endDate'] as Timestamp).toDate();
            if (now.isAfter(start) && now.isBefore(end)) {
              return false; // Currently rented
            }
          }
          return true; // Available
        });
  }

  // Check if a specific date range is available
  Future<bool> isRangeAvailable(
    String carId,
    DateTime start,
    DateTime end,
  ) async {
    final snapshot = await _db
        .collection('bookings')
        .where('carId', isEqualTo: carId)
        .where('status', isEqualTo: 'approved')
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final bookedStart = (data['startDate'] as Timestamp).toDate();
      final bookedEnd = (data['endDate'] as Timestamp).toDate();

      // Overlap logic: (StartA <= EndB) and (EndA >= StartB)
      if (start.isBefore(bookedEnd) && end.isAfter(bookedStart)) {
        return false;
      }
    }
    return true;
  }
}
