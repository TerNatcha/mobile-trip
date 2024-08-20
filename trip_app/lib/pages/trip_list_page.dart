import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'trip_info_page.dart';

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
    int userId = 1; // Replace with actual user ID
    final response = await http.get(
      Uri.parse('https://www.yasupada.com/mobiletrip/api.php?action=get_trips&user_id=$userId'),
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
        SnackBar(content: Text('Failed to load trips')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Trips')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : trips.isEmpty
              ? Center(child: Text('No trips available'))
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
                            builder: (context) => TripInfoPage(tripId: trip['trip_id']),
                          ),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripInfoPage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
