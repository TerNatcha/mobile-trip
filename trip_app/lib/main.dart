import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'tab_base_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trip App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // You can define a splash screen here or check for the login state
      routes: {
        '/login': (context) => LoginPage(),
        '/tabBasePage': (context) => TabBasePage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check login status when the splash screen loads
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username'); // Check if a username is saved in SharedPreferences

    if (username != null) {
      // User is already logged in, navigate to TabBasePage
      Navigator.pushReplacementNamed(context, '/tabBasePage');
    } else {
      // User is not logged in, navigate to LoginPage
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Show a loading indicator while checking the login status
      ),
    );
  }
}
