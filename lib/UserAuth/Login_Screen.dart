import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hostel_add/UserAuth/Forget_Password.dart';
import 'package:hostel_add/UserAuth/SignUp_Screen.dart';
import 'package:hostel_add/Home_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoggedIn = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Check the user's login state when the app starts
    _checkLoginState();
  }

  void _checkLoginState() async {
    // Retrieve the user's login state from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
    if(isLoggedIn){
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => const HScreen()),
              (Route<dynamic> r)=> false);
    }

  }

  void _signInWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      try {
        final UserCredential userCredential = await _auth
            .signInWithEmailAndPassword(email: _email, password: _password);

        _isLoggedIn = true;
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', _isLoggedIn);

        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => const HScreen()),
                (Route<dynamic> r)=> false);

        print('Logged in as ${userCredential.user?.email}');

      } catch (e) {
        print('Invalid User Name/Password');
        setState(() {
          _errorMessage = e.toString();
          _isLoggedIn = false;
          Fluttertoast.showToast(msg: _errorMessage,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              textColor: Colors.white,
              fontSize: 10.0);
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', _isLoggedIn);
        print('Error: $_errorMessage');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF5A5F),
          title: const Center(
              child: Text(
            'HOSTEL',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/HostelLogo.jpg', height: 65, width: double.infinity, fit: BoxFit.cover),
                  const SizedBox(height: 40),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter Email';
                      }
                      return null;
                    },
                    onSaved: (value) => _email = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Enter Password!!';
                      }
                      return null;
                    },
                    onSaved: (value) => _password = value!,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 35,
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                            color: Color(0xFFFF5A5F),
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ResetPasswordScreen())), // Navigate to Reset Password Screen
                    ),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5A5F)),
                      onPressed: _signInWithEmailAndPassword,
                      //Sign in with firebase auth
                      child: const Text('Login',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18))),
                  TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpScreen())),
                    // Navigate to signup screen
                    child: const Text(
                      'Dont Have an account? SignUp',
                      style: TextStyle(
                          color: Color(0xFFFF5A5F)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
