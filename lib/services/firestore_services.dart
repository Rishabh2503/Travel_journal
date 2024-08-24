import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel/models/journal_entry.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<JournalEntry>> getJournalEntries(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('journalEntries')
        .get();
    return snapshot.docs.map((doc) => JournalEntry.fromDocument(doc)).toList();
  }

  Future<void> addJournalEntry(String userId, String title, String description,
      DateTime timestamp) async {
    await _db.collection('users').doc(userId).collection('journalEntries').add({
      'title': title,
      'description': description,
      'timestamp': timestamp,
    });
  }
}
