import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroupListPage extends StatefulWidget {
  final bool isOwner;
  final bool isJoined;

  GroupListPage({this.isOwner = false, this.isJoined = false});

  @override
  _GroupListPageState createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  List<dynamic> _groupList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGroupList();
  }

  // Function to fetch group list from the API
  Future<void> _fetchGroupList() async {
    try {
      // Replace with your actual API URL
      String apiUrl = 'https://yourapiurl.com/api/groups';
      
      // Pass isOwner and isJoined as query parameters
      final response = await http.get(Uri.parse('$apiUrl?isOwner=${widget.isOwner}&isJoined=${widget.isJoined}'));

      if (response.statusCode == 200) {
        // Parse the response body as JSON
        setState(() {
          _groupList = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        // Handle the error response
        setState(() {
          _isLoading = false;
        });
        print('Error fetching group list: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors or other exceptions
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isOwner ? 'My Groups' : 'Joined Groups'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _groupList.isEmpty
              ? Center(child: Text('No groups found'))
              : ListView.builder(
                  itemCount: _groupList.length,
                  itemBuilder: (context, index) {
                    final group = _groupList[index];
                    return ListTile(
                      title: Text(group['name']), // Assuming 'name' is a field in the group data
                      subtitle: Text(group['description'] ?? 'No description'), // Assuming 'description' is a field
                      trailing: ElevatedButton(
                        onPressed: () {
                          // Navigate to the chat room page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatRoomPage(groupId: group['id']),
                            ),
                          );
                        },
                        child: Text('Go to Chat'),
                      ),
                    );
                  },
                ),
    );
  }
}
 
