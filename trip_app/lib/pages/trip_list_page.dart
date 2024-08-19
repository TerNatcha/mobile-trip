import 'package:flutter/material.dart';
import 'trip_info_page.dart';

class TripListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('List of Trips will be shown here.'),
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
