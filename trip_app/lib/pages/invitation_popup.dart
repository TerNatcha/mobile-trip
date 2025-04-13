import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';

class InvitationPopup extends StatelessWidget {
  final int groupId;
  final int userId;

  const InvitationPopup(
      {super.key, required this.groupId, required this.userId});

  Future<void> _handleResponse(BuildContext context, bool accepted) async {
    final response = await http.post(
      Uri.parse(
          'http://localhost:3000/api/respond_invite'),
      body: {
        'group_id': groupId.toString(),
        'user_id': userId.toString(),
        'accepted': accepted.toString(),
      },
    );

    final responseBody = json.decode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseBody['message'])),
      );
      Navigator.of(context).pop(); // Close the popup
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Failed to respond to invite: ${responseBody['message']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Group Invitation'),
      content: const Text(
          'You have been invited to join a group. Do you want to accept?'),
      actions: [
        TextButton(
          child: const Text('No'),
          onPressed: () => _handleResponse(context, false),
        ),
        TextButton(
          child: const Text('Yes'),
          onPressed: () => _handleResponse(context, true),
        ),
      ],
    );
  }
}
