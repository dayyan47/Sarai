import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hostel_add/UserAuth/Email_Verification.dart';
import 'package:hostel_add/UserAuth/Forget_Password.dart';
import 'package:hostel_add/UserAuth/SignUp_Screen.dart';
import 'package:hostel_add/Screens/Home_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String _email = '';
  String _password = '';

  @override
  void initState() {
    super.initState();
    _checkLoginState(); // Check the user's login state when the app starts
  }

  void _checkLoginState() async {
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); // Retrieve the user's login state from shared preferences
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
    if (isLoggedIn) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
  }

  void _signInWithEmailAndPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      try {
        setState(() {
          _isLoading = true;
        });
        final UserCredential userCredential = await _auth
            .signInWithEmailAndPassword(email: _email, password: _password);
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.reload(); // Refresh the user's data

          if (user.emailVerified) {
            // The user's email is verified
            setState(() {
              _isLoggedIn = true;
            });
            prefs.setBool('isLoggedIn', _isLoggedIn);
            print('Email is verified');
            Fluttertoast.showToast(
                msg: "Logged In Successfully!",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2,
                textColor: Colors.white,
                fontSize: 10.0);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomeScreen()));

            print('Logged in as ${userCredential.user?.email}');
          } else {
            // The user's email is not verified
            setState(() {
              _isLoading = false;
              _isLoggedIn = false;
            });
            prefs.setBool('isLoggedIn', _isLoggedIn);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EmailVerificationScreen()));
            print('Email is not verified');
          }
        } else {
          // User is not signed in
          print('User is not signed in');
        }

      } catch (e) {
        print('Invalid User Name/Password');
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
          Fluttertoast.showToast(
              msg: e.toString(),
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              textColor: Colors.white,
              fontSize: 10.0);
        });
        prefs.setBool('isLoggedIn', _isLoggedIn);
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _isLoading ? false : true,
      child: Stack(
        children: [
          Scaffold(
              appBar: AppBar(
                backgroundColor: const Color(0xFFFF5A5F),
                title: const Center(
                    child: Text(
                  'HOSTEL',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
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
                        Image.asset('assets/HostelLogo.jpg',
                            height: 65,
                            width: double.infinity,
                            fit: BoxFit.cover),
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
                          decoration:
                              const InputDecoration(labelText: 'Password'),
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
                                        const ResetPasswordScreen())),
                          ),
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5A5F)),
                            onPressed: _signInWithEmailAndPassword,
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
                          child: const Text(
                            'Dont Have an account? SignUp',
                            style: TextStyle(color: Color(0xFFFF5A5F)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
          if (_isLoading)
            Positioned.fill(
                child: Container(
                    color: Colors.black.withOpacity(0.8),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CupertinoActivityIndicator(
                            radius: 25, color: Color(0xFFFF5A5F)),
                        SizedBox(height: 10),
                        Text("Loading...",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                decoration: TextDecoration.none))
                      ],
                    )))
        ],
      ),
    );
  }
}
