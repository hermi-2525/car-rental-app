import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/car.dart';
import '../models/booking.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class BookingFlowScreen extends StatefulWidget {
  final String carId;

  const BookingFlowScreen({super.key, required this.carId});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  DateTimeRange? _selectedDateRange;
  bool _isLoading = false;
  bool? _isAvailable;

  Future<void> _checkAvailability(String carId, DateTimeRange range) async {
    final firestore = context.read<FirestoreService>();
    final available = await firestore.isRangeAvailable(
      carId,
      range.start,
      range.end,
    );
    if (mounted) {
      setState(() {
        _isAvailable = available;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    final user = context.read<AuthService>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Book Car')),
      body: StreamBuilder<Car>(
        stream: firestore.getCar(widget.carId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final car = snapshot.data!;
          final days = _selectedDateRange?.duration.inDays ?? 0;
          final totalPrice = days * car.price;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Car Summary
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: car.image,
                            width: 100,
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: Colors.grey[100]),
                            errorWidget: (_, __, ___) => Container(
                              width: 100,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                car.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                car.type,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(
                                '\$${car.price.toStringAsFixed(0)}/day',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Date Selection
                    const Text(
                      'Select Dates',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 90),
                          ),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Theme.of(context).primaryColor,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDateRange = picked;
                            _isAvailable = null;
                          });
                          await _checkAvailability(car.id, picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isAvailable == false
                                ? Colors.red
                                : (_isAvailable == true
                                      ? Colors.green
                                      : Colors.grey[300]!),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: _isAvailable == false ? Colors.red[50] : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: _isAvailable == false ? Colors.red : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedDateRange == null
                                    ? 'Choose pickup & return date'
                                    : '${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd').format(_selectedDateRange!.end)}',
                                style: TextStyle(
                                  color: _isAvailable == false
                                      ? Colors.red
                                      : null,
                                  fontWeight: _selectedDateRange != null
                                      ? FontWeight.w500
                                      : null,
                                ),
                              ),
                            ),
                            if (_isAvailable == true)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                            if (_isAvailable == false)
                              const Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),

                    if (_isAvailable == false)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          'These dates are already booked. Please choose others.',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                      ),

                    if (_selectedDateRange != null && _isAvailable == true) ...[
                      const SizedBox(height: 32),
                      const Text(
                        'Price Breakdown',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPriceRow(
                        '\$${car.price} x $days days',
                        '\$${totalPrice.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 8),
                      _buildPriceRow('Service Fee', '\$50.00'),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            '\$${(totalPrice + 50).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Bottom Action
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        _selectedDateRange == null ||
                            _isLoading ||
                            _isAvailable != true
                        ? null
                        : () async {
                            setState(() => _isLoading = true);
                            try {
                              final booking = Booking(
                                id: DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                carId: car.id,
                                carName: car.name,
                                carImage: car.image,
                                userId: user?.uid ?? 'unknown',
                                userName: user?.displayName ?? 'User',
                                ownerId: car.ownerId,
                                startDate: _selectedDateRange!.start,
                                endDate: _selectedDateRange!.end,
                                totalPrice: totalPrice + 50,
                                status: 'pending',
                                tripType: 'Standard',
                              );

                              await firestore.createBooking(booking);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Booking Request Sent!'),
                                  ),
                                );
                                Navigator.popUntil(
                                  context,
                                  (route) => route.isFirst,
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Confirm Booking',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
