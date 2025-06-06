import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // For LatLng coordinates

import 'package:trip_app/pages/create_trip_page.dart';
import 'package:trip_app/pages/group_expend_page.dart';

class TripInfoPage extends StatefulWidget {
  final String? tripId;

  const TripInfoPage({super.key, required this.tripId});

  @override
  _TripInfoPageState createState() => _TripInfoPageState();
}

class _TripInfoPageState extends State<TripInfoPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? tripDetails;
  List<dynamic>? joinedUsers;
  late TabController _tabController;

  LatLng?
      selectedLocation; // For the selected latitude and longitude from the map
  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchTripDetails();
    fetchJoinedUsers();
  }

  Future<void> fetchTripDetails() async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost:3000/api/get_trip&trip_id=${widget.tripId}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'trip_id': widget.tripId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          tripDetails = jsonDecode(response.body);
          final data = json.decode(response.body);
          selectedLocation = LatLng(
              double.parse(data['latitude']), double.parse(data['longitude']));

          markers.clear();

          // Add a new marker at the tapped location
          markers.add(
            Marker(
              point: selectedLocation!,
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
      } else {
        print('Failed to fetch trip details');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchJoinedUsers() async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost:3000/api/joined_trip_users&trip_id=${widget.tripId}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'trip_id': widget.tripId}),
      );

      if (response.statusCode == 200) {
        print(response.body);
        setState(() {
          joinedUsers = jsonDecode(response.body);
        });
      } else {
        print('Failed to fetch joined users');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteTrip() async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost:3000/api/delete_trip'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'trip_id': widget.tripId}),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        print('Failed to delete trip');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void editTrip() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateTripPage(tripId: widget.tripId, isOwner: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Joined Users'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: editTrip,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Trip'),
                  content:
                      const Text('Are you sure you want to delete this trip?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        deleteTrip();
                        Navigator.pop(context);
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          tripDetails == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TripDetailItem(
                        label: 'Trip Name:',
                        value: tripDetails!['name'] ?? 'N/A',
                      ),
                      TripDetailItem(
                        label: 'Detail Trip:',
                        value: tripDetails!['destination'] ?? 'N/A',
                      ),
                      TripDetailItem(
                        label: 'Start Date:',
                        value: tripDetails!['start_date'] ?? 'N/A',
                      ),
                      TripDetailItem(
                        label: 'End Date:',
                        value: tripDetails!['end_date'] ?? 'N/A',
                      ),
                      if (selectedLocation != null &&
                          selectedLocation!.latitude != 0 &&
                          selectedLocation!.longitude != 0)
                        SizedBox(
                          height: 300,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: selectedLocation!,
                              initialZoom: 14.0,
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
                                markers:
                                    markers, // Display all markers in the list
                              ),
                            ],
                          ),
                        ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: FloatingActionButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupExpendPage(
                                  tripId: widget.tripId!,
                                ),
                              ),
                            );
                          },
                          child: const Icon(Icons.group),
                        ),
                      ),
                    ],
                  ),
                ),
          joinedUsers == null
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: joinedUsers!.length,
                  itemBuilder: (context, index) {
                    final user = joinedUsers![index];
                    return ListTile(
                      title: Text(user['username'] ?? 'Unknown'),
                      subtitle: Text(
                          'Start: ${user['start_date'] ?? 'N/A'}, End: ${user['end_date'] ?? 'N/A'}'),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class TripDetailItem extends StatelessWidget {
  final String label;
  final String value;

  const TripDetailItem({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
