import 'package:flutter/material.dart';

// Example of Group Info Page
class GroupInfoPage extends StatelessWidget {
  final String groupName;
  final String groupDescription;
  final List<String> users;
  final VoidCallback onEnterChat;

  const GroupInfoPage({
    super.key,
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
            const Text(
              'Group Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(groupDescription),
            const SizedBox(height: 16),
            const Text(
              'Users Joined',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(users[index]),
                    leading: const Icon(Icons.person),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: onEnterChat,
                child: const Text('Go to Chat Room'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
