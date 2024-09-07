import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  TextEditingController messageController = TextEditingController();
  String? tripId;
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchUserId(); // Fetch user_id from shared preferences
    fetchMessages();
  }

  Future<void> fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id'); // Adjust key as needed
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
                    'user': msg['user'] as String,
                    'message': msg['message'] as String,
                  })
              .toList();
        });
      } else {
        // Handle error
        print('Failed to load messages');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> sendMessage() async {
    String message = messageController.text.trim();
    if (message.isNotEmpty) {
      // Format the message
      String formattedMessage =
          tripId != null ? '1:${tripId!}\n$message' : '0:$message';

      // Send the message
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
            'user_id': userId, // Use user ID from shared preferences
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            messages.add({
              'user': 'Me', // You can replace this with actual user info
              'message': message,
            });
            messageController.clear();
          });
        } else {
          // Handle error
          print('Failed to send message');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void _showTripIdDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController tripIdController = TextEditingController();

        return AlertDialog(
          title: const Text('Enter Trip ID'),
          content: TextField(
            controller: tripIdController,
            decoration: const InputDecoration(hintText: 'Trip ID'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  tripId = tripIdController.text.trim();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
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
            onPressed: _showTripIdDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];
                bool isMe =
                    message['user'] == 'Me'; // Differentiate user messages

                return Align(
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
                    child: Text(
                      '${message['user']}: ${message['message']}',
                      style:
                          TextStyle(color: isMe ? Colors.white : Colors.black),
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
