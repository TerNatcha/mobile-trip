import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'dart:convert';
import 'trip_info_page.dart';
import 'create_trip_page.dart'; // Import CreateTripPage

class TripListPage extends StatefulWidget {
  @override
  _TripListPageState createState() => _TripListPageState();
}

class _TripListPageState extends State<TripListPage> {
  List trips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTrips();
  }

  Future<void> _fetchTrips() async {
    setState(() {
      isLoading = true; // Show loading indicator while fetching trips
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://www.yasupada.com/mobiletrip/api.php?action=get_trips'),
      );

      if (response.statusCode == 200) {
        setState(() {
          trips = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load trips')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while fetching trips')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateTripPage(
                      isOwner: true), // Adjust based on user permissions
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : trips.isEmpty
              ? const Center(child: Text('No trips available'))
              : ListView.builder(
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    return ListTile(
                      title: Text(trip['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Destination: ${trip['destination']}'),
                          Text('Start Date: ${trip['start_date']}'),
                          Text('End Date: ${trip['end_date']}'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TripInfoPage(tripId: trip['trip_id']),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
