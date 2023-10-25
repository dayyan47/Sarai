import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hostel_add/UserAuth/Login_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Home_Screen.dart';

class NewSplashScreen extends StatefulWidget {
  @override
  _NewSplashScreenState createState() => _NewSplashScreenState();
}

class _NewSplashScreenState extends State<NewSplashScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, child: const Center(child: CircularProgressIndicator()));
  }

}