import 'package:flutter/material.dart';
import 'trip_info_page.dart';
import 'calendar_page.dart';
import 'my_person_info_page.dart';

class TabBasePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Trip Management'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Trip Info'),
              Tab(text: 'Calendar'),
              Tab(text: 'My Info'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TripInfoPage(),
            CalendarPage(),
            MyPersonInfoPage(),
          ],
        ),
      ),
    );
  }
}
