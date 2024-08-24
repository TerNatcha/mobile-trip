import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('https://www.yasupada.com/mobiletrip/api.php?action=login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          responseData['message'] == 'Login successful.') {
        // Save user information
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', responseData['user_id']);
        await prefs.setString('username', username);
        // await prefs.setString('token', responseData['token']); // Assuming the response contains a token

// Show success SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message']),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to the next page or save token and navigate
        Navigator.pushReplacementNamed(context, '/tabBasePage');
      } else {
        setState(() {
          _errorMessage = responseData['message'];
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or App Name
              const Padding(
                padding: EdgeInsets.only(bottom: 40.0),
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundImage:
                      AssetImage('assets/images/logo.png'), // Your logo here
                ),
              ),

              // Username Field
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),

              // Password Field
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // Error Message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // Login Button
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
              const SizedBox(height: 20),

              // Register Button
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text('Don’t have an account? Register here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
