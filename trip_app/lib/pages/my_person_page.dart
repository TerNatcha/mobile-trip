import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPersonPage extends StatefulWidget {
  const MyPersonPage({super.key});

  @override
  _MyPersonPageState createState() => _MyPersonPageState();
}

class _MyPersonPageState extends State<MyPersonPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  File? _imageFile;
  final picker = ImagePicker();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // Load the user_id from SharedPreferences
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId =
          prefs.getString('user_id') ?? '0'; // Update default value if needed

      _usernameController.text = prefs.getString('username') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _firstNameController.text = prefs.getString('first_name') ?? '';
      _lastNameController.text = prefs.getString('last_name') ?? '';
      _phoneController.text = prefs.getString('phone') ?? '';
      _addressController.text = prefs.getString('address') ?? '';
    });
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse(
            'https://www.yasupada.com/mobiletrip/api.php?action=update_user'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'user_id': _userId,
          'username': _usernameController.text,
          'email': _emailController.text,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile.')),
        );
      }
    }
  }

  Future<void> _updateProfileImage() async {
    if (_imageFile != null) {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://www.yasupada.com/mobiletrip/api.php?action=update_profile_image'),
      );
      request.fields['user_id'] = _userId ?? '';
      request.files
          .add(await http.MultipartFile.fromPath('image', _imageFile!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile image.')),
        );
      }
    }
  }

  Future<void> _updateDetailedProfile() async {
    final response = await http.post(
      Uri.parse(
          'https://www.yasupada.com/mobiletrip/api.php?action=update_profile_info'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'user_id': _userId,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
      }),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile.')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // Logout and clear user data
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to login page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Personal Information'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? const Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _updateProfileImage,
                child: const Text('Update Profile Image'),
              ),
              // TextFormField(
              //   controller: _usernameController,
              //   decoration: const InputDecoration(labelText: 'Username'),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter your username';
              //     }
              //     return null;
              //   },
              // ),
              // TextFormField(
              //   controller: _emailController,
              //   decoration: const InputDecoration(labelText: 'Email'),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter your email';
              //     }
              //     return null;
              //   },
              // ),
              // const SizedBox(height: 16.0),
              // ElevatedButton(
              //   onPressed: _updateProfile,
              //   child: const Text('Update Profile'),
              // ),
              // const Divider(),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _updateDetailedProfile,
                child: const Text('Update Detailed Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
