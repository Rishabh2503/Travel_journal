import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart'; // For reverse geocoding
import 'package:latlong2/latlong.dart';
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
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  LatLng? _selectedLocation;
  String? _locationName;

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
    _selectedLocation = LatLng(data['latitude'], data['longitude']);
    _locationName = data['locationName'];
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
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );
    if (result != null) {
      final coordinates = result['coordinates']!.split(',');
      _selectedLocation =
          LatLng(double.parse(coordinates[0]), double.parse(coordinates[1]));

      // Reverse geocoding to get the location name
      _reverseGeocodeLocation(_selectedLocation!);
    }
  }

  // Reverse geocoding to get the location name
  Future<void> _reverseGeocodeLocation(LatLng point) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _locationName =
              "${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
      } else {
        setState(() {
          _locationName = "Unknown location";
        });
      }
    } catch (e) {
      // Handle and log the error
      print("Error reverse geocoding: $e");
      setState(() {
        _locationName = "Error fetching location name";
      });
    }
  }

  Future<void> _saveEntry() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    final user = FirebaseAuth.instance.currentUser;
    String? imageUrl;

    try {
      // Image upload
      if (_image != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('journal_images')
            .child('${user!.uid}/${DateTime.now().millisecondsSinceEpoch}');
        final uploadTask = storageRef.putFile(File(_image!.path));
        final snapshot = await uploadTask;

        if (snapshot.state == TaskState.success) {
          imageUrl = await snapshot.ref.getDownloadURL();
        } else {
          throw Exception('Failed to upload image');
        }
      }

      // Entry data
      final entryData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'imageUrl': imageUrl ?? '',
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'userId': user!.uid,
        'latitude': _selectedLocation?.latitude,
        'longitude': _selectedLocation?.longitude,
        'locationName': _locationName ?? '',
      };

      // Saving to Firestore
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

      // Dismiss loading dialog and show success message
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry saved successfully')),
        );
        Navigator.of(context).pop(); // Return to previous screen
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save entry: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.entryId == null ? 'New Entry' : 'Edit Entry')),
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
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 16),
            if (_locationName != null)
              Text('Location: $_locationName',
                  style: const TextStyle(fontSize: 16, color: Colors.green))
            else
              const Text('No location selected.',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            ElevatedButton(
              onPressed: _selectLocation,
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
              child: const Text('Select Location'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveEntry,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
