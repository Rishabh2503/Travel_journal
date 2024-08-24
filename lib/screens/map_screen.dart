import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TravelJournalMapScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const TravelJournalMapScreen({Key? key, this.initialLocation})
      : super(key: key);

  @override
  _TravelJournalMapScreenState createState() => _TravelJournalMapScreenState();
}

class _TravelJournalMapScreenState extends State<TravelJournalMapScreen> {
  LatLng? _selectedLocation;
  String _locationName = '';
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ?? const LatLng(0, 0);
    _updateMarker();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onTap(LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
      _locationName = ''; // Reset location name when a new point is selected
      _updateMarker();
    });
  }

  void _updateMarker() {
    _markers.clear();
    if (_selectedLocation != null) {
      _markers.add(Marker(
        markerId: MarkerId('selected_location'),
        position: _selectedLocation!,
        infoWindow: InfoWindow(
            title:
                _locationName.isNotEmpty ? _locationName : 'Selected Location'),
      ));
    }
  }

  void _confirmSelection() {
    if (_selectedLocation != null) {
      Navigator.of(context).pop({
        'coordinates':
            '${_selectedLocation!.latitude},${_selectedLocation!.longitude}',
        'name': _locationName,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Travel Location'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _buildMap(),
          _buildLocationCard(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _confirmSelection,
        child: const Icon(Icons.check),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _selectedLocation!,
        zoom: 10,
      ),
      onMapCreated: _onMapCreated,
      onTap: _onTap,
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      zoomGesturesEnabled: true,
    );
  }

  Widget _buildLocationCard() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selected Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                _selectedLocation != null
                    ? '${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}'
                    : 'No location selected',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Location Name',
                  hintText: 'Enter a name for this location',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _locationName = value;
                    _updateMarker();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
