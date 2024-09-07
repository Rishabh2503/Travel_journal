import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart'; // Add this for reverse geocoding

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _selectedLocation;
  String? _locationName;
  TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(0, 0),
              initialZoom: 2,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                });
                _reverseGeocodeLocation(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Search input floating at the top of the screen
          Positioned(
            top: 20,
            left: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for a location',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchLocation,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedLocation != null) {
            Navigator.of(context).pop({
              'coordinates':
                  '${_selectedLocation!.latitude},${_selectedLocation!.longitude}',
              'name': _locationName ?? 'Unknown', // Pass the location name
            });
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }

  // Reverse geocoding to get location name
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
      setState(() {
        _locationName = "Error fetching location name";
      });
    }
  }

  // Search location by name
  Future<void> _searchLocation() async {
    String query = _searchController.text;
    if (query.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(query);

        if (locations.isNotEmpty) {
          Location location = locations.first;

          // Update the map to the searched location
          LatLng latLng = LatLng(location.latitude, location.longitude);
          _mapController.move(latLng, 12); // Zoom level is 12
          setState(() {
            _selectedLocation = latLng;
          });

          _reverseGeocodeLocation(latLng); // Get the location name
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No results found')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching location: $e')),
        );
      }
    }
  }
}
