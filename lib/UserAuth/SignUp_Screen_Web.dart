import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hostel_add/UserAuth/SignUp_Screen.dart';
import 'package:hostel_add/resources/values/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:modern_form_line_awesome_icons/modern_form_line_awesome_icons.dart';
import 'package:permission_handler/permission_handler.dart';

class SignUpScreenWeb extends SignUpScreenState {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isPasswordVisible = true;
  Icon passwordVisible = const Icon(LineAwesomeIcons.eye_slash);
  final TextEditingController dobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          width: MediaQuery.sizeOf(context).width / 2,
          padding: const EdgeInsets.all(16.0),
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
                      child: imageBytes != null
                          ? Image.memory(imageBytes!)
                          : const Icon(Icons.person_sharp,
                          size: 100,
                          color: AppColors.primaryColor),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: openFileExplorer,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: AppColors.primaryColor,
                        ),
                        child:
                        const Icon(LineAwesomeIcons.camera_retro),
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
                      decoration: const InputDecoration(
                          labelText: 'Full Name'),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                      onSaved: (value) => fullName = value!,
                    ),
                    TextFormField(
                      decoration:
                      const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                      onSaved: (value) => email = value!,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          label: const Text('Password'),
                          suffixIcon: IconButton(
                            icon: passwordVisible,
                            onPressed: () {
                              setState(() {
                                if (isPasswordVisible == true) {
                                  isPasswordVisible = false;
                                  passwordVisible = const Icon(
                                      LineAwesomeIcons.eye);
                                } else if (isPasswordVisible ==
                                    false) {
                                  isPasswordVisible = true;
                                  passwordVisible = const Icon(
                                      LineAwesomeIcons.eye_slash);
                                }
                              });
                            },
                          )),
                      obscureText: isPasswordVisible,
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
                      onSaved: (value) => password = value!,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your Phone Number';
                        } else if (!pakistanPhoneRegExp
                            .hasMatch(value)) {
                          return 'Please enter Valid Phone Number';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) => phoneNumber = value!,
                    ),
                    TextFormField(
                      controller: dobController,
                      decoration: const InputDecoration(
                          labelText: 'Date of Birth'),
                      keyboardType: TextInputType.none,
                      readOnly: true,
                      showCursor: false,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your date of birth';
                        }
                        return null;
                      },
                      onTap: () => selectDate(context),
                      onSaved: (value) => dateOfBirth = value!,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor),
                        onPressed: () => signUpWithEmailAndPassword,
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Already have an account? Login here',
                        textAlign: TextAlign.center,
                        style:
                        TextStyle(color: AppColors.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
