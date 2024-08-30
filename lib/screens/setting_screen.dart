import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:travel/models/user_modal.dart';
// import 'package:travel/models/user_model.dart';
import 'package:travel/screens/auth_screen.dart';

class SettingsScreen extends StatelessWidget {
  final UserModel user;

  const SettingsScreen({super.key, required this.user});

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

                // Redirect to the AuthScreen after sign out
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
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
