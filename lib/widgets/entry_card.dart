import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../screens/view_entery_screen.dart';

class EntryCard extends StatelessWidget {
  final JournalEntry entry;

  EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(entry.title),
        subtitle: Text(entry.date.toString()),
        leading: entry.imageUrl.isNotEmpty
            ? CircleAvatar(backgroundImage: NetworkImage(entry.imageUrl))
            : Icon(Icons.photo),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewEntryScreen(entry: entry),
            ),
          );
        },
      ),
    );
  }
}
