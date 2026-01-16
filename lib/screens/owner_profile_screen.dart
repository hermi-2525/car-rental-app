import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/user_header.dart';
import 'account_settings_screen.dart';

class OwnerProfileScreen extends StatelessWidget {
  final VoidCallback onSwitchToUser;

  const OwnerProfileScreen({super.key, required this.onSwitchToUser});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Owner Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const UserHeader(isOwner: true),
          const SizedBox(height: 32),

          // Switch to Renter Mode
          Card(
            color: Colors.blue[50],
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.blue[200]!),
            ),
            child: ListTile(
              leading: const Icon(Icons.swap_horiz, color: Colors.blue),
              title: const Text('Switch to Renter Mode'),
              subtitle: const Text('Book cars for yourself'),
              onTap: onSwitchToUser,
            ),
          ),

          const Divider(height: 32),

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
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await auth.signOut();
              if (context.mounted) {
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
