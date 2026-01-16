import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../services/firestore_service.dart';
import 'package:provider/provider.dart';

class BookingDetailsScreen extends StatefulWidget {
  final Booking booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  late DateTime _viewingDate;
  late DateTime _today;
  late DateTime _returnDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _returnDate = DateTime(
      widget.booking.endDate.year,
      widget.booking.endDate.month,
      widget.booking.endDate.day,
    );
    // Start by viewing the return date month
    _viewingDate = DateTime(_returnDate.year, _returnDate.month, 1);
  }

  void _nextMonth() {
    setState(() {
      _viewingDate = DateTime(_viewingDate.year, _viewingDate.month + 1, 1);
    });
  }

  void _prevMonth() {
    setState(() {
      _viewingDate = DateTime(_viewingDate.year, _viewingDate.month - 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Request Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: widget.booking.carImage,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey[100]),
                errorWidget: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.booking.carName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            // Renter Identity Section
            const Text(
              'Renter Identity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>?>(
              future: firestore.getUser(widget.booking.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }
                final userData = snapshot.data;
                final name =
                    userData?['displayName'] ?? widget.booking.userName;
                final email = userData?['email'] ?? 'No email provided';
                final phone = userData?['phoneNumber'] ?? 'No phone provided';

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(email, style: TextStyle(color: Colors.grey[600])),
                        Text(phone, style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),

            // Return Timeline Header with Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Return Timeline',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: _prevMonth,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_viewingDate),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: _nextMonth,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Grid-based Monthly Calendar UI
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Days of the week header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                        .map(
                          (day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  // Calendar Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                    itemCount: (() {
                      final firstDay = DateTime(
                        _viewingDate.year,
                        _viewingDate.month,
                        1,
                      );
                      final lastDay = DateTime(
                        _viewingDate.year,
                        _viewingDate.month + 1,
                        0,
                      );
                      final offset = firstDay.weekday % 7;
                      return offset + lastDay.day;
                    })(),
                    itemBuilder: (context, index) {
                      final firstDay = DateTime(
                        _viewingDate.year,
                        _viewingDate.month,
                        1,
                      );
                      final offset = firstDay.weekday % 7;

                      if (index < offset) {
                        return const SizedBox.shrink();
                      }

                      final dayNum = index - offset + 1;
                      final date = DateTime(
                        _viewingDate.year,
                        _viewingDate.month,
                        dayNum,
                      );

                      final isToday =
                          date.year == _today.year &&
                          date.month == _today.month &&
                          date.day == _today.day;

                      final isReturnDay =
                          date.year == _returnDate.year &&
                          date.month == _returnDate.month &&
                          date.day == _returnDate.day;

                      return Container(
                        decoration: BoxDecoration(
                          color: isReturnDay
                              ? Colors.blue
                              : (isToday
                                    ? Colors.blue[50]
                                    : Colors.transparent),
                          borderRadius: BorderRadius.circular(8),
                          border: isToday
                              ? Border.all(color: Colors.blue, width: 2)
                              : null,
                          boxShadow: isReturnDay
                              ? [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            dayNum.toString(),
                            style: TextStyle(
                              fontWeight: isReturnDay || isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isReturnDay
                                  ? Colors.white
                                  : (isToday ? Colors.blue : Colors.black87),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                _buildLegendItem(Colors.blue[50]!, Colors.blue, 'Today'),
                const SizedBox(width: 16),
                _buildLegendItem(
                  Colors.blue,
                  Colors.blue,
                  'Expected Return',
                  isSolid: true,
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Trip Details
            _buildDetailRow('Trip Type', widget.booking.tripType),
            _buildDetailRow(
              'Start Date',
              DateFormat('MMM d, yyyy').format(widget.booking.startDate),
            ),
            _buildDetailRow(
              'End Date',
              DateFormat('MMM d, yyyy').format(widget.booking.endDate),
            ),
            _buildDetailRow('Total Price', '\$${widget.booking.totalPrice}'),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This car must be returned by ${DateFormat('h:mm a').format(widget.booking.endDate)} on ${DateFormat('MMM d').format(widget.booking.endDate)}.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    Color bgColor,
    Color borderColor,
    String label, {
    bool isSolid = false,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
