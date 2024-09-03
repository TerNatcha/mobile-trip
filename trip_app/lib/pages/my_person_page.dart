import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MyPersonPage extends StatefulWidget {
  final String userId; // Pass user_id when navigating

  const MyPersonPage({super.key, required this.userId});

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
  String? _profileImageUrl; // For displaying the profile image
  final picker = ImagePicker();
  bool _loading = true; // For displaying a loading indicator

  @override
  void initState() {
    super.initState();
    _getPersonData(); // Fetch user data when the screen loads
  }

  Future<void> _getPersonData() async {
    // Fetch person data from the server
    final response = await http.get(Uri.parse(
        'https://www.yasupada.com/mobiletrip/api.php?action=get_user&user_id=${widget.userId}'));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      setState(() {
        _usernameController.text = result['username'];
        _emailController.text = result['email'];
        _firstNameController.text = result['first_name'];
        _lastNameController.text = result['last_name'];
        _phoneController.text = result['phone'];
        _addressController.text = result['address'];
        _profileImageUrl = result['profile_image'];
        _loading = false;
      });
    } else {
      // Handle error case
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load user data.')),
      );
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final response = await http.post(
        Uri.parse(
            'https://www.yasupada.com/mobiletrip/api.php?action=update_user'),
        body: {
          'user_id': widget.userId,
          'username': _usernameController.text,
          'email': _emailController.text,
        },
      );

      // Hide loading indicator
      Navigator.of(context).pop();

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
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://www.yasupada.com/mobiletrip/api.php?action=update_profile_image'),
      );
      request.fields['user_id'] = widget.userId;
      request.files
          .add(await http.MultipartFile.fromPath('image', _imageFile!.path));

      final response = await request.send();

      // Hide loading indicator
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully.')),
        );
        // Refresh image after updating
        _getPersonData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile image.')),
        );
      }
    }
  }

  Future<void> _updateDetailedProfile() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final response = await http.post(
      Uri.parse(
          'https://www.yasupada.com/mobiletrip/api.php?action=update_profile_info'),
      body: {
        'user_id': widget.userId,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
      },
    );

    // Hide loading indicator
    Navigator.of(context).pop();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Personal Information'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : _profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!)
                                    as ImageProvider
                                : null,
                        child: _imageFile == null && _profileImageUrl == null
                            ? const Icon(Icons.camera_alt, size: 50)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _updateProfileImage,
                      child: const Text('Update Profile Image'),
                    ),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: const Text('Update Profile'),
                    ),
                    const Divider(),
                    TextFormField(
                      controller: _firstNameController,
                      decoration:
                          const InputDecoration(labelText: 'First Name'),
                    ),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration:
                          const InputDecoration(labelText: 'Phone Number'),
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
