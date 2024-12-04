import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:trip_app/pages/create_trip_page.dart';

class TripInfoPage extends StatefulWidget {
  final String tripId;

  const TripInfoPage({super.key, required this.tripId});

  @override
  _TripInfoPageState createState() => _TripInfoPageState();
}

class _TripInfoPageState extends State<TripInfoPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? tripDetails;
  List<dynamic>? joinedUsers;
  late TabController _tabController;

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
            'https://www.yasupada.com/mobiletrip/api.php?action=get_trip&trip_id=${widget.tripId}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'trip_id': widget.tripId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          tripDetails = jsonDecode(response.body);
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
            'https://www.yasupada.com/mobiletrip/api.php?action=joined_trip_users&trip_id=${widget.tripId}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'trip_id': widget.tripId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          joinedUsers = jsonDecode(response.body)['users'];
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
            'https://www.yasupada.com/mobiletrip/api.php?action=delete_trip'),
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
                        label: 'Destination:',
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
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // Action for adding activities or notes
                          },
                          child: const Text('Add Activities or Notes'),
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
