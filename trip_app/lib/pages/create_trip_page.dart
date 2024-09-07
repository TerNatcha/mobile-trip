import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'dart:convert';

class CreateTripPage extends StatefulWidget {
  final int?
      tripId; // If null, it means creating a new trip. If not, editing an existing trip.
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
  bool isEditing = false;

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
      Uri.parse('https://www.yasupada.com/mobiletrip/api.php?action=get_trip'),
      body: {'trip_id': widget.tripId.toString()},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _tripNameController.text = data['name'];
        _destinationController.text = data['destination'];
        _startDateController.text = data['start_date'];
        _endDateController.text = data['end_date'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load trip data')),
      );
    }
  }

  Future<void> _saveTrip() async {
    // if (_formKey.currentState!.validate()) {
    // Retrieve the user ID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    // If userId is null, show an error or handle the case
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User ID not found. Please log in again.')),
      );
      return;
    }

    final action = isEditing ? 'edit_trip' : 'create_trip';
    final response = await http.post(
      Uri.parse('https://www.yasupada.com/mobiletrip/api.php?action=$action'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'trip_id': widget.tripId?.toString() ?? '',
        'user_id': userId.toString(), // Use user_id from SharedPreferences
        'name': _tripNameController.text,
        'destination': _destinationController.text,
        'start_date': _startDateController.text,
        'end_date': _endDateController.text,
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
    // }
  }

  Future<void> _deleteTrip() async {
    final response = await http.post(
      Uri.parse(
          'https://www.yasupada.com/mobiletrip/api.php?action=delete_trip'),
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
        SnackBar(
            content: Text('Failed to delete trip: ${responseBody['message']}')),
      );
    }
  }

  Future<void> _closeTrip() async {
    final response = await http.post(
      Uri.parse(
          'https://www.yasupada.com/mobiletrip/api.php?action=close_trip'),
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
        SnackBar(
            content: Text('Failed to close trip: ${responseBody['message']}')),
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
                decoration: const InputDecoration(labelText: 'Destination'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a destination';
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
}
