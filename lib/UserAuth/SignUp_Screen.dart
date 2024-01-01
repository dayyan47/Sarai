import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hostel_add/UserAuth/SignUp_Screen_Mobile.dart';
import 'package:hostel_add/UserAuth/SignUp_Screen_Web.dart';
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

  UserCredential? userCredential;
  bool isLoading = false;
  bool isPasswordVisible = true;
  String email = '';
  String password = '';
  String fullName = '';
  String phoneNumber = '';
  String dateOfBirth = '';
  File? profileImage;
  Uint8List? imageBytes;
  String? imageUrl;
  RegExp pakistanPhoneRegExp = RegExp(r'^03[0-9]{2}[0-9]{7}$');
  Icon passwordVisible = const Icon(LineAwesomeIcons.eye_slash);
  DateTime selectedDate = DateTime.now();
  final TextEditingController dobController = TextEditingController();

  Future<void> getImageFromGallery() async {
    await [Permission.storage, Permission.photos].request();
    bool isStoragePermissionGranted = await Permission.storage.isGranted;
    bool isGalleryPermissionGranted = await Permission.photos.isGranted; // for ios

    if (isStoragePermissionGranted || isGalleryPermissionGranted) {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          profileImage = File(pickedFile.path);
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

  Future<void> getImageFromCamera() async {
    await [Permission.camera].request();
    bool isCameraPermissionGranted = await Permission.camera.isGranted;
    if (isCameraPermissionGranted) {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          profileImage = File(pickedFile.path);
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

  void showOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Photo Gallery'),
            onPressed: () {
              Navigator.of(context).pop();
              getImageFromGallery(); // get image from gallery
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              Navigator.of(context).pop();
              getImageFromCamera(); // get image from camera
            },
          ),
        ],
      ),
    );
  }

  void openFileExplorer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        imageBytes = result.files.single.bytes!;
      });
    }
  }

  Future<void> uploadImageWeb() async {
    if (imageBytes != null) {
      String imageName = '${DateTime.now()}.jpg';
      final imageReference = FirebaseStorage.instance
          .ref()
          .child('profile_images/${userCredential!.user!.uid}/$imageName');
      await imageReference.putData(imageBytes!);
      imageUrl = await imageReference.getDownloadURL();
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialEntryMode: DatePickerEntryMode.calendar,
        initialDate: selectedDate,
        firstDate: DateTime(1947),
        lastDate: selectedDate);
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> sendVerificationEmail() async {
    User user = _auth.currentUser;

    if (user.emailVerified) {
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

  Future<void> signUpWithEmailAndPassword() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      try {
        setState(() {
          _isLoading = true;
        });

        userCredential = await _auth.createUserWithEmailAndPassword(
            email: _email, password: _password);

        if (kIsWeb) {
          await _uploadImageWeb();
          if (_imageBytes != null) {
            await _fireStore
                .collection('users')
                .doc(userCredential!.user!.uid)
                .set({
              'full_name': _fullName,
              'email': _email,
              'phone_number': _phoneNumber,
              'date_of_birth': _dateOfBirth,
              'profile_image_url': imageUrl,
              'fav_ads': [],
            });
          } else {
            await _fireStore
                .collection('users')
                .doc(userCredential!.user!.uid)
                .set({
              'full_name': _fullName,
              'email': _email,
              'phone_number': _phoneNumber,
              'date_of_birth': _dateOfBirth,
              'profile_image_url': "",
              'fav_ads': [],
            });
          }
        } else {
          if (_profileImage != null) {
            String imageName = '${DateTime.now()}.jpg';
            final imageReference = FirebaseStorage.instance.ref().child(
                'profile_images/${userCredential!.user!.uid}/$imageName');
            await imageReference.putFile(_profileImage!);
            imageUrl = await imageReference.getDownloadURL();

            await _fireStore
                .collection('users')
                .doc(userCredential!.user!.uid)
                .set({
              'full_name': _fullName,
              'email': _email,
              'phone_number': _phoneNumber,
              'date_of_birth': _dateOfBirth,
              'profile_image_url': imageUrl,
              'fav_ads': [],
            });
          } else {
            await _fireStore
                .collection('users')
                .doc(userCredential!.user!.uid)
                .set({
              'full_name': _fullName,
              'email': _email,
              'phone_number': _phoneNumber,
              'date_of_birth': _dateOfBirth,
              'profile_image_url': "",
              'fav_ads': [],
            });
          }
        }

        Fluttertoast.showToast(
            msg: "Sign Up Successfully!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            textColor: Colors.white,
            fontSize: 10.0);

        print('Signed up as ${userCredential!.user!.email}');
        print('Full Name: $_fullName');
        print('Phone Number: $_phoneNumber');
        print('Date of Birth: $_dateOfBirth');
        print('Profile Image URL: $imageUrl');

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
    return PopScope(
      canPop: isLoading ? false : true,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
                backgroundColor: AppColors.primaryColor,
                title: const Text('Sign Up',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                iconTheme: const IconThemeData(color: Colors.white)),
            body: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth < 600) {
                  // For smaller screens (phones)
                  return const SignUpScreenMobile();
                } else {
                  // For larger screens (tablets, web)
                  return const SignUpScreenWeb();
                }
              },
            ),
          ),
          if (isLoading)
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
                      ],
                    )))
        ],
      ),
    );
  }
}
