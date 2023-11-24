import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hostel_add/resources/values/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:modern_form_line_awesome_icons/modern_form_line_awesome_icons.dart';
import 'package:permission_handler/permission_handler.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isPasswordVisible = true;
  String _email = '';
  String _password = '';
  String _fullName = '';
  String _phoneNumber = '';
  String _dateOfBirth = '';
  File? _profileImage;
  RegExp pakistanPhoneRegExp = RegExp(r'^03[0-9]{2}[0-9]{7}$');
  Icon passwordVisible = const Icon(LineAwesomeIcons.eye_slash);
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _dobController = TextEditingController();

  Future<void> _getImageFromGallery() async {
    await [Permission.storage, Permission.photos].request();
    bool isStoragePermissionGranted = await Permission.storage.isGranted;
    //bool isGalleryPermissionGranted = await Permission.photos.isGranted; // for ios

    if (isStoragePermissionGranted) {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } else {
      Fluttertoast.showToast(
          msg: "Please grant Files and Media permission first!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          textColor: Colors.white,
          fontSize: 10.0);
      openAppSettings();
    }
  }

  Future<void> _getImageFromCamera() async {
    await [Permission.camera].request();
    bool isCameraPermissionGranted = await Permission.camera.isGranted;
    if (isCameraPermissionGranted) {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } else {
      Fluttertoast.showToast(
          msg: "Please grant Camera permission first!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          textColor: Colors.white,
          fontSize: 10.0);
      openAppSettings();
    }
  }

  void showOptions()  {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Photo Gallery'),
            onPressed: () {
              Navigator.of(context).pop();
              _getImageFromGallery(); // get image from gallery
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              Navigator.of(context).pop();
              _getImageFromCamera(); // get image from camera
            },
          ),
        ],
      ),
    );
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

  Future<void> _sendVerificationEmail() async {
    User? user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        Fluttertoast.showToast(
            msg: "Verification email sent!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            textColor: Colors.white,
            fontSize: 10.0);
        print('Verification email sent');
      } catch (e) {
        Fluttertoast.showToast(
            msg: "Error sending verification email",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            textColor: Colors.white,
            fontSize: 10.0);
        print('Error sending verification email: $e');
      }
    }
  }

  Future<void> _signUpWithEmailAndPassword() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      try {
        setState(() {
          _isLoading = true;
        });

        final UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: _email, password: _password);
        if (_profileImage != null) {
          final imageReference = FirebaseStorage.instance
              .ref()
              .child('profile_images/${userCredential.user?.uid}.jpg');
          await imageReference.putFile(_profileImage!);
          final imageUrl = await imageReference.getDownloadURL();

          await _firestore
              .collection('users')
              .doc(userCredential.user?.uid)
              .set({
            'full_name': _fullName,
            'email': _email,
            'phone_number': _phoneNumber,
            'date_of_birth': _dateOfBirth,
            'profile_image_url': imageUrl,
            'fav_ads': [],
          });
        } else {
          await _firestore
              .collection('users')
              .doc(userCredential.user?.uid)
              .set({
            'full_name': _fullName,
            'email': _email,
            'phone_number': _phoneNumber,
            'date_of_birth': _dateOfBirth,
            'profile_image_url': "",
            'fav_ads': [],
          });
        }
        Fluttertoast.showToast(
            msg: "Sign Up Successfully!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            textColor: Colors.white,
            fontSize: 10.0);

        print('Signed up as ${userCredential.user?.email}');
        print('Full Name: $_fullName');
        print('Phone Number: $_phoneNumber');
        print('Date of Birth: $_dateOfBirth');

        _sendVerificationEmail();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(
            msg: e.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            textColor: Colors.white,
            fontSize: 10.0);
        print('Error: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
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
                backgroundColor: AppColors.PRIMARY_COLOR,
                title: const Text('Sign Up',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                iconTheme: const IconThemeData(color: Colors.white)),
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    GestureDetector(
                      onTap: showOptions,
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.transparent,
                        child: _profileImage == null
                            ? const Icon(Icons.add_a_photo,
                                size: 50, color: AppColors.PRIMARY_COLOR)
                            : Image.file(_profileImage!,
                                width: 200, height: 200, fit: BoxFit.contain),
                      ),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Full Name'),
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
                      decoration: const InputDecoration(labelText: 'Email'),
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
                      decoration: InputDecoration(
                          label: const Text('Password'),
                          suffixIcon: IconButton(
                            icon: passwordVisible,
                            onPressed: () {
                              setState(() {
                                if (_isPasswordVisible == true) {
                                  _isPasswordVisible = false;
                                  passwordVisible =
                                      const Icon(LineAwesomeIcons.eye);
                                } else if (_isPasswordVisible == false) {
                                  _isPasswordVisible = true;
                                  passwordVisible =
                                      const Icon(LineAwesomeIcons.eye_slash);
                                }
                              });
                            },
                          )),
                      obscureText: _isPasswordVisible,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your password';
                        }
                        // if (!RegExp(r'[A-Z]').hasMatch(value)) {
                        //   return 'Password must contain at least 1 capital letter';
                        // }
                        // if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                        //     .hasMatch(value)) {
                        //   return 'Password must contain at least 1 special character';
                        // }
                        // if (!RegExp(r'[0-9]').hasMatch(value)) {
                        //   return 'Password must contain at least 1 numeric character';
                        // }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        return null;
                      },
                      onSaved: (value) => _password = value!,
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your Phone Number';
                        } else if (!pakistanPhoneRegExp.hasMatch(value)) {
                          return 'Please enter Valid Phone Number';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) => _phoneNumber = value!,
                    ),
                    TextFormField(
                      controller: _dobController,
                      decoration:
                          const InputDecoration(labelText: 'Date of Birth'),
                      keyboardType: TextInputType.none,
                      readOnly: true,
                      showCursor: false,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your date of birth';
                        }
                        return null;
                      },
                      onTap: () => _selectDate(context),
                      onSaved: (value) => _dateOfBirth = value!,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.PRIMARY_COLOR),
                      onPressed: _signUpWithEmailAndPassword,
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Already have an account? Login here',
                        style: TextStyle(color: AppColors.PRIMARY_COLOR),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
                child: Container(
                    color: Colors.black.withOpacity(0.8),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CupertinoActivityIndicator(
                            radius: 25, color: AppColors.PRIMARY_COLOR),
                        SizedBox(height: 10),
                        Text('Signing Up...',
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
