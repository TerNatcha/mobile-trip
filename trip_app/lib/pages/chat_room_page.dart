import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:trip_app/pages/trip_info_page.dart';

class ChatRoomPage extends StatefulWidget {
  final String groupName;
  final String groupId;

  const ChatRoomPage({
    super.key,
    required this.groupName,
    required this.groupId,
  });

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  List<Map<String, String>> messages = [];
  List<Map<String, String>> trips = []; // Store available trips
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  String? tripId;
  String? userId;
  String? username;

  @override
  void initState() {
    super.initState();
    fetchUserId(); // Fetch user_id from shared preferences
    fetchMessages();
    fetchAvailableTrips(); // Fetch trips when the page loads
  }

  Future<void> fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id'); // Adjust key as needed
      username = prefs.getString('username');
    });
  }

  Future<void> fetchMessages() async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://www.yasupada.com/mobiletrip/api.php?action=get_messages',
        ),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'group_id': widget.groupId,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          messages = data
              .map((msg) => {
                    'user': msg['username'] as String,
                    'message': msg['message'] as String,
                  })
              .toList();
        });

        // Scroll to the bottom after sending a message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
          }
        });
      } else {
        // Handle error
        print('Failed to load messages');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchAvailableTrips() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://www.yasupada.com/mobiletrip/api.php?action=get_trips'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          trips = data
              .map((trip) => {
                    'trip_id': trip['id'].toString(),
                    'trip_name': trip['name'].toString(),
                  })
              .toList();
        });
      } else {
        print('Failed to fetch trips');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> sendMessage() async {
    String message = messageController.text.trim();
    if (message.isNotEmpty) {
      String formattedMessage =
          tripId != null ? '1:${tripId!}\n$message' : '0:$message';
      tripId = null;
      try {
        if (userId == null) {
          print('User ID is not available');
          return;
        }

        final response = await http.post(
          Uri.parse(
              'https://www.yasupada.com/mobiletrip/api.php?action=send_message'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            'group_id': widget.groupId,
            'message': formattedMessage,
            'user_id': userId,
          }),
        );

        if (response.statusCode == 200) {
          // setState(() {
          //   messages.add({'user': username!, 'message': message});
          //
          // });
          messageController.clear();
          fetchMessages();
        } else {
          print('Failed to send message');
          // Use SnackBar to show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send message: ${response.reasonPhrase}'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  // Future<void> joinTrip(String tripId) async {
  //   // Call API to join trip
  //   try {
  //     final response = await http.post(
  //       Uri.parse(
  //           'https://www.yasupada.com/mobiletrip/api.php?action=join_trip'),
  //       headers: {'Content-Type': 'application/json; charset=UTF-8'},
  //       body: jsonEncode({
  //         'trip_id': tripId,
  //         'user_id': userId,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       print('Successfully joined the trip');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Joined trip successfully!')),
  //       );
  //     } else {
  //       print('Failed to join trip');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  Future<void> joinTrip(String tripId, String startDate, String endDate) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://www.yasupada.com/mobiletrip/api.php?action=join_trip'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'trip_id': tripId,
          'user_id': userId, // Assuming userId is already fetched
          'start_date': startDate,
          'end_date': endDate,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined the trip!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to join the trip.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred.')),
      );
    }
  }

  void _showTripSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a Trip'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: trips.length,
              itemBuilder: (context, index) {
                var trip = trips[index];
                return ListTile(
                  title: Text(trip['trip_name'] ?? ''),
                  onTap: () {
                    setState(() {
                      tripId = trip['trip_id'];
                    });

                    messageController.text = trip['trip_name'] ?? '';

                    sendMessage();
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showTripDetails(String tripId) {
    // Show trip details with join option
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Trip Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Trip ID: $tripId'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  joinTrip(tripId);
                  Navigator.of(context).pop();
                },
                child: const Text('Join Trip'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTripDetailsDialog(String tripId) async {
    // Fetch trip details from the server (e.g., title, start_date, end_date)
    final response = await http.post(
      Uri.parse(
          'https://www.yasupada.com/mobiletrip/api.php?action=get_trip_details'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'trip_id': tripId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Extract trip details
      String tripTitle = data['title'];
      String tripStartDate = data['start_date'];
      String tripEndDate = data['end_date'];

      // Create date controllers
      TextEditingController startDateController = TextEditingController();
      TextEditingController endDateController = TextEditingController();

      // Show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Trip: $tripTitle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Start Date: $tripStartDate'),
                Text('End Date: $tripEndDate'),
                const SizedBox(height: 10),
                TextField(
                  controller: startDateController,
                  decoration:
                      const InputDecoration(labelText: 'Select Start Date'),
                ),
                TextField(
                  controller: endDateController,
                  decoration:
                      const InputDecoration(labelText: 'Select End Date'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  String selectedStartDate = startDateController.text.trim();
                  String selectedEndDate = endDateController.text.trim();

                  if (selectedStartDate.isNotEmpty &&
                      selectedEndDate.isNotEmpty) {
                    joinTrip(tripId, selectedStartDate, selectedEndDate);
                  } else {
                    // Show a warning if fields are empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select dates!')),
                    );
                  }
                },
                child: const Text('Join Trip'),
              ),
            ],
          );
        },
      );
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch trip details.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        actions: [
          IconButton(
            icon: const Icon(Icons.trip_origin),
            onPressed: _showTripSelectionDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];

                bool isMe = message['user'] == username;

                return GestureDetector(
                  onTap: () {
                    // Handle trip detail showing
                    if (message['message']!.startsWith('1:')) {
                      String tripId = message['message']!.split(':')[1];
                      // _showTripDetails(tripId);
                      _showTripDetailsDialog(tripId);
                    }
                  },
                  child: Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blueAccent : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          // Show message text for normal messages or trip messages
                          Text(
                            isMe
                                ? 'Me: ${message['message']}'
                                : '${message['user']}: ${message['message']}',
                            style: TextStyle(
                                color: isMe ? Colors.white : Colors.black),
                          ),
                          // Add a button if it's a trip message
                          if (message['message']!.startsWith('1:')) ...[
                            const SizedBox(height: 8.0),
                            ElevatedButton(
                              onPressed: () {
                                String tripId =
                                    message['message']!.split(':')[1];
                                joinTrip(tripId);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green, // Set button color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text('Join Trip'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                String tripId2 =
                                    message['message']!.split(':')[1];
                                TripInfoPage(key: null, tripId: tripId2);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green, // Set button color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text('Trip Info'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                  color: Colors.blueAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
