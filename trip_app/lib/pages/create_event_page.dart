import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateEventPage extends StatefulWidget {
  final int tripId; // The trip ID to which the event belongs
  final int? eventId; // If null, it means creating a new event. If not, editing an existing event.
  final bool isOwner;

  CreateEventPage({required this.tripId, this.eventId, required this.isOwner});

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _eventDateController = TextEditingController();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) {
      isEditing = true;
      _loadEventData();
    }
  }

  Future<void> _loadEventData() async {
    final response = await http.post(
      Uri.parse('https://www.yasupada.com/mobiletrip/api.php?action=get_event'),
      body: {'event_id': widget.eventId.toString()},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _eventNameController.text = data['event_name'];
        _descriptionController.text = data['description'];
        _eventDateController.text = data['event_date'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load event data')),
      );
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      final action = isEditing ? 'update_event' : 'create_event';
      final response = await http.post(
        Uri.parse('https://www.yasupada.com/mobiletrip/api.php?action=$action'),
        body: {
          'trip_id': widget.tripId.toString(),
          'event_id': widget.eventId.toString(),
          'event_name': _eventNameController.text,
          'description': _descriptionController.text,
          'event_date': _eventDateController.text,
        },
      );

      final responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['message'])),
        );
        Navigator.pop(context); // Go back to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save event: ${responseBody['message']}')),
        );
      }
    }
  }

  Future<void> _deleteEvent() async {
    final response = await http.post(
      Uri.parse('https://www.yasupada.com/mobiletrip/api.php?action=delete_event'),
      body: {'event_id': widget.eventId.toString()},
    );

    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'])),
      );
      Navigator.pop(context); // Go back to the previous screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete event: ${responseBody['message']}')),
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
        title: Text(isEditing ? 'Edit Event' : 'Create Event'),
        actions: widget.isOwner
            ? [
                if (isEditing) 
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: _deleteEvent,
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
                controller: _eventNameController,
                decoration: InputDecoration(labelText: 'Event Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _eventDateController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Event Date'),
                onTap: () => _selectDate(_eventDateController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an event date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEvent,
                child: Text(isEditing ? 'Update Event' : 'Save Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
