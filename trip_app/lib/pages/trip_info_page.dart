import 'package:flutter/material.dart';

class TripInfoPage extends StatelessWidget {
  final String? tripId;

  TripInfoPage({this.tripId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit trip page
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Confirm and delete trip
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TripDetailItem(
              label: 'Trip Name:',
              value: 'Example Trip Name', // Replace with actual trip name
            ),
            TripDetailItem(
              label: 'Destination:',
              value: 'Example Destination', // Replace with actual destination
            ),
            TripDetailItem(
              label: 'Start Date:',
              value: '2024-01-01', // Replace with actual start date
            ),
            TripDetailItem(
              label: 'End Date:',
              value: '2024-01-05', // Replace with actual end date
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Perform action when button is pressed
                },
                child: Text('Add Activities or Notes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TripDetailItem extends StatelessWidget {
  final String label;
  final String value;

  TripDetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
