import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GroupExpendPage extends StatelessWidget {
  final List<dynamic> joinedUsers;

  const GroupExpendPage({super.key, required this.joinedUsers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Expenditures'),
      ),
      body: ListView.builder(
        itemCount: joinedUsers.length,
        itemBuilder: (context, index) {
          final user = joinedUsers[index];
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
