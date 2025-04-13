import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart'; // For LatLng coordinates
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'dart:convert';

class CreateTripPage extends StatefulWidget {
  final String?
      tripId; // If null, creating a new trip. If not, editing an existing trip.
  final bool isOwner;

  const CreateTripPage({super.key, this.tripId, required this.isOwner});

  @override
  _CreateTripPageState createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _tripNameController = TextEditingController();
  final _destinationController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  LatLng?
      selectedLocation; // For the selected latitude and longitude from the map
  bool isEditing = false;

  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    if (widget.tripId != null) {
      isEditing = true;
      _loadTripData();
    }
  }

  Future<void> _loadTripData() async {
    final response = await http.post(
      Uri.parse(
          'http://localhost:3000/api/get_trip&trip_id=${widget.tripId}'),
      body: {'trip_id': widget.tripId.toString()},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _tripNameController.text = data['name'];
        _destinationController.text = data['destination'];
        _startDateController.text = data['start_date'];
        _endDateController.text = data['end_date'];

        selectedLocation = LatLng(
            double.parse(data['latitude']), double.parse(data['longitude']));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load trip data')),
      );
    }
  }

  Future<void> _saveTrip() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User ID not found. Please log in again.')),
      );
      return;
    }

    final action = isEditing ? 'edit_trip' : 'create_trip';
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/$action'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'trip_id': widget.tripId?.toString() ?? '',
        'user_id': userId.toString(), // Use user_id from SharedPreferences
        'name': _tripNameController.text,
        'destination': _destinationController.text,
        'start_date': _startDateController.text,
        'end_date': _endDateController.text,
        'latitude': selectedLocation?.latitude.toString() ?? '',
        'longitude': selectedLocation?.longitude.toString() ?? '',
      }),
    );

    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'])),
      );
      Navigator.pop(context); // Go back to the previous screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to save trip: ${responseBody['message']}')),
      );
    }
  }

  void _selectDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  void _onMapTap(BuildContext context, LatLng latlng) {
    setState(() {
      markers.clear();
      selectedLocation = latlng; // Update the selected location
      // Add a new marker at the tapped location
      markers.add(
        Marker(
          point: latlng,
          width: 80.0,
          height: 80.0,
          child: const Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 40.0,
          ),
        ),
      );
    });

    // Show a snackbar with the tapped location
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "Tapped location: Latitude: ${latlng.latitude}, Longitude: ${latlng.longitude}"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Trip' : 'Create Trip'),
        actions: widget.isOwner
            ? [
                if (isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _deleteTrip,
                  ),
                if (isEditing)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _closeTrip,
                  ),
              ]
            : [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tripNameController,
                decoration: const InputDecoration(labelText: 'Trip Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a trip name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(labelText: 'Detail Trip'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a detail trip';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _startDateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Start Date'),
                onTap: () => _selectDate(_startDateController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a start date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _endDateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'End Date'),
                onTap: () => _selectDate(_endDateController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an end date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (selectedLocation != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selected Location:'),
                    Text(
                        'Latitude: ${selectedLocation!.latitude}, Longitude: ${selectedLocation!.longitude}'),
                  ],
                ),
              const SizedBox(height: 20),
              SizedBox(
                height: 300,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: const LatLng(
                        13.7563, 100.5018), // Default map center (Bangkok)
                    initialZoom: 13.0,
                    onTap: (tapPosition, latlng) => _onMapTap(context,
                        latlng), // Pass context and latlng to the tap handler
                  ),
                  children: [
                    TileLayer(
                      // Display map tiles from any source
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
                      userAgentPackageName: 'com.example.app',
                      maxNativeZoom:
                          19, // Scale tiles when the server doesn't support higher zoom levels
                      // And many more recommended properties!
                    ),
                    MarkerLayer(
                      markers: markers, // Display all markers in the list
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTrip,
                child: Text(isEditing ? 'Update Trip' : 'Save Trip'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteTrip() async {
    final response = await http.post(
      Uri.parse(
          'http://localhost:3000/api/delete_trip'),
      body: {'trip_id': widget.tripId.toString()},
    );

    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'])),
      );
      Navigator.pop(context); // Go back to the previous screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete trip')),
      );
    }
  }

  Future<void> _closeTrip() async {
    final response = await http.post(
      Uri.parse(
          'http://localhost:3000/api/close_trip'),
      body: {'trip_id': widget.tripId.toString()},
    );

    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'])),
      );
      Navigator.pop(context); // Go back to the previous screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to close trip')),
      );
    }
  }

  MarkerLayerOptions({required List<Marker> markers}) {}
}
