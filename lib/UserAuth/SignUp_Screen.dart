import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  UserCredential? _userCredential;
  bool _isLoading = false;
  bool _isPasswordVisible = true;
  String _email = '';
  String _password = '';
  String _fullName = '';
  String _phoneNumber = '';
  String _dateOfBirth = '';
  File? _profileImageMobile;
  Uint8List? _profileImageWeb;
  String? _imageURL;
  Icon _passwordVisible = const Icon(LineAwesomeIcons.eye_slash);
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _dobController = TextEditingController();
  final RegExp _pakistanPhoneRegExp = RegExp(r'^03[0-9]{2}[0-9]{7}$');

  Future<void> _getImageFromGallery() async {
    await [Permission.storage, Permission.photos].request();
    bool isStoragePermissionGranted = await Permission.storage.isGranted;
    bool isGalleryPermissionGranted =
        await Permission.photos.isGranted; // For IOS
    if (isStoragePermissionGranted || isGalleryPermissionGranted) {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImageMobile = File(pickedFile.path);
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
      openAppSettings(); // Open App Settings to grant permission if user declined at first
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
          _profileImageMobile = File(pickedFile.path);
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
      openAppSettings(); // Open App Settings to grant permission if user declined at first
    }
  }

  void _showMobileOptions() {
    showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(actions: [
              CupertinoActionSheetAction(
                  child: const Text('Photo Gallery'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _getImageFromGallery();
                  }),
              CupertinoActionSheetAction(
                  child: const Text('Camera'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _getImageFromCamera();
                  })
            ]));
  }

  void _openFileExplorerForWeb() async {
    FilePickerResult? pickedFile =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (pickedFile != null) {
      setState(() {
        _profileImageWeb = pickedFile.files.single.bytes;
      });
    }
  }

  Future<void> _uploadImageWeb() async {
    try {
      if (_profileImageWeb != null) {
        String imageName = '${DateTime.now()}.jpg';
        final imageReference = FirebaseStorage.instance
            .ref()
            .child('profile_images/${_userCredential!.user!.uid}/$imageName');
        await imageReference.putData(
            _profileImageWeb!, SettableMetadata(contentType: 'image/jpeg'));
        _imageURL = await imageReference.getDownloadURL();
      }
    } catch (e) {
      print("Upload Profile Image Web Failed! $e");
    }
  }

  Future<void> _uploadImageMobile() async {
    try {
      if (_profileImageMobile != null) {
        String imageName = '${DateTime.now()}.jpg';
        final imageReference = FirebaseStorage.instance
            .ref()
            .child('profile_images/${_userCredential!.user!.uid}/$imageName');
        await imageReference.putFile(
            _profileImageMobile!, SettableMetadata(contentType: 'image/jpeg'));
        _imageURL = await imageReference.getDownloadURL();
      }
    } catch (e) {
      print("Upload Profile Image Mobile Failed! $e");
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
        _userCredential = await _auth.createUserWithEmailAndPassword(
            email: _email, password: _password);
        if (_profileImageWeb != null) {
          await _uploadImageWeb();
        } else if (_profileImageMobile != null) {
          await _uploadImageMobile();
        }
        await _fireStore
            .collection('users')
            .doc(_userCredential!.user!.uid)
            .set({
          'full_name': _fullName,
          'email': _email,
          'phone_number': _phoneNumber,
          'date_of_birth': _dateOfBirth,
          'profile_image_url': _imageURL ?? "",
          'fav_ads': [],
        });
        _sendVerificationEmail();
        Fluttertoast.showToast(
            msg: "Sign Up Successfully!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            textColor: Colors.white,
            fontSize: 10.0);
        print('Signed up as ${_userCredential!.user!.email}');
        print('Full Name: $_fullName');
        print('Phone Number: $_phoneNumber');
        print('Date of Birth: $_dateOfBirth');
        //print('Profile Image URL: $_imageURL');
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(
            msg: 'Error signing up: $e',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            textColor: Colors.white,
            fontSize: 10.0);
        print('Error signing up: $e');
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
    return PopScope(
        canPop: _isLoading ? false : true,
        child: Stack(children: [
          Scaffold(
              appBar: AppBar(
                  backgroundColor: AppColors.primaryColor,
                  title: const Text('Sign Up',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  iconTheme: const IconThemeData(color: Colors.white)),
              body: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                    child: Center(
                        child: Container(
                            width: constraints.maxWidth >= 600
                                ? constraints.maxWidth / 2
                                : constraints.maxWidth,
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Stack(children: [
                                    SizedBox(
                                        width: 120,
                                        height: 120,
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child: _profileImageWeb != null
                                                ? Image.memory(
                                                    _profileImageWeb!)
                                                : _profileImageMobile != null
                                                    ? Image.file(
                                                        _profileImageMobile!)
                                                    : const Icon(
                                                        Icons.person_sharp,
                                                        size: 100,
                                                        color: AppColors
                                                            .primaryColor))),
                                    Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: InkWell(
                                            onTap: kIsWeb
                                                ? _openFileExplorerForWeb
                                                : _showMobileOptions,
                                            child: Container(
                                                width: 35,
                                                height: 35,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    color:
                                                        AppColors.primaryColor),
                                                child: const Icon(
                                                    LineAwesomeIcons
                                                        .camera_retro))))
                                  ]),
                                  const SizedBox(height: 25),
                                  Form(
                                      key: _formKey,
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            TextFormField(
                                                decoration:
                                                    const InputDecoration(
                                                        labelText: 'Full Name'),
                                                keyboardType:
                                                    TextInputType.text,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Please enter your full name';
                                                  }
                                                  return null;
                                                },
                                                onSaved: (value) =>
                                                    _fullName = value!),
                                            TextFormField(
                                                decoration:
                                                    const InputDecoration(
                                                        labelText: 'Email'),
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Please enter your email';
                                                  }
                                                  return null;
                                                },
                                                onSaved: (value) =>
                                                    _email = value!),
                                            TextFormField(
                                                decoration: InputDecoration(
                                                    label:
                                                        const Text('Password'),
                                                    suffixIcon: IconButton(
                                                        icon: _passwordVisible,
                                                        onPressed: () {
                                                          setState(() {
                                                            if (_isPasswordVisible ==
                                                                true) {
                                                              _isPasswordVisible =
                                                                  false;
                                                              _passwordVisible =
                                                                  const Icon(
                                                                      LineAwesomeIcons
                                                                          .eye);
                                                            } else if (_isPasswordVisible ==
                                                                false) {
                                                              _isPasswordVisible =
                                                                  true;
                                                              _passwordVisible =
                                                                  const Icon(
                                                                      LineAwesomeIcons
                                                                          .eye_slash);
                                                            }
                                                          });
                                                        })),
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
                                                onSaved: (value) =>
                                                    _password = value!),
                                            TextFormField(
                                                decoration: const InputDecoration(
                                                    labelText: 'Phone Number'),
                                                keyboardType:
                                                    TextInputType.phone,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Please enter your Phone Number';
                                                  } else if (!_pakistanPhoneRegExp
                                                      .hasMatch(value)) {
                                                    return 'Please enter Valid Phone Number';
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                onSaved: (value) =>
                                                    _phoneNumber = value!),
                                            TextFormField(
                                                controller: _dobController,
                                                decoration:
                                                    const InputDecoration(
                                                        labelText:
                                                            'Date of Birth'),
                                                readOnly: true,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Please enter your date of birth';
                                                  }
                                                  return null;
                                                },
                                                onTap: () =>
                                                    _selectDate(context),
                                                onSaved: (value) =>
                                                    _dateOfBirth = value!),
                                            const SizedBox(height: 10),
                                            SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                AppColors
                                                                    .primaryColor),
                                                    onPressed:
                                                        _signUpWithEmailAndPassword,
                                                    child: const Text('Sign Up',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)))),
                                            const SizedBox(height: 10),
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text(
                                                    'Already have an account? Login here',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .primaryColor)))
                                          ]))
                                ]))));
              })),
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
                          Text('Signing Up...',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  decoration: TextDecoration.none))
                        ])))
        ]));
  }
}
