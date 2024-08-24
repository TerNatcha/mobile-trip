import 'package:flutter/material.dart';

class TripInfoPage extends StatelessWidget {
  final String? tripId;

  const TripInfoPage({super.key, this.tripId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit trip page
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
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
            const TripDetailItem(
              label: 'Trip Name:',
              value: 'Example Trip Name', // Replace with actual trip name
            ),
            const TripDetailItem(
              label: 'Destination:',
              value: 'Example Destination', // Replace with actual destination
            ),
            const TripDetailItem(
              label: 'Start Date:',
              value: '2024-01-01', // Replace with actual start date
            ),
            const TripDetailItem(
              label: 'End Date:',
              value: '2024-01-05', // Replace with actual end date
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Perform action when button is pressed
                },
                child: const Text('Add Activities or Notes'),
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
