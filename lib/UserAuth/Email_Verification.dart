import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> sendVerificationEmail() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xFFFF5A5F),
          title: const Text('Email Verification',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (user != null && user!.emailVerified)
              const Text('Your email is verified.'),
            if (user != null && !user!.emailVerified)
              const Text('You need to verify your email address.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (user != null && !user!.emailVerified)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5A5F)),
                onPressed: sendVerificationEmail,
                child: const Text('Resend Verification Email',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
