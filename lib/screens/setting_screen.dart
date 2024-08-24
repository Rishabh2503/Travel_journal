import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:travel/screens/home_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              child: const Text('Sign Out'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to Edit Profile Screen
              },
              child: const Text('Edit Profile'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to User Info Screen
              },
              child: const Text('User Info'),
            ),
          ],
        ),
      ),
    );
  }
}
