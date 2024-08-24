import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_room_page.dart';

class GroupListPage extends StatefulWidget {
  final bool isOwner;
  final bool isJoined;

  const GroupListPage(
      {super.key, required this.isOwner, required this.isJoined});

  @override
  _GroupListPageState createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  List<dynamic> _groupList = [];

  @override
  void initState() {
    super.initState();
    _fetchGroupList();
  }

  Future<void> _fetchGroupList() async {
    final response = await http.get(Uri.parse(
        'https://www.yasupada.com/mobiletrip/api.php?action=get_groups&isOwner=${widget.isOwner}&isJoined=${widget.isJoined}'));
    if (response.statusCode == 200) {
      setState(() {
        _groupList = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load groups');
    }
  }

  // Function to handle group creation
  void _createGroup() {
    String groupName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Group'),
          content: TextField(
            decoration: const InputDecoration(hintText: "Enter Group Name"),
            onChanged: (value) {
              groupName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Retrieve the user ID from shared preferences
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? userId = prefs.getString('user_id');

                // Make sure userId is not null before making the API call
                if (userId != null) {
                  _createGroupApi(groupName, userId);
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User ID not found.')),
                  );
                }
              },
              child: const Text('Create'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Function to call the create_group API
  Future<void> _createGroupApi(String groupName, String userId) async {
    final response = await http.post(
      Uri.parse(
          'https://www.yasupada.com/mobiletrip/api.php?action=create_group'),
      body: {
        'group_name': groupName,
        'user_id': userId, // Include the user ID in the API request
      },
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);

      if (result['success'] == true) {
        // Group successfully created, refresh the group list
        _fetchGroupList();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Group "$groupName" created successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to create group: ${result['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to create group. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group List'),
      ),
      body: Column(
        children: [
          // Create Group Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _createGroup,
              child: const Text('Create Group'),
            ),
          ),

          // Group List
          Expanded(
            child: ListView.builder(
              itemCount: _groupList.length,
              itemBuilder: (context, index) {
                final group = _groupList[index];
                return ListTile(
                  title: Text(group['name']),
                  subtitle: Text(group['description'] ?? 'No description'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatRoomPage(
                            groupName: group['name'],
                            groupId: group['id'],
                          ),
                        ),
                      );
                    },
                    child: const Text('Go to Chat'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
