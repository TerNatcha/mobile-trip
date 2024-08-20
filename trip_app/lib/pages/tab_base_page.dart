import 'package:flutter/material.dart';
import 'trip_info_page.dart';
import 'trip_list_page.dart';
import 'calendar_page.dart';
import 'my_person_page.dart';

class TabBasePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Trip Management'),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 4.0,
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontSize: 14),
            tabs: [
              Tab(
                icon: Icon(Icons.list_alt),
                text: 'Trips',
              ),
              Tab(
                icon: Icon(Icons.calendar_today),
                text: 'Calendar',
              ),
              Tab(
                icon: Icon(Icons.person),
                text: 'My Info',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TripListPage(),
            CalendarPage(),
            MyPersonPage(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Handle action when FAB is pressed, e.g., create a new trip
          },
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
