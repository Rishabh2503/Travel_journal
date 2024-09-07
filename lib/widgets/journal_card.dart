import 'package:flutter/material.dart';
import 'package:travel/models/journal_entry.dart';

class JournalCard extends StatelessWidget {
  final JournalEntry entry;

  const JournalCard({Key? key, required this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display the image if the imageUrl is not empty
          if (entry.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                entry.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: double.infinity,
                    height: 200,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  height: 200,
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the title
                Text(
                  entry.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),

                // Display the description
                Text(
                  entry.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),

                // Display the location name (if available)
                if (entry.locationName != null &&
                    entry.locationName!.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.green),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          entry.locationName!,
                          style: const TextStyle(color: Colors.green),
                          overflow: TextOverflow
                              .ellipsis, // Ensure it doesn't overflow
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),

                // Display the timestamp
                Text(
                  'Date: ${entry.timestamp.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
