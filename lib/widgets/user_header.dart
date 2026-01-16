import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class UserHeader extends StatelessWidget {
  final bool isOwner;

  const UserHeader({super.key, this.isOwner = false});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final firestore = context.read<FirestoreService>();

    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<Map<String, dynamic>?>(
      stream: firestore.userStream(user.uid),
      builder: (context, snapshot) {
        final userData = snapshot.data;
        final name = userData?['displayName'] ?? user.displayName ?? 'User';
        final email = userData?['email'] ?? user.email ?? '';
        final phone = userData?['phoneNumber'] ?? '';

        return Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: isOwner ? Colors.teal[100] : Colors.blue[100],
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 36,
                    color: isOwner ? Colors.teal[800] : Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(email, style: TextStyle(color: Colors.grey[600])),
              if (phone.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    phone,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
              if (isOwner)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: const Text(
                      'Verified Owner',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
