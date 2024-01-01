import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hostel_add/resources/values/colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modern_form_line_awesome_icons/modern_form_line_awesome_icons.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  RegExp pakistanPhoneRegExp = RegExp(r'^03[0-9]{2}[0-9]{7}$');

  User? user;
  File? newProfileImage;
  String? profileImageUrl;
  String? oldPassword;
  String? newPassword;
  Uint8List? _imageBytes;
  String? downloadUrl;

  DateTime _selectedDate = DateTime.now();
  bool _isOldVisible = true;
  Icon oldPasswordVisible = const Icon(LineAwesomeIcons.eye_slash);
  bool _isNewVisible = true;
  Icon newPasswordVisible = const Icon(LineAwesomeIcons.eye_slash);
  bool _isLoading = false;

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

  Future<void> _getImageFromGallery() async {
    await [Permission.camera, Permission.storage, Permission.photos].request();
    bool isStoragePermissionGranted = await Permission.storage.isGranted;
    //bool isGalleryPermissionGranted = await Permission.photos.isGranted; // for ios

    if (isStoragePermissionGranted) {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          newProfileImage = File(pickedFile.path);
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
    await [Permission.camera, Permission.storage, Permission.photos].request();
    bool isCameraPermissionGranted = await Permission.camera.isGranted;
    if (isCameraPermissionGranted) {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          newProfileImage = File(pickedFile.path);
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

  Future<void> _updateUserData() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();

      setState(() {
        _isLoading = true;
      });

      try {
        final credential = EmailAuthProvider.credential(
          email: user!.email!,
          password: oldPassword!,
        );
        await user!.reauthenticateWithCredential(credential);
      } catch (e) {
        Fluttertoast.showToast(
            msg: "Old Password Incorrect!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            textColor: Colors.white,
            fontSize: 10.0);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        if (newPassword != null && newPassword!.isNotEmpty) {
          await user!.updatePassword(newPassword!);
        }
        final userDoc = _firestore.collection('users').doc(user?.uid);

        await userDoc.update({
          'full_name': _fullNameController.text,
          'phone_number': _phoneNumController.text,
          'date_of_birth': _dobController.text,
        });

        if (kIsWeb) {
          if (_imageBytes!.isNotEmpty) {
            if (profileImageUrl != "") {
              await _storage
                  .refFromURL(profileImageUrl!)
                  .delete(); // delete old profile picture
            }
            await _uploadImageWeb();

            await userDoc.update({
              'profile_image_url': downloadUrl,
            });
          }
        } else {
          if (newProfileImage != null) {
            if (profileImageUrl != null && profileImageUrl != "") {
              await _storage
                  .refFromURL(profileImageUrl!)
                  .delete(); // delete old profile picture
            }
            String imageName = '${DateTime.now()}.jpg';
            final storageRef =
                _storage.ref().child('profile_images/${user?.uid}/$imageName');
            final UploadTask uploadTask = storageRef.putFile(newProfileImage!);
            final TaskSnapshot snapshot =
                await uploadTask.whenComplete(() => null);

            if (snapshot.state == TaskState.success) {
              downloadUrl = await storageRef.getDownloadURL();
              await userDoc.update({
                'profile_image_url': downloadUrl,
              });
            }
          }
        }
        Fluttertoast.showToast(
            msg: "Profile Updated Successfully!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            textColor: Colors.white,
            fontSize: 10.0);
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
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      }
    }
  }

  Future<void> _uploadImageWeb() async {
    if (_imageBytes != null) {
      String imageName = '${DateTime.now()}.jpg';
      final storageRef =
          _storage.ref().child('profile_images/${user?.uid}/$imageName');
      await storageRef.putData(_imageBytes!);
      downloadUrl = await storageRef.getDownloadURL();
    }
  }

  void _openFileExplorer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _imageBytes = result.files.single.bytes!;
      });
    }
  }

  Widget _buildPhoneLayout() {
    return SingleChildScrollView(
      child: Container(
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
                    child: newProfileImage != null
                        ? Image.file(newProfileImage!)
                        : profileImageUrl == ""
                            ? const Icon(Icons.person_sharp,
                                size: 100, color: AppColors.primaryColor)
                            : CachedNetworkImage(
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                imageUrl: profileImageUrl!,
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: showOptions,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: AppColors.primaryColor,
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
                        prefixIcon: Icon(LineAwesomeIcons.user)),
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
                        prefixIcon: Icon(LineAwesomeIcons.phone)),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your Phone Number';
                      } else if (!pakistanPhoneRegExp.hasMatch(value)) {
                        return 'Please enter Valid Phone Number';
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _dobController,
                    keyboardType: TextInputType.none,
                    readOnly: true,
                    showCursor: false,
                    decoration: const InputDecoration(
                        label: Text('Date of Birth'),
                        prefixIcon: Icon(LineAwesomeIcons.birthday_cake)),
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your date of birth';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    obscureText: _isOldVisible,
                    decoration: InputDecoration(
                        label: const Text('Enter Old Password'),
                        prefixIcon: const Icon(Icons.fingerprint_sharp),
                        suffixIcon: IconButton(
                          icon: oldPasswordVisible,
                          onPressed: () {
                            setState(() {
                              if (_isOldVisible == true) {
                                _isOldVisible = false;
                                oldPasswordVisible =
                                    const Icon(LineAwesomeIcons.eye);
                              } else if (_isOldVisible == false) {
                                _isOldVisible = true;
                                oldPasswordVisible =
                                    const Icon(LineAwesomeIcons.eye_slash);
                              }
                            });
                          },
                        )),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your old password';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        oldPassword = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    obscureText: _isNewVisible,
                    decoration: InputDecoration(
                        label: const Text('Enter New Password'),
                        prefixIcon: const Icon(Icons.fingerprint_sharp),
                        suffixIcon: IconButton(
                          icon: newPasswordVisible,
                          onPressed: () {
                            setState(() {
                              if (_isNewVisible == true) {
                                _isNewVisible = false;
                                newPasswordVisible =
                                    const Icon(LineAwesomeIcons.eye);
                              } else if (_isNewVisible == false) {
                                _isNewVisible = true;
                                newPasswordVisible =
                                    const Icon(LineAwesomeIcons.eye_slash);
                              }
                            });
                          },
                        )),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your new password';
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
                      onPressed: _updateUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        side: BorderSide.none,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'Update',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text.rich(
                        TextSpan(
                            text: 'Joined Date: ',
                            style: const TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(
                                text: user != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(user!.metadata.creationTime!)
                                    : 'N/A',
                              )
                            ]),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTabletAndWebLayout(double width) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          width: width / 2,
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: _imageBytes != null
                              ? Image.memory(_imageBytes!)
                              : profileImageUrl != ""
                                  ? CachedNetworkImage(
                                      placeholder: (context, url) =>
                                          const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                      imageUrl: profileImageUrl!,
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    )
                                  : const Icon(Icons.person_sharp,
                                      size: 100, color: AppColors.primaryColor),
                        )

                        // child: profileImageUrl == ""
                        //         ? const Icon(Icons.person_sharp,
                        //             size: 100, color: AppColors.primaryColor)
                        //         : CachedNetworkImage(
                        //             placeholder: (context, url) => const Center(
                        //                 child: CircularProgressIndicator()),
                        //             imageUrl: profileImageUrl!,
                        //             errorWidget: (context, url, error) =>
                        //                 const Icon(Icons.error),
                        //           ),
                        ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _openFileExplorer,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: AppColors.primaryColor,
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
                          prefixIcon: Icon(LineAwesomeIcons.user)),
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
                          prefixIcon: Icon(LineAwesomeIcons.phone)),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your Phone Number';
                        } else if (!pakistanPhoneRegExp.hasMatch(value)) {
                          return 'Please enter Valid Phone Number';
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _dobController,
                      keyboardType: TextInputType.none,
                      readOnly: true,
                      showCursor: false,
                      decoration: const InputDecoration(
                          label: Text('Date of Birth'),
                          prefixIcon: Icon(LineAwesomeIcons.birthday_cake)),
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your date of birth';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      obscureText: _isOldVisible,
                      decoration: InputDecoration(
                          label: const Text('Enter Old Password'),
                          prefixIcon: const Icon(Icons.fingerprint_sharp),
                          suffixIcon: IconButton(
                            icon: oldPasswordVisible,
                            onPressed: () {
                              setState(() {
                                if (_isOldVisible == true) {
                                  _isOldVisible = false;
                                  oldPasswordVisible =
                                      const Icon(LineAwesomeIcons.eye);
                                } else if (_isOldVisible == false) {
                                  _isOldVisible = true;
                                  oldPasswordVisible =
                                      const Icon(LineAwesomeIcons.eye_slash);
                                }
                              });
                            },
                          )),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your old password';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          oldPassword = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      obscureText: _isNewVisible,
                      decoration: InputDecoration(
                          label: const Text('Enter New Password'),
                          prefixIcon: const Icon(Icons.fingerprint_sharp),
                          suffixIcon: IconButton(
                            icon: newPasswordVisible,
                            onPressed: () {
                              setState(() {
                                if (_isNewVisible == true) {
                                  _isNewVisible = false;
                                  newPasswordVisible =
                                      const Icon(LineAwesomeIcons.eye);
                                } else if (_isNewVisible == false) {
                                  _isNewVisible = true;
                                  newPasswordVisible =
                                      const Icon(LineAwesomeIcons.eye_slash);
                                }
                              });
                            },
                          )),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your new password';
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
                        onPressed: _updateUserData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text.rich(
                          TextSpan(
                              text: 'Joined Date: ',
                              style: const TextStyle(color: Colors.grey),
                              children: [
                                TextSpan(
                                  text: user != null
                                      ? DateFormat('dd/MM/yyyy')
                                          .format(user!.metadata.creationTime!)
                                      : 'N/A',
                                )
                              ]),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Future<void> _deleteUser() async {
  //   try {
  //     if (user != null) {
  //       await user!.delete();
  //       Fluttertoast.showToast(
  //           msg: "Account deleted successfully!",
  //           toastLength: Toast.LENGTH_LONG,
  //           gravity: ToastGravity.BOTTOM,
  //           timeInSecForIosWeb: 2,
  //           textColor: Colors.white,
  //           fontSize: 10.0);
  //
  //       print("User deleted successfully.");
  //
  //To Do:
  //delete all ads of this user too!
  //delete user profile picture also
  //Navigate to login screen and clear shared prefs here
  //     } else {
  //       print("No user is currently signed in.");
  //     }
  //   } catch (e) {
  //     print("Error deleting user: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _isLoading ? false : true,
      child: Stack(
        children: [
          Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.primaryColor,
                title: const Text(
                  'Edit Profile',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                iconTheme: const IconThemeData(color: Colors.white),
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
              body: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  if (constraints.maxWidth < 600) {
                    // For smaller screens (phones)
                    return _buildPhoneLayout();
                  } else {
                    // For larger screens (tablets, web)
                    return _buildTabletAndWebLayout(constraints.maxWidth);
                  }
                },
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
                        Text("Updating...",
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
