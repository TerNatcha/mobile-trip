import 'package:flutter/material.dart';
import 'trip_info_page.dart';
import 'trip_list_page.dart';
import 'group_list_page.dart';
import 'calendar_page.dart';
import 'my_person_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TabBasePage extends StatefulWidget {
  @override
  _TabBasePageState createState() => _TabBasePageState();
}

class _TabBasePageState extends State<TabBasePage> {
  Future<Map<String, String?>>? _userInfoFuture;

  @override
  void initState() {
    super.initState();
    _userInfoFuture = getUserInfo();
  }

  Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString('username'),
      'token': prefs.getString('token'),
    };
  }
  
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
                icon: Icon(Icons.list_alt),
                text: 'Groups',
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
            GroupsListPage(),
            CalendarPage(),
            MyPersonPage(),
          ],
        ),
        
      ),
    );
  }
}
