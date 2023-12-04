import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hostel_add/UserAuth/Email_Verification.dart';
import 'package:hostel_add/UserAuth/Forget_Password.dart';
import 'package:hostel_add/UserAuth/SignUp_Screen.dart';
import 'package:hostel_add/Screens/Home_Screen.dart';
import 'package:modern_form_line_awesome_icons/modern_form_line_awesome_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hostel_add/resources/values/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = true;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String _email = '';
  String _password = '';
  Icon passwordVisible = const Icon(LineAwesomeIcons.eye_slash);

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
          final userDoc =
              FirebaseFirestore.instance.collection('users').doc(user.uid);
          DocumentSnapshot documentSnapshot =
              await userDoc.get(); // check if user data exists in users bucket
          if (!documentSnapshot.exists) {
            setState(() {
              _isLoading = false;
            });
            print('User data does not exist');
            _deleteUser(user);
            Fluttertoast.showToast(
                msg: "Please Sign Up again or contact support!",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2,
                textColor: Colors.white,
                fontSize: 10.0);
            return; // Stop login process if user data doesn't exist
          }
          // Check if the user's email is verified or not
          if (user.emailVerified) {
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
        print('Invalid Email/Password');
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
          Fluttertoast.showToast(
              msg: 'Invalid Email/Password',
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

  Future<void> _deleteUser(User? currentUser) async {
    try {
      if (currentUser != null) {
        await currentUser.delete();
        print("User deleted successfully!");

        //To Do: delete all ads of this user too?
      } else {
        print("No user is currently signed in.");
      }
    } catch (e) {
      print("Error deleting user: $e");
    }
  }

  void _launchWhatsapp() async {
    String phoneNumber = '+923032777297';
    String message = 'Hi guys, I need your help!';
    String whatsappUrl =
        'https://wa.me/$phoneNumber/?text=${Uri.parse(message)}';
    if (!await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      print("Can't open WhatsApp.");
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
                backgroundColor: AppColors.primaryColor,
                title: const Center(
                    child: Text(
                  'SARAI',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
                automaticallyImplyLeading: false,
              ),
              body: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(15.0, 50.0, 15.0, 15.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 10,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                15.0, 30.0, 15.0, 30.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/SaraiLogo.png',
                                        height: 150, fit: BoxFit.contain)
                                  ],
                                ),
                                const SizedBox(height: 10),
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
                                const SizedBox(height: 10),
                                TextFormField(
                                  decoration: InputDecoration(
                                      label: const Text('Password'),
                                      suffixIcon: IconButton(
                                        icon: passwordVisible,
                                        onPressed: () {
                                          setState(() {
                                            if (_isPasswordVisible == true) {
                                              _isPasswordVisible = false;
                                              passwordVisible = const Icon(
                                                  LineAwesomeIcons.eye);
                                            } else if (_isPasswordVisible ==
                                                false) {
                                              _isPasswordVisible = true;
                                              passwordVisible = const Icon(
                                                  LineAwesomeIcons.eye_slash);
                                            }
                                          });
                                        },
                                      )),
                                  obscureText: _isPasswordVisible,
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
                                          color: AppColors.primaryColor),
                                    ),
                                    onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ResetPasswordScreen())),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.primaryColor),
                                    onPressed: _signInWithEmailAndPassword,
                                    child: const Text('Login',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18))),
                                const SizedBox(height: 5),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SignUpScreen())),
                                  child: const Text(
                                    "Don't have an account? Sign up here",
                                    style: TextStyle(
                                        color: AppColors.primaryColor),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _launchWhatsapp,
                                  child: const Text(
                                    "Having problem Logging In, Contact Support on WhatsApp",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: AppColors.primaryColor),
                                  ),
                                ),
                              ],
                            ),
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
                            radius: 25, color: AppColors.primaryColor),
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
