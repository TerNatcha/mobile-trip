import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'dart:convert';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _trips = [];
  List<Map<String, dynamic>> _filteredTrips = [];
  String _filter = 'All Trips';
  String? _userId; // Store the user ID

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Load user ID from SharedPreferences
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('user_id'); // Retrieve the user ID
      _fetchTrips(); // Fetch trips after loading user ID
    });
  }

  Future<void> _fetchTrips() async {
    if (_userId == null) return; // Ensure user ID is not null

    final response = await http.get(Uri.parse('https://www.yasupada.com/mobiletrip/api.php?action=get_trips&user_id=$_userId'));

    if (response.statusCode == 200) {
      setState(() {
        _trips = List<Map<String, dynamic>>.from(json.decode(response.body));
        _filteredTrips = _trips;
      });
    } else {
      throw Exception('Failed to load trips');
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _showTripsForDay(selectedDay);
    });
  }

  void _showTripsForDay(DateTime day) {
    final tripsForDay = _filteredTrips.where((trip) {
      DateTime startDate = DateTime.parse(trip['start_date']);
      DateTime endDate = DateTime.parse(trip['end_date']);
      return day.isAfter(startDate.subtract(Duration(days: 1))) && day.isBefore(endDate.add(Duration(days: 1)));
    }).toList();

    if (tripsForDay.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Trips on ${day.toLocal()}'.split(' ')[0]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: tripsForDay.map((trip) {
              return ListTile(
                title: Text(trip['name']),
                subtitle: Text('${trip['destination']}'),
                onTap: () {
                  Navigator.pop(context);
                  _showTripInfo(trip);
                },
              );
            }).toList(),
          ),
        ),
      );
    }
  }

  void _showTripInfo(Map<String, dynamic> trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(trip['name']),
        content: Text('Destination: ${trip['destination']}\nStart Date: ${trip['start_date']}\nEnd Date: ${trip['end_date']}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _filterTrips(String filter) {
    setState(() {
      _filter = filter;
      if (filter == 'All Trips') {
        _filteredTrips = _trips;
      } else if (filter == 'My Own Trips') {
        _filteredTrips = _trips.where((trip) => trip['user_id'] == _userId).toList();
      } else if (filter == 'My Join Trips') {
        _filteredTrips = _trips.where((trip) => trip['joined_users'].contains(_userId)).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Calendar'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _filterTrips,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'All Trips', child: Text('All Trips')),
              PopupMenuItem(value: 'My Own Trips', child: Text('My Own Trips')),
              PopupMenuItem(value: 'My Join Trips', child: Text('My Join Trips')),
            ],
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) {
              return _filteredTrips.where((trip) {
                DateTime startDate = DateTime.parse(trip['start_date']);
                DateTime endDate = DateTime.parse(trip['end_date']);
                return day.isAfter(startDate.subtract(Duration(days: 1))) && day.isBefore(endDate.add(Duration(days: 1)));
              }).toList();
            },
          ),
        ],
      ),
    );
  }
}
