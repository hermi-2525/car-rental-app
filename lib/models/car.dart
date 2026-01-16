class Car {
  final String id;
  final String ownerId;
  final String name;
  final String type;
  final double price;
  final double rating;
  final String image;
  final int routeFitScore;
  final List<String> features;
  final List<String> suitable;
  final String location;
  final List<String> usage; // city, long distance, mountain

  Car({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.type,
    required this.price,
    required this.rating,
    required this.image,
    required this.routeFitScore,
    required this.features,
    required this.suitable,
    required this.location,
    required this.usage,
  });

  factory Car.fromMap(Map<String, dynamic> data, String id) {
    return Car(
      id: id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
      image: data['image'] ?? '',
      routeFitScore: data['routeFitScore'] ?? 0,
      features: List<String>.from(data['features'] ?? []),
      suitable: List<String>.from(data['suitable'] ?? []),
      location: data['location'] ?? '',
      usage: List<String>.from(data['usage'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'type': type,
      'price': price,
      'rating': rating,
      'image': image,
      'routeFitScore': routeFitScore,
      'features': features,
      'suitable': suitable,
      'location': location,
      'usage': usage,
    };
  }
}
