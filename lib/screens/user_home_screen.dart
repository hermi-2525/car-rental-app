import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/car.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/car_card.dart';
import 'car_details_screen.dart';
import 'user_bookings_screen.dart';
import 'messages_screen.dart';
import 'user_profile_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final List<String> _categories = ['All', 'Sedan', 'SUV', 'Compact', 'Luxury'];

  // Usage filters
  final List<String> _usageOptions = ['city', 'long distance', 'mountain'];
  final Set<String> _selectedUsageFilters = {};

  @override
  Widget build(BuildContext context) {
    if (_currentIndex == 1) return _wrapWithNav(const UserBookingsScreen());
    if (_currentIndex == 2)
      return _wrapWithNav(const MessagesScreen(isOwnerMode: false));
    if (_currentIndex == 3) return _wrapWithNav(const UserProfileScreen());

    final firestore = context.read<FirestoreService>();

    return _wrapWithNav(
      Scaffold(
        appBar: AppBar(
          title: const Text('Hermi Car Rental'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search cars...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                },
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Category Filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(category),
                      onSelected: (selected) {
                        setState(() => _selectedCategory = category);
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.2),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),

            // Usage Filter Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Text(
                    'Usage:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  ..._usageOptions.map((usage) {
                    final isSelected = _selectedUsageFilters.contains(usage);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(
                          usage[0].toUpperCase() + usage.substring(1),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedUsageFilters.add(usage);
                            } else {
                              _selectedUsageFilters.remove(usage);
                            }
                          });
                        },
                        backgroundColor: Colors.teal[50],
                        selectedColor: Colors.teal[200],
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.teal[900]
                              : Colors.teal[700],
                        ),
                        showCheckmark: true,
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Car List
            Expanded(
              child: StreamBuilder<List<Car>>(
                stream: firestore.getCars(category: _selectedCategory),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final cars = snapshot.data ?? [];

                  // Filter by Search Query AND Usage
                  final filteredCars = cars.where((car) {
                    final matchesSearch =
                        car.name.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ||
                        car.location.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        );

                    bool matchesUsage = true;
                    if (_selectedUsageFilters.isNotEmpty) {
                      matchesUsage = car.usage.any(
                        (u) => _selectedUsageFilters.contains(u),
                      );
                    }

                    return matchesSearch && matchesUsage;
                  }).toList();

                  if (filteredCars.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.car_rental,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No ${_selectedCategory == 'All' ? '' : _selectedCategory} cars found',
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredCars.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return CarCard(
                        car: filteredCars[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CarDetailsScreen(
                                carId: filteredCars[index].id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isHome: true,
    );
  }

  Widget _wrapWithNav(Widget child, {bool isHome = false}) {
    // If it's a Scaffold, we want to inject the BottomNav into it.
    // If it's already a Scaffold, we probably want to replace its bottomNavItem.
    // However, the cleanest way is to have one Scaffold for the main layout or wrap the body.
    // But since the child screens (Bookings, etc) are currently Scaffolds, we can wrap them in a Column or just use bottomNavigationBar property if we could pass it.
    // Actually, let's just wrap the body content in a generic Scaffold here OR modify the children to not be Scaffolds.
    // For simplicity given the current structure, I will stick to returning the child if it's not home, but assume we want the nav bar on all of them.

    // Better approach: Use IndexedStack for state preservation, OR just conditional rendering but we need the BottomNav visible.

    if (child is Scaffold) {
      // Allow the child scaffold to define body/appbar, but override bottomNavigationBar
      return Scaffold(
        appBar: child.appBar,
        body: child.body,
        floatingActionButton: child.floatingActionButton,
        bottomNavigationBar: BottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
