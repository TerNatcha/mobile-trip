// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GroupExpendPage extends StatefulWidget {
  const GroupExpendPage({super.key});

  @override
  _GroupExpendPage createState() => _GroupExpendPage();
}

class _GroupExpendPage extends State<GroupExpendPage> {
  List<dynamic>? joinedUsers;
  List<Map<String, dynamic>> expenditures = []; // To store expenditures
  String? tripId;

  void addExpenditure() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddExpenditureDialog(),
    );

    if (result != null) {
      setState(() {
        expenditures.add(result);
      });
    }
  }

  double calculateBudgetPerPerson() {
    if (expenditures.isEmpty || joinedUsers == null || joinedUsers!.isEmpty) {
      return 0;
    }

    final totalExpenditure =
        expenditures.fold(0, (sum, item) => sum + (item['amount'] as int));
    return totalExpenditure / joinedUsers!.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Expenditures'),
      ),
      body: ListView.builder(
        itemCount: joinedUsers!.length,
        itemBuilder: (context, index) {
          final user = joinedUsers![index];
          return ListTile(
            title: Text(user['username'] ?? 'Unknown'),
            trailing: IconButton(
              icon: const Icon(Icons.attach_money),
              onPressed: () {
                // เพิ่มฟังก์ชันแสดงรายละเอียดการจ่ายเงินของผู้ใช้นี้
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // เพิ่มฟังก์ชันเพื่อเพิ่มรายการค่าใช้จ่ายใหม่
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddExpenditureDialog extends StatefulWidget {
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
