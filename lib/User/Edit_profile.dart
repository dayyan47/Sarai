import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hostel_add/User/Prof_Screen.dart';
import 'package:hostel_add/Home_Screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modern_form_line_awesome_icons/modern_form_line_awesome_icons.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  User? user;
  String? profileImageUrl;
  String? newPassword;
  File? newProfileImage;
  DateTime _selectedDate = DateTime.now();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _phoneNumController = TextEditingController();
  TextEditingController _dobController = TextEditingController();

  RegExp pakistanPhoneRegExp = RegExp(r'^03[0-9]{2}[0-9]{7}$');

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    loadUserData();
  }

  Future<void> loadUserData() async {
    final userDoc = _firestore.collection('users').doc(user?.uid);
    final userData = await userDoc.get();
    if (userData.exists) {
      setState(() {
        _fullNameController.text = userData['full_name'];
        _phoneNumController.text = userData['phone_number'];
        _dobController.text = userData['date_of_birth'];
        profileImageUrl = userData['profile_image_url'];
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        newProfileImage = File(pickedImage.path);
      });
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

  // Future<void> _uploadImage() async {
  //   if (newProfileImage != null) {
  //     final Reference storageRef =
  //         _storage.ref().child('profile_images').child(user!.uid);
  //     final UploadTask uploadTask = storageRef.putFile(newProfileImage!);
  //     final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
  //
  //     if (snapshot.state == TaskState.success) {
  //       final String downloadUrl = await storageRef.getDownloadURL();
  //
  //       await _firestore.collection('users').doc(user?.uid).update({
  //         'profile_image_url': downloadUrl,
  //       });
  //
  //       setState(() {
  //         profileImageUrl = downloadUrl;
  //         newProfileImage = null;
  //       });
  //     }
  //   }
  // }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (newPassword != null &&
            newPassword!.isNotEmpty) {
          await FirebaseAuth.instance.currentUser!
              .updatePassword(newPassword!);
        }
        final userDoc =
        _firestore.collection('users').doc(user?.uid);

        await userDoc.update({
          'full_name': _fullNameController.text,
          'phone_number': _phoneNumController.text,
          'date_of_birth': _dobController.text,
        });
        if (newProfileImage != null) {
          final Reference storageRef = _storage
              .ref()
              .child('profile_images')
              .child(user!.uid);
          final UploadTask uploadTask =
          storageRef.putFile(newProfileImage!);
          final TaskSnapshot snapshot =
          await uploadTask.whenComplete(() => null);

          if (snapshot.state == TaskState.success) {
            final String downloadUrl =
            await storageRef.getDownloadURL();
            await userDoc.update({
              'profile_image_url': downloadUrl,
            });
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile Updated Successfully'),
            duration: Duration(seconds: 5),
          ),
        );
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                const ProfScreen()));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(
          content: Text(
              'Failed to Update Profile, Please Try Again Later'),
          duration: Duration(seconds: 3),
        ));
      }
    }
  }

  Future<void> _deleteUser() async{
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        Fluttertoast.showToast(
            msg: "Account deleted successfully!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            textColor: Colors.white,
            fontSize: 10.0);

        print("User deleted successfully.");

        //delete all ads of this user too!
        //Navigate to login screen and clear shared prefs here
      } else {
        print("No user is currently signed in.");
      }
    } catch (e) {
      print("Error deleting user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF5A5F),
        title: Text(
            'Edit Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        iconTheme: IconThemeData(color: Colors.white),
        // actions: [
        //   IconButton(
        //   icon: Icon(
        //     Icons.delete_forever,
        //   ),
        //   onPressed: _deleteUser,
        // ),
        //   SizedBox(width: 10)
        // ],
        ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: profileImageUrl != null
                          ? Image.network(
                              profileImageUrl!,
                              errorBuilder: (context, error, stackTrace) {
                                return const Placeholder();
                              },
                            )
                          : const Placeholder(),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: const Color(0xFFFF5A5F),
                        ),
                        child: const Icon(LineAwesomeIcons.camera_retro),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _fullNameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        label: Text('Full Name'),
                        prefixIcon: Icon(LineAwesomeIcons.user),
                      ),
                      // onChanged: (value) {
                      //   setState(() {
                      //     _fullNameController. = value;
                      //   });
                      // },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _phoneNumController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        label: Text('Phone Number'),
                        prefixIcon: Icon(LineAwesomeIcons.phone),
                      ),
                      validator:  (value){
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
                      // onChanged: (value) {
                      //   setState(() {
                      //     phoneNumber = value;
                      //   });
                      // },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _dobController,
                      //initialValue: dateOfBirth ?? '',
                      keyboardType: TextInputType.none,
                      decoration: const InputDecoration(
                        label: Text('Date of Birth'),
                        prefixIcon: Icon(LineAwesomeIcons.birthday_cake),
                      ),
                      onTap: ()=> _selectDate(context),
                      // onChanged: (value) {
                      //   setState(() {
                      //     dateOfBirth = value;
                      //   });
                      // },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your date of birth';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        label: const Text('Enter New Password'),
                        prefixIcon: const Icon(Icons.fingerprint_sharp),
                        suffixIcon: IconButton(
                          icon: const Icon(LineAwesomeIcons.eye_slash),
                          onPressed: () {  },// to do show password
                        ),
                      ),
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
                      onChanged: (value) {
                        setState(() {
                          newPassword = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateUserData ,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5A5F),
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    //const SizedBox(height: 10),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text.rich(
                    //       TextSpan(
                    //           text: 'Joined Date:',
                    //           style: const TextStyle(
                    //               fontSize: 12, color: Colors.white),
                    //           children: [
                    //             TextSpan(
                    //                 text: user != null
                    //                     ? DateFormat('MM dd, yyyy').format(
                    //                         user!.metadata.creationTime!)
                    //                     : 'N/A',
                    //                 style: const TextStyle(
                    //                     fontSize: 12,
                    //                     fontWeight: FontWeight.bold))
                    //           ]),
                    //     ),
                    //   ],
                    // ),
                    // ElevatedButton(
                    //   onPressed: () {},// to do
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: const Color(0xFFFF5A5F),
                    //     shape: const StadiumBorder(),
                    //     side: BorderSide.none,
                    //   ),
                    //   child: const Text(
                    //     'Delete Account',
                    //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    //   ),
                    // ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}
