import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/firestore_service.dart';
import '../models/car.dart';
import '../services/auth_service.dart';
import 'messages_screen.dart';
import 'booking_flow_screen.dart';
import 'owner_rating_details_screen.dart';

class CarDetailsScreen extends StatelessWidget {
  final String carId;

  const CarDetailsScreen({super.key, required this.carId});

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();

    return StreamBuilder<Car>(
      stream: firestore.getCar(carId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text('Car not found')));
        }

        final car = snapshot.data!;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: car.image,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      // Availability Badge
                      StreamBuilder<bool>(
                        stream: firestore.getCarAvailability(carId),
                        builder: (context, availSnap) {
                          final isAvailable = availSnap.data ?? true;
                          return Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isAvailable
                                    ? Colors.green.withOpacity(0.9)
                                    : Colors.red.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isAvailable ? 'AVAILABLE' : 'RENTED',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            car.name,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${car.price.toStringAsFixed(0)}/day',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Owner Rating Summary Row
                      StreamBuilder<Map<String, dynamic>>(
                        stream: firestore.getOwnerRatingInfo(car.ownerId),
                        builder: (context, ratingSnap) {
                          final data =
                              ratingSnap.data ?? {'average': 0.0, 'count': 0};
                          final avg = data['average'] as double;
                          final count = data['count'] as int;

                          return Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                avg.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '($count renters reviews)',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OwnerRatingDetailsScreen(
                                        ownerId: car.ownerId,
                                        ownerName: 'Owner',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('More Details'),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            car.location,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              car.type,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Text(
                        'Features',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: car.features.isEmpty
                            ? [
                                const Text(
                                  'No features listed',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ]
                            : car.features.map((feature) {
                                return Chip(
                                  label: Text(feature),
                                  backgroundColor: Colors.grey[100],
                                  labelStyle: const TextStyle(fontSize: 12),
                                );
                              }).toList(),
                      ),

                      const SizedBox(height: 24),
                      Text(
                        'Best Used For',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: car.usage.isEmpty
                            ? [
                                const Text(
                                  'No usage info',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ]
                            : car.usage.map((u) {
                                return Chip(
                                  label: Text(
                                    u[0].toUpperCase() + u.substring(1),
                                  ),
                                  backgroundColor: Colors.teal[50],
                                  labelStyle: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.teal,
                                  ),
                                );
                              }).toList(),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () async {
                    final auth = context.read<AuthService>();
                    final user = auth.currentUser;
                    if (user == null) return;

                    final myData = await firestore.getUser(user.uid);
                    final ownerData = await firestore.getUser(car.ownerId);

                    final myName =
                        myData?['displayName'] ?? user.displayName ?? 'User';
                    final ownerEmail = ownerData?['email'] ?? '';
                    final ownerName = ownerData?['displayName'] ?? 'Owner';

                    final chatId = await firestore.startChat(
                      myId: user.uid,
                      myName: myName,
                      myEmail: user.email ?? '',
                      ownerId: car.ownerId,
                      ownerName: ownerName,
                      ownerEmail: ownerEmail,
                    );

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: chatId,
                            otherUserName: ownerName,
                            otherUserEmail: ownerEmail,
                            otherUserId: car.ownerId,
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StreamBuilder<bool>(
                    stream: firestore.getCarAvailability(carId),
                    builder: (context, availSnap) {
                      final isAvailable = availSnap.data ?? true;
                      return FilledButton(
                        onPressed: !isAvailable
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        BookingFlowScreen(carId: car.id),
                                  ),
                                );
                              },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: isAvailable
                              ? null
                              : Colors.grey[400],
                        ),
                        child: Text(
                          isAvailable ? 'Book Now' : 'Currently Rented',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
