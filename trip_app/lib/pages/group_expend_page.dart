import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GroupExpendPage extends StatefulWidget {
  final String tripId;

  const GroupExpendPage({
    Key? key,
    required this.tripId,
  }) : super(key: key);

  @override
  _GroupExpendPageState createState() => _GroupExpendPageState();
}

class _GroupExpendPageState extends State<GroupExpendPage> {
  List<dynamic> joinedUsers = [];
  List<Map<String, dynamic>> expenditures = [];

  @override
  void initState() {
    super.initState();
    fetchJoinedUsers();
  }

  Future<void> fetchJoinedUsers() async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost:3000/api/joined_trip_users'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'trip_id': widget.tripId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          joinedUsers = data;
        });
      } else {
        print('Failed to fetch joined users: ${response.body}');
      }
    } catch (e) {
      print('Error fetching joined users: $e');
    }
  }

  Future<void> addExpenditureForUser(
      String userId, String description, double amount) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost:3000/api/update_expense'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'user_id': userId,
          'trip_id': widget.tripId,
          'description': description,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        print('Expenditure added successfully!');
      } else {
        print('Failed to add expenditure: ${response.body}');
      }
    } catch (e) {
      print('Error adding expenditure: $e');
    }
  }

  void addExpenditure() async {
    if (joinedUsers.isEmpty) {
      print('No users joined the trip');
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddExpenditureDialog(
        joinedUsers: joinedUsers,
      ),
    );

    if (result != null) {
      setState(() {
        final userId = result['userId'] as String;
        final description = result['description'] as String;
        final amount = result['amount'] as double;

        // Add to expenditures list
        expenditures.add({
          'userId': userId,
          'description': description,
          'amount': amount,
        });

        // Update expenditure in the backend
        addExpenditureForUser(userId, description, amount);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Expenditures'),
      ),
      body: joinedUsers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: joinedUsers.length,
              itemBuilder: (context, index) {
                final user = joinedUsers[index];
                return ListTile(
                  title: Text(user['username'] ?? 'Unknown'),
                  subtitle: Text(
                      'Total Expenditure: \$${user['total_expenditure'] ?? 0}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addExpenditure,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddExpenditureDialog extends StatefulWidget {
  final List<dynamic> joinedUsers;

  const AddExpenditureDialog({Key? key, required this.joinedUsers})
      : super(key: key);

  @override
  _AddExpenditureDialogState createState() => _AddExpenditureDialogState();
}

class _AddExpenditureDialogState extends State<AddExpenditureDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, bool> _selectedUsers = {};
  String _description = '';
  double _amount = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize selectedUsers map with default values (false for all)
    for (var user in widget.joinedUsers) {
      _selectedUsers[user['id']] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Expenditure'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User selection with checkboxes
            const Text('Select Users:'),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: widget.joinedUsers.map((user) {
                  return CheckboxListTile(
                    title: Text(user['username'] ?? 'Unknown'),
                    value: _selectedUsers[user['id']],
                    onChanged: (isSelected) {
                      setState(() {
                        _selectedUsers[user['id']] = isSelected ?? false;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            // Description input
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              onSaved: (value) => _description = value ?? '',
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter description' : null,
            ),
            const SizedBox(height: 10),
            // Amount input
            TextFormField(
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              onSaved: (value) =>
                  _amount = double.tryParse(value ?? '0') ?? 0.0,
              validator: (value) =>
                  value == null || double.tryParse(value) == null
                      ? 'Enter valid amount'
                      : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              // Filter selected user IDs
              final selectedUserIds = _selectedUsers.entries
                  .where((entry) => entry.value)
                  .map((entry) => entry.key)
                  .toList();

              if (selectedUserIds.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please select at least one user.')),
                );
                return;
              }

              Navigator.pop(context, {
                'userIds': selectedUserIds,
                'description': _description,
                'amount': _amount,
              });
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
