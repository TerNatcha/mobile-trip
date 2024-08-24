import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  final String groupName;

  const ChatRoomPage({super.key, required this.groupName, required groupId});

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  List<Map<String, String>> messages = [];
  TextEditingController messageController = TextEditingController();

  void sendMessage() {
    String message = messageController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        messages.add({
          'user': 'Me', // You can replace this with actual user info
          'message': message,
        });
        messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
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
                  icon: Icon(Icons.send),
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
