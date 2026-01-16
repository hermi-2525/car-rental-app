import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/booking.dart';
import 'package:hermi/screens/owner_cars_screen.dart';
import 'package:hermi/screens/owner_requests_screen.dart';
import 'package:hermi/screens/owner_profile_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;
    final firestore = context.read<FirestoreService>();

    if (user == null) return const Center(child: Text('Please log in'));

    return Scaffold(
      appBar: AppBar(title: const Text('Owner Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Statistics Section - Real Data
            StreamBuilder<List<Booking>>(
              stream: firestore.getOwnerBookings(user.uid),
              builder: (context, snapshot) {
                final bookings = snapshot.data ?? [];

                // Calculate Metrics
                final totalRevenue = bookings
                    .where(
                      (b) => b.status == 'approved' || b.status == 'completed',
                    )
                    .fold(0.0, (sum, b) => sum + b.totalPrice);

                final activeTrips = bookings
                    .where(
                      (b) =>
                          b.status == 'approved' &&
                          b.endDate.isAfter(DateTime.now()),
                    )
                    .length;

                return Column(
                  children: [
                    _buildStatCard(
                      'Total Revenue',
                      '${totalRevenue.toStringAsFixed(0)} Birr',
                      Icons.attach_money,
                      Colors.green,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Active Trips',
                            '$activeTrips',
                            Icons.directions_car,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Total Bookings',
                            '${bookings.length}',
                            Icons.assignment_turned_in,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Bookings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (bookings.isEmpty)
                      const Center(child: Text('No bookings yet'))
                    else
                      ...bookings
                          .take(3)
                          .map(
                            (booking) => Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: booking.carImage,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) =>
                                        Container(color: Colors.grey[100]),
                                    errorWidget: (_, __, ___) =>
                                        const Icon(Icons.car_rental),
                                  ),
                                ),
                                title: Text(
                                  booking.carName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(booking.userName),
                                trailing: Text(
                                  '\$${booking.totalPrice}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
