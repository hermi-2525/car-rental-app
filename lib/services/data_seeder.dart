import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car.dart';

class DataSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> _mockCars = [
    {
      'id': '1',
      'name': 'Toyota Corolla 2022',
      'type': 'Sedan',
      'price': 1200,
      'rating': 4.8,
      'image':
          'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800&auto=format&fit=crop',
      'routeFitScore': 95,
      'ownerId': 'owner1',
      'features': ['AC', 'Bluetooth', 'GPS', 'Backup Camera'],
      'suitable': ['City', 'Long Distance'],
      'location': 'Addis Ababa',
      'usage': ['city', 'long distance'],
    },
    {
      'id': '2',
      'name': 'Toyota Land Cruiser',
      'type': 'SUV',
      'price': 3500,
      'rating': 4.9,
      'image':
          'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800&auto=format&fit=crop',
      'routeFitScore': 98,
      'ownerId': 'owner2',
      'features': ['4WD', 'AC', 'GPS', '7 Seats'],
      'suitable': ['Mountain', 'Long Distance'],
      'location': 'Addis Ababa',
      'usage': ['mountain', 'long distance'],
    },
    {
      'id': '3',
      'name': 'Suzuki Swift 2021',
      'type': 'Compact',
      'price': 800,
      'rating': 4.5,
      'image':
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&auto=format&fit=crop',
      'routeFitScore': 88,
      'ownerId': 'owner3',
      'features': ['AC', 'Bluetooth', 'Fuel Efficient'],
      'suitable': ['City'],
      'location': 'Adama',
      'usage': ['city'],
    },
    {
      'id': '4',
      'name': 'Hyundai Tucson 2023',
      'type': 'SUV',
      'price': 2200,
      'rating': 4.7,
      'image':
          'https://images.unsplash.com/photo-1619767886558-efdc259cde1a?w=800&auto=format&fit=crop',
      'routeFitScore': 92,
      'ownerId': 'owner4',
      'features': ['AC', 'Sunroof', 'GPS', 'Backup Camera'],
      'suitable': ['City', 'Long Distance'],
      'location': 'Addis Ababa',
      'usage': ['city', 'long distance'],
    },
    {
      'id': '5',
      'name': 'Nissan Patrol',
      'type': 'SUV',
      'price': 4000,
      'rating': 4.9,
      'image':
          'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800&auto=format&fit=crop',
      'routeFitScore': 97,
      'ownerId': 'owner1',
      'features': ['4WD', 'AC', 'GPS', 'Leather Seats'],
      'suitable': ['Mountain', 'Long Distance'],
      'location': 'Bahir Dar',
      'usage': ['mountain', 'long distance'],
    },
  ];

  Future<void> seedCars() async {
    final batch = _db.batch();

    for (var carData in _mockCars) {
      final docRef = _db.collection('cars').doc(carData['id'].toString());
      // Ensure types are correct for the Car model
      batch.set(docRef, carData);
    }

    try {
      await batch.commit();
      print('Cars seeded successfully');
    } catch (e) {
      print('Error seeding cars: $e');
      rethrow;
    }
  }
}
