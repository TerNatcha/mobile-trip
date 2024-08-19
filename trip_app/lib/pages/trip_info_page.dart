import 'package:flutter/material.dart';

class TripInfoPage extends StatelessWidget {
  final String? tripId;

  TripInfoPage({this.tripId}); // If tripId is passed, it means we're editing an existing trip

  @override
  Widget build(BuildContext context) {
    bool isEditing = tripId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Trip' : 'Create Trip'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Trip Name',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Destination',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Date',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Handle saving the trip info
                Navigator.pop(context); // Go back to the previous screen
              },
              child: Text(isEditing ? 'Update Trip' : 'Create Trip'),
            ),
          ],
        ),
      ),
    );
  }
}
