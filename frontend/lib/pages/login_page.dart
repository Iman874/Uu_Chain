import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/user.dart';
import 'home_page_admin.dart';
import 'home_page_user.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _login(BuildContext context, User user) {
    if (user.name.toLowerCase() == 'admin') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HomeAdminScreen(user: user),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HomeUserScreen(user: user),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UuChain Login'),
        centerTitle: true,
        elevation: 3,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: dummyUsers.length,
        itemBuilder: (context, index) {
          final user = dummyUsers[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.blueAccent),
              title: Text(
                user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                '${user.privateKey.substring(0, 10)}...',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.black54,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _login(context, user),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        },
      ),
    );
  }
}
