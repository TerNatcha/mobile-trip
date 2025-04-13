import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GroupOfUserPage extends StatefulWidget {
  const GroupOfUserPage({super.key});

  @override
  _GroupOfUserPageState createState() => _GroupOfUserPageState();
}

class _GroupOfUserPageState extends State<GroupOfUserPage> {
  List groups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User ID not found. Please log in again.')),
      );
      return;
    }

    final response = await http.get(
      Uri.parse(
          'http://localhost:3000/api/get_groups&user_id=$userId'),
    );

    if (response.statusCode == 200) {
      setState(() {
        groups = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load groups')),
      );
    }
  }

  Future<void> _createGroup(String groupName) async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    final response = await http.post(
      Uri.parse(
          'http://localhost:3000/api/create_group'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'user_id': userId,
        'name': groupName,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group created successfully')));
      _fetchGroups();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create group')));
    }
  }

  void _showCreateGroupDialog() {
    TextEditingController _groupNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Group'),
          content: TextField(
            controller: _groupNameController,
            decoration: const InputDecoration(hintText: 'Enter group name'),
          ),
          actions: [
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                Navigator.of(context).pop();
                _createGroup(_groupNameController.text);
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
        title: const Text('My Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateGroupDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : groups.isEmpty
              ? const Center(child: Text('No groups available'))
              : ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return ListTile(
                      title: Text(group['name']),
                      onTap: () {},
                    );
                  },
                ),
    );
  }
}
