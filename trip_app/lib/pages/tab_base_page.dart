import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'calendar_page.dart';
import 'group_list_page.dart';
import 'my_person_page.dart';
import 'trip_list_page.dart';

class TabBasePage extends StatefulWidget {
  const TabBasePage({super.key});

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
      'user_id': prefs.getString('user_id'),
      'username': prefs.getString('username'),
      'token': prefs.getString('token'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trip Management'),
          centerTitle: true,
          bottom: const TabBar(
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
        body: FutureBuilder<Map<String, String?>>(
          future: _userInfoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final userId = snapshot.data!['user_id'];

              return TabBarView(
                children: [
                  TripListPage(),
                  GroupListPage(userId: userId),
                  const CalendarPage(),
                  const MyPersonPage()
                ],
              );
            } else {
              return const Center(child: Text('No user data found.'));
            }
          },
        ),
      ),
    );
  }
}
