// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import '../models/journal_entry.dart';

// class ViewEntryScreen extends StatelessWidget {
//   final JournalEntry entry;

//   ViewEntryScreen({required this.entry});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(entry.title)),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (entry.imageUrl.isNotEmpty)
//               Image.network(entry.imageUrl, fit: BoxFit.cover),
//             Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     entry.timestamp
//                         .toLocal()
//                         .toString()
//                         .split(' ')[0], // Display date
//                     style: TextStyle(fontSize: 14, color: Colors.grey),
//                   ),
//                   SizedBox(height: 8),
//                   Text(entry.description, style: TextStyle(fontSize: 16)),
//                   SizedBox(height: 16),
//                   Container(
//                     height: 200,
//                     child: GoogleMap(
//                       initialCameraPosition: CameraPosition(
//                         target: entry.location,
//                         zoom: 15,
//                       ),
//                       markers: {
//                         Marker(
//                           markerId: MarkerId('entry_location'),
//                           position: entry.location,
//                         ),
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
