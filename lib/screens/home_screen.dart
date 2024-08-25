// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel/models/journal_entry.dart';
import 'package:travel/screens/auth_screen.dart';
import 'package:travel/screens/journal_entry_screen.dart';
import 'package:travel/widgets/journal_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? _user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Travel Journal"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsMenu(context),
          ),
          CircleAvatar(
            backgroundImage: NetworkImage(_user?.photoURL ?? ''),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('journal_entries')
            .where('userId', isEqualTo: _user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final entries = snapshot.data?.docs.map((doc) {
                return JournalEntry.fromDocument(doc);
              }).toList() ??
              [];

          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.book, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No travel entries yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start adding your travel memories!',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => JournalEntryScreen()),
                      );
                    },
                    child: const Text('Add New Entry'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return JournalCard(entry: entry);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => JournalEntryScreen()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor:
            Colors.lightBlueAccent, // Update with your desired color
      ),
    );
  }
}

void _showSettingsMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: Colors.black),
              title: const Text('Profile'),
              onTap: () {
                // Handle Profile navigation
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.black),
              title: const Text('Edit Entry'),
              onTap: () {
                // Handle Edit Entry navigation
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () async {
                await _logoutAndRedirect(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

Future<void> _logoutAndRedirect(BuildContext context) async {
  try {
    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();

    // Optionally clear any local data if needed
    // Example: SharedPreferences.getInstance().then((prefs) => prefs.clear());

    // Redirect to login page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (context) =>
              const LoginScreen()), // Replace with your login screen widget
      (route) => false,
    );
  } catch (e) {
    // Handle any errors during sign out
    // ignore: duplicate_ignore
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error signing out: $e')),
    );
  }
}
