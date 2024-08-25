// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:latlong2/latlong.dart';
import 'map_screen.dart';

class JournalEntryScreen extends StatefulWidget {
  final String? entryId;

  const JournalEntryScreen({super.key, this.entryId});

  @override
  _JournalEntryScreenState createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  XFile? _image;
  String? _location;

  @override
  void initState() {
    super.initState();
    if (widget.entryId != null) {
      _loadEntry();
    }
  }

  Future<void> _loadEntry() async {
    final entry = await FirebaseFirestore.instance
        .collection('journal_entries')
        .doc(widget.entryId)
        .get();
    final data = entry.data()!;
    _titleController.text = data['title'];
    _descriptionController.text = data['description'];
    _image = XFile(data['imageUrl']);
    _location = data['location'];
    setState(() {});
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(
        builder: (context) => const MapScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _location = result['coordinates'];
        // You can also save the location name if needed
        // String? locationName = result['name'];
      });
    }
  }

  Future<void> _saveEntry() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    final user = FirebaseAuth.instance.currentUser;
    String? imageUrl;

    if (_image != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('journal_images')
          .child('${user!.uid}/${DateTime.now().millisecondsSinceEpoch}');

      final uploadTask = storageRef.putFile(File(_image!.path));
      final snapshot = await uploadTask.whenComplete(() => {});

      if (snapshot.state == TaskState.success) {
        imageUrl = await snapshot.ref.getDownloadURL();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image')),
          );
        }
        return;
      }
    }

    final entryData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'imageUrl': imageUrl ?? '', // Ensure the imageUrl is not null
      'timestamp': Timestamp.fromDate(DateTime.now()),
      'userId': user!.uid,
      'location': _location ?? '',
    };

    try {
      if (widget.entryId == null) {
        await FirebaseFirestore.instance
            .collection('journal_entries')
            .add(entryData);
      } else {
        await FirebaseFirestore.instance
            .collection('journal_entries')
            .doc(widget.entryId)
            .update(entryData);
      }

      // Check if the widget is still mounted before calling Navigator.of(context).pop()
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save entry: $e')),
        );
      }
    }
    Navigator.of(context).pop();

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry saved successfully')),
      );
      Navigator.of(context).pop(); // Return to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entryId == null ? 'New Entry' : 'Edit Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            if (_image != null)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(File(_image!.path)),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 8,
                      top: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _image = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue, // Customize the color
              ),
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 16),
            if (_location != null)
              Text(
                'Location: $_location',
                style: const TextStyle(fontSize: 16, color: Colors.green),
              )
            else
              const Text(
                'No location selected.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ElevatedButton(
              onPressed: _selectLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue, // Customize the color
              ),
              child: const Text('Select Location'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Customize the color
              ),
              child: const Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
