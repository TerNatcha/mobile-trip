import 'package:flutter/material.dart';

class CreateTripPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  void _saveTrip() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Call API to save trip
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Trip')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Trip Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a trip name';
                }
                return null;
              },
              onSaved: (value) {
                // Save trip name
              },
            ),
            ElevatedButton(
              onPressed: _saveTrip,
              child: Text('Save Trip'),
            ),
          ],
        ),
      ),
    );
  }
}
