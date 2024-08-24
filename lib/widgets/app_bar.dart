import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel/screens/setting_screen.dart';
// import 'package:travel/screens/settings_screen.dart';

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    title: const Text('Travel Journal'),
    actions: [
      IconButton(
        icon: Icon(Icons.settings),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          ));
        },
      ),
      CircleAvatar(
        backgroundImage:
            NetworkImage(FirebaseAuth.instance.currentUser?.photoURL ?? ''),
      ),
      const SizedBox(width: 10),
    ],
  );
}
