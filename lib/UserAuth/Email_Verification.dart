import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hostel_add/resources/values/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Screens/Home_Screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> _sendVerificationEmail() async {
    await user?.reload();
    if (user != null && !user!.emailVerified) {
      try {
        await user!.sendEmailVerification();
        Fluttertoast.showToast(
            msg: 'Verification email sent. Please check your email.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            textColor: Colors.white,
            fontSize: 10.0);
      } catch (e) {
        Fluttertoast.showToast(
            msg: 'Error sending verification email: $e',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            textColor: Colors.white,
            fontSize: 10.0);
      }
    }
  }

  Future<void> _checkEmailVerified() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User? user = FirebaseAuth.instance.currentUser;
    await user!.reload();
    user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      Fluttertoast.showToast(
          msg: 'Please verify your email.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          textColor: Colors.white,
          fontSize: 10.0);
    } else {
      Fluttertoast.showToast(
          msg: 'Email verified, Logging you in.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          textColor: Colors.white,
          fontSize: 10.0);

      prefs.setBool('isLoggedIn', true);
      print('Email is verified');

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> r) => false);
    }
  }

  Widget _buildPhoneLayout() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (user != null && !user!.emailVerified)
            const Text('You need to verify your email address.',
                style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (user != null && !user!.emailVerified)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              onPressed: _sendVerificationEmail,
              child: const Text(
                'Resend Verification Email',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 25),
          const Text('Have you verified your email?',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            onPressed: _checkEmailVerified,
            child: const Text(
              'Check Status',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletAndWebLayout(double width) {
    return Center(
      child: SizedBox(
        width: width/2,
        height: MediaQuery.sizeOf(context).height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (user != null && !user!.emailVerified)
              const Text('You need to verify your email address.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (user != null && !user!.emailVerified)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                onPressed: _sendVerificationEmail,
                child: const Text(
                  'Resend Verification Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 25),
            const Text('Have you verified your email?',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              onPressed: _checkEmailVerified,
              child: const Text(
                'Check Status',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('Email Verification',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth < 600) {
              // For smaller screens (phones)
              return _buildPhoneLayout();
            } else {
              // For larger screens (tablets, web)
              return _buildTabletAndWebLayout(constraints.maxWidth);
            }
          },
        )
    );
  }
}
