import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hostel_add/UserAuth/Login_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Home_Screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
        child:
            CupertinoActivityIndicator(radius: 25, color: Color(0xFFFF5A5F)));
  }

  Future<void> _checkLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool login = prefs.getBool('isLoggedIn') ?? false;
    if (login) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HScreen()),
          (Route<dynamic> r) => false);
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> r) => false);
    }
  }
}
