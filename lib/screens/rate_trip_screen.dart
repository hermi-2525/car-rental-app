import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/review.dart';

class RateTripScreen extends StatefulWidget {
  final String bookingId;
  final String ownerId;
  final String carId;

  const RateTripScreen({
    super.key,
    required this.bookingId,
    required this.ownerId,
    required this.carId,
  });

  @override
  State<RateTripScreen> createState() => _RateTripScreenState();
}

class _RateTripScreenState extends State<RateTripScreen> {
  int _carRating = 5;
  int _ownerRating = 5;
  double _cleanliness = 80;
  double _accuracy = 80;
  double _communication = 80;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate Your Experience')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Rating
            const Text(
              'Rate the Car',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStarRating(
              _carRating,
              (val) => setState(() => _carRating = val),
            ),
            const SizedBox(height: 24),

            // Owner Rating
            const Text(
              'Rate the Owner',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStarRating(
              _ownerRating,
              (val) => setState(() => _ownerRating = val),
            ),
            const SizedBox(height: 24),

            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Detailed Ratings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Sliders
            _buildSliderCategory(
              'Cleanliness',
              _cleanliness,
              (val) => setState(() => _cleanliness = val),
            ),
            const SizedBox(height: 16),
            _buildSliderCategory(
              'Accuracy',
              _accuracy,
              (val) => setState(() => _accuracy = val),
            ),
            const SizedBox(height: 16),
            _buildSliderCategory(
              'Communication',
              _communication,
              (val) => setState(() => _communication = val),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _submitReview,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.teal,
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
                    : const Text('Submit Rating'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(int current, Function(int) onSelected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () => onSelected(index + 1),
          icon: Icon(
            index < current ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 40,
          ),
        );
      }),
    );
  }

  Widget _buildSliderCategory(
    String label,
    double value,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Text(
              '${value.toInt()}%',
              style: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 20,
          activeColor: Colors.teal,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _submitReview() async {
    if (_carRating == 0 || _ownerRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide ratings for both car and owner'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthService>();
      final firestore = context.read<FirestoreService>();

      final review = Review(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bookingId: widget.bookingId,
        carId: widget.carId,
        ownerId: widget.ownerId,
        userId: auth.currentUser!.uid,
        userName: auth.currentUser!.displayName ?? 'User',
        carRating: _carRating.toDouble(),
        ownerRating: _ownerRating.toDouble(),
        cleanliness: _cleanliness,
        accuracy: _accuracy,
        communication: _communication,
        comment: '',
        createdAt: DateTime.now(),
      );

      await firestore.createReview(review);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your feedback!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
