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
            'https://www.yasupada.com/mobiletrip/api.php?action=joined_trip_users'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'trip_id': widget.tripId}),
      );

      print(response.body);

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

  void addExpenditure() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddExpenditureDialog(),
    );

    if (result != null) {
      setState(() {
        expenditures.add(result);
      });
    }
  }

  double calculateBudgetPerPerson() {
    if (expenditures.isEmpty || joinedUsers.isEmpty) {
      return 0;
    }

    final totalExpenditure =
        expenditures.fold(0, (sum, item) => sum + (item['amount'] as int));
    return totalExpenditure / joinedUsers.length;
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
                  trailing: IconButton(
                    icon: const Icon(Icons.attach_money),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title:
                                Text('Payment Details for ${user['username']}'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Total Expenditure: \$${user['total_expenditure'] ?? 0}',
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Add Payment'),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
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
  const AddExpenditureDialog({super.key});

  @override
  _AddExpenditureDialogState createState() => _AddExpenditureDialogState();
}

class _AddExpenditureDialogState extends State<AddExpenditureDialog> {
  final _formKey = GlobalKey<FormState>();
  String _description = '';
  double _amount = 0.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Expenditure'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              onSaved: (value) => _description = value ?? '',
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter description' : null,
            ),
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
              Navigator.pop(
                  context, {'description': _description, 'amount': _amount});
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
