import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import 'owner_dashboard_screen.dart';
import 'owner_cars_screen.dart';
import 'owner_requests_screen.dart';
import 'owner_profile_screen.dart';
import 'user_home_screen.dart';
import 'messages_screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const OwnerDashboardScreen(),
          const OwnerCarsScreen(),
          const OwnerRequestsScreen(),
          const MessagesScreen(isOwnerMode: true),
          OwnerProfileScreen(
            onSwitchToUser: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const UserHomeScreen()),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_outlined),
            label: 'My Cars',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
