import 'package:flutter/material.dart';

class InvitationPopup extends StatelessWidget {
  final int groupId;
  final int userId;

  InvitationPopup({required this.groupId, required this.userId});

  Future<void> _handleResponse(BuildContext context, bool accepted) async {
    final response = await http.post(
      Uri.parse(
          'https://www.yasupada.com/mobiletrip/api.php?action=respond_invite'),
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
      title: Text('Group Invitation'),
      content:
          Text('You have been invited to join a group. Do you want to accept?'),
      actions: [
        TextButton(
          child: Text('No'),
          onPressed: () => _handleResponse(context, false),
        ),
        TextButton(
          child: Text('Yes'),
          onPressed: () => _handleResponse(context, true),
        ),
      ],
    );
  }
}
