import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime timestamp;
  final String? locationName; // Add the locationName field

  JournalEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.timestamp,
    this.locationName, // Optional field for location
  });

  factory JournalEntry.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JournalEntry(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      locationName:
          data['locationName'], // Retrieve locationName from Firestore
    );
  }
}
