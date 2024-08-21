import 'package:flutter/material.dart';

// Example of Group Info Page
class GroupInfoPage extends StatelessWidget {
  final String groupName;
  final String groupDescription;
  final List<String> users;
  final VoidCallback onEnterChat;

  GroupInfoPage({
    required this.groupName,
    required this.groupDescription,
    required this.users,
    required this.onEnterChat,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Group Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(groupDescription),
            SizedBox(height: 16),
            Text(
              'Users Joined',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(users[index]),
                    leading: Icon(Icons.person),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: onEnterChat,
                child: Text('Go to Chat Room'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
