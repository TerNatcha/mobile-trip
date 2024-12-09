import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:trip_app/pages/trip_info_page.dart';
import 'package:trip_app/pages/search_user_page.dart';

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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        userId = prefs.getString('user_id'); // Adjust key as needed
        username = prefs.getString('username');
      });

      final response = await http.get(
        Uri.parse(
            'https://www.yasupada.com/mobiletrip/api.php?action=get_trips&user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          trips = data
              .map((trip) => {
                    'trip_id': trip['id'].toString(),
                    'trip_name': trip['name'].toString(),
                    'trip_destination': trip['destination'].toString(),
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
          tripId != null ? '1:${tripId!}:$message' : '0:$message';
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
                  subtitle: Text(trip['trip_destination'] ?? ''),
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

  void _showTripDetailsDialog(String tripId) async {
    // Fetch trip details from the server (e.g., title, start_date, end_date)
    final response = await http.post(
      Uri.parse(
          'https://www.yasupada.com/mobiletrip/api.php?action=get_trip&trip_id=$tripId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'trip_id': tripId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Extract trip details
      String tripTitle = data['name'];
      String tripDesc = data['destination'];
      String tripStartDate = data['start_date'];
      String tripEndDate = data['end_date'];

      DateTime? selectedStartDate;
      DateTime? selectedEndDate;

      // Show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Trip: $tripTitle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Detail Trip: $tripDesc'),
                Text('Trip Start Date: $tripStartDate'),
                Text('Trip End Date: $tripEndDate'),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Start Date:'),
                    TextButton(
                      onPressed: () async {
                        selectedStartDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );

                        if (selectedStartDate != null) {
                          (context as Element).markNeedsBuild(); // Update UI
                        }
                      },
                      child: Text(
                        selectedStartDate != null
                            ? selectedStartDate!
                                .toLocal()
                                .toString()
                                .split(' ')[0]
                            : 'Select Date',
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('End Date:'),
                    TextButton(
                      onPressed: () async {
                        selectedEndDate = await showDatePicker(
                          context: context,
                          initialDate: selectedStartDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );

                        if (selectedEndDate != null) {
                          (context as Element).markNeedsBuild(); // Update UI
                        }
                      },
                      child: Text(
                        selectedEndDate != null
                            ? selectedEndDate!
                                .toLocal()
                                .toString()
                                .split(' ')[0]
                            : 'Select Date',
                      ),
                    ),
                  ],
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
                  if (selectedStartDate != null && selectedEndDate != null) {
                    joinTrip(
                      tripId,
                      selectedStartDate!.toIso8601String(),
                      selectedEndDate!.toIso8601String(),
                    );
                    Navigator.of(context).pop(); // Close dialog
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select both dates!')),
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

  void _showTripInfoDialog(BuildContext context, String tripId) {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchJoinedTripUsers(tripId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('Failed to load trip details.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              );
            } else {
              final tripParticipants = snapshot.data ?? [];
              return AlertDialog(
                title: const Text('Friend Free Time:'),
                content: tripParticipants.isEmpty
                    ? const Text('No participants found for this trip.')
                    : SizedBox(
                        width: double.maxFinite,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: tripParticipants.length,
                          itemBuilder: (context, index) {
                            final participant = tripParticipants[index];
                            return ListTile(
                              title: Text('User: ${participant['username']}'),
                              subtitle: Text(
                                'From: ${participant['start_date']} - ${participant['end_date']}',
                              ),
                              trailing: participant['user_id'] == userId
                                  ? IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        _confirmUnjoinTrip(
                                          context,
                                          tripId,
                                          participant['user_id'],
                                        );
                                      },
                                    )
                                  : null,
                            );
                          },
                        ),
                      ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  void _confirmUnjoinTrip(BuildContext context, String tripId, String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Un-Join'),
          content: const Text('Are you sure you want to remove this user?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close confirmation dialog
                _unjoinTrip(context, tripId, userId);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _unjoinTrip(
      BuildContext context, String tripId, String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://yasupada.com/mobiletrip/api.php?action=unjoin_trip&trip_id=$tripId&user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['message'] == "Un-Join Trip successfully.") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('User removed from trip successfully.')),
          );

          // Refresh the dialog content by closing and reopening
          Navigator.pop(context); // Close the current dialog
          _showTripInfoDialog(context, tripId); // Reopen dialog
        } else {
          throw Exception(result['message']);
        }
      } else {
        throw Exception('Failed to unjoin trip.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchJoinedTripUsers(
      String tripId) async {
    final response = await http.post(
      Uri.parse(
          'https://yasupada.com/mobiletrip/api.php?action=joined_trip_users'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'trip_id': tripId}),
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch trip participants');
    }
  }

  void _showSearchDialog() {
    String searchQuery = '';
    List<dynamic> searchResults = [];
    bool isLoading = false;

    Future<void> _searchUsernames(String query) async {
      if (query.isEmpty) {
        searchResults = [];
        return;
      }

      try {
        isLoading = true;
        final response = await http.get(Uri.parse(
            'https://yasupada.com/mobiletrip/api.php?action=search_users&query=$query'));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success') {
            searchResults = data['data'];
          } else {
            searchResults = [];
          }
        } else {
          searchResults = [];
          throw Exception('Failed to fetch users');
        }
      } catch (e) {
        print('Error: $e');
        searchResults = [];
      } finally {
        isLoading = false;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Search User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) async {
                      setState(() {
                        searchQuery = value;
                      });

                      await _searchUsernames(searchQuery);
                      setState(() {}); // Update the UI with new results
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else if (searchResults.isEmpty)
                    const Text('No users found',
                        style: TextStyle(color: Colors.grey))
                  else
                    SizedBox(
                      height: 150, // Limit the height of the list
                      child: ListView.separated(
                        itemCount: searchResults.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: Colors.grey),
                        itemBuilder: (context, index) {
                          final user = searchResults[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(user['username'][0].toUpperCase()),
                            ),
                            title: Text(user['username']),
                            subtitle: Text(user['email']),
                            trailing: Icon(Icons.person_add,
                                color: Theme.of(context).primaryColor),
                            onTap: () {
                              Navigator.pop(context); // Close the dialog
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
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
          IconButton(
            icon: const Icon(Icons.add_to_photos),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchUserPage(
                      key: null,
                      groupName: widget.groupName,
                      groupId: widget.groupId),
                ),
              );
            },
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
                  onTap: () {},
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

                                _showTripDetailsDialog(tripId);
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
                                String tripId =
                                    message['message']!.split(':')[1];
                                _showTripInfoDialog(context, tripId);
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
