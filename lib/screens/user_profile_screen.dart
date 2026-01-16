import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/user_header.dart';
import 'owner_home_screen.dart';
import 'account_settings_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const UserHeader(isOwner: false),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Account Settings'),
            subtitle: const Text('Edit name & phone number'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AccountSettingsScreen(),
                ),
              );
            },
          ),
          const Divider(height: 32),

          Card(
            color: Colors.teal[50],
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.teal[200]!),
            ),
            child: ListTile(
              leading: const Icon(Icons.swap_horiz, color: Colors.teal),
              title: const Text('Switch to Owner Mode'),
              subtitle: const Text('Manage your cars & bookings'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const OwnerHomeScreen()),
                );
              },
            ),
          ),

          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await auth.signOut();
              if (context.mounted) {
                // Pop all routes until we get to the root (which usually triggers the AuthWrapper)
                // Or navigate explicitly to Login if usage of Wrapper is not triggering on all navigators.
                // Since we are in a pushed route (likely), we might need to pop.
                // However, AuthWrapper should be handled in Main.
                // If we are deep in stack, the wrapper might rebuild the whole app.
                // Let's try popping everything off.
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}
