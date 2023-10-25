import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hostel_add/UserAuth/Login_Screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  String _fullName = '';
  String _phoneNumber = '';
  String _dateOfBirth = '';
  String _errorMessage = '';
  File? _profileImage;
  DateTime _selectedDate = DateTime.now();
  TextEditingController _dobController = TextEditingController();
  RegExp pakistanPhoneRegExp = RegExp(r'^03[0-9]{2}[0-9]{7}$');

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _signUpWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      try {
        final UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        // Upload the profile image to FirebaseStorage
        if (_profileImage != null) {
          final imageReference = FirebaseStorage.instance
              .ref()
              .child('profile_images/${userCredential.user?.uid}.jpg');
          await imageReference.putFile(_profileImage!);
          final imageUrl = await imageReference.getDownloadURL();

          // Store other user information in Firestore
          await _firestore
              .collection('users')
              .doc(userCredential.user?.uid)
              .set({
            'full_name': _fullName,
            'phone_number': _phoneNumber,
            'date_of_birth': _dateOfBirth,
            'profile_image_url': imageUrl,
          });
        } else {
          await _firestore
              .collection('users')
              .doc(userCredential.user?.uid)
              .set({
            'full_name': _fullName,
            'phone_number': _phoneNumber,
            'date_of_birth': _dateOfBirth,
            'profile_image_url': "",
          });
        }
        // After Successful signup, you can navigate to the login screen
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));

        print('Signed up as ${userCredential.user?.email}');
        print('Full Name: $_fullName');
        print('Phone Number: $_phoneNumber');
        print('Date of Birth: $_dateOfBirth');
      } catch (e) {
        // Handle errors (e.g., weak password, email already exists, etc.)
        setState(() {
          _errorMessage = e.toString();
          Fluttertoast.showToast(
              msg: _errorMessage,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              textColor: Colors.white,
              fontSize: 10.0);
        });
        print('Error: $_errorMessage');
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialEntryMode: DatePickerEntryMode.calendar,
        initialDate: _selectedDate,
        firstDate: DateTime(1947),
        lastDate: _selectedDate);
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xFFFF5A5F),
          title: Text('Sign Up',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          iconTheme: IconThemeData(color: Colors.white)),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              GestureDetector(
                onTap: _getImage,
                child: CircleAvatar(
                  radius: 70,
                  child: _profileImage == null
                      ? Icon(Icons.camera_alt, size: 50, color: Colors.white)
                      : CircleAvatar(
                          radius: 75,
                          backgroundImage: Image.file(_profileImage!,
                                  width: 200, height: 200, fit: BoxFit.fill)
                              .image),
                ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Full Name'),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
                onSaved: (value) => _fullName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    return 'Password must contain at least 1 capital letter';
                  }
                  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                    return 'Password must contain at least 1 special character';
                  }
                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Password must contain at least 1 numeric character';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value){
                  if (value!.isEmpty) {
                    return 'Please enter your Phone Number';
                  }
                  else if (!pakistanPhoneRegExp.hasMatch(value)) {
                    return 'Please enter Valid Phone Number';
                  }
                  else{
                    return null;
                  }
              },
                onSaved: (value) => _phoneNumber = value!,
              ),
              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(labelText: 'Date of Birth'),
                keyboardType: TextInputType.none,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your date of birth';
                  }
                  return null;
                },
                onTap: () => _selectDate(context),
                onSaved: (value) => _dateOfBirth = value!,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF5A5F)),
                onPressed: _signUpWithEmailAndPassword,
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              LoginScreen())); // Navigate back to the login screen
                },
                child: Text(
                  'Already have an account? Login',
                  style: TextStyle(color: Color(0xFFFF5A5F)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
