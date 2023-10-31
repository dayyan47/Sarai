import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:modern_form_line_awesome_icons/modern_form_line_awesome_icons.dart';
import 'package:permission_handler/permission_handler.dart';

class PostEditAdScreen extends StatefulWidget {
  final String adId; // Pass the ad id to edit the specific ad
  const PostEditAdScreen({super.key, required this.adId});

  @override
  _PostEditAdScreenState createState() => _PostEditAdScreenState();
}

class _PostEditAdScreenState extends State<PostEditAdScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _hostelNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _FLM1 = TextEditingController();
  final TextEditingController _FLM2 = TextEditingController();
  final TextEditingController _FLM3 = TextEditingController();

  File? _image;
  String? _selectedCity;
  String? _selectedGender;
  String? _selectedACOption;
  String? _selectedUPSOption;
  String? _selectedInternetOption;
  String? _selectedRoomsOption;
  String? _selectedParkingOption;
  String? _imageUrl;
  String? _imageName;
  String? _latitude;
  String? _longitude;
  bool _isLoading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.adId != "Post Ad") _isEdit = true;

    if (_isEdit) _fetchAdData();
  }

  Future<void> _fetchAdData() async {
    try {
      final adDoc = await _firestore.collection('ads').doc(widget.adId).get();
      final adData = adDoc.data() as Map<String, dynamic>;
      setState(() {
        _hostelNameController.text = adData['hostel_name'];
        _descriptionController.text = adData['description'];
        _priceController.text = adData['price'];
        _phoneNumberController.text = adData['phone_number'];
        _addressController.text = adData['address'];
        _areaController.text = adData['area'];
        _FLM1.text = adData['FLM1'];
        _FLM2.text = adData['FLM2'];
        _FLM3.text = adData['FLM3'];
        _selectedCity = adData['city'];
        _selectedGender = adData['gender'];
        _selectedACOption = adData['AC'];
        _selectedUPSOption = adData['UPS'];
        _selectedRoomsOption = adData['Rooms'];
        _selectedInternetOption = adData['Internet'];
        _selectedParkingOption = adData['Parking'];
        _imageUrl = adData['image_url'];
        _imageName = adData['image_name'];
      });
    } catch (e) {
      print('Error fetching ad data: $e');
    }
  }

  Future<void> _updateAd() async {
    final user = _auth.currentUser;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      if (user != null) {
        try {
          setState(() {
            _isLoading = true;
          });

          final adData = {
            'hostel_name': _hostelNameController.text,
            'description': _descriptionController.text,
            'price': _priceController.text,
            'gender': _selectedGender,
            'phone_number': _phoneNumberController.text,
            'address': _addressController.text,
            'area': _areaController.text,
            'FLM1': _FLM1.text,
            'FLM2': _FLM2.text,
            'FLM3': _FLM3.text,
            'city': _selectedCity,
            'AC': _selectedACOption,
            'UPS': _selectedUPSOption,
            'Internet': _selectedInternetOption,
            'Rooms': _selectedRoomsOption,
            'Parking': _selectedParkingOption,
            'latitude': _latitude,
            'longitude': _longitude,
            // You may also update other fields like 'timestamp' if needed.
          };
          if (_imageName != null) {
            //delete old picture from storage first
            await FirebaseStorage.instance
                .ref()
                .child('ad_images')
                .child(_imageName!)
                .delete();
          }

          if (_image != null) {
            final imageUrl = await uploadImage(_image!);
            if (imageUrl != null) {
              adData['image_name'] = imageUrl[0];
              adData['image_url'] = imageUrl[1];
            } else if (imageUrl.isEmpty || imageUrl == "") {
              adData['image_name'] = "";
              adData['image_url'] = "Image upload failed.";
            } else {
              // Handle image upload error
              print('Image upload failed.');
            }
          }

          await _firestore.collection('ads').doc(widget.adId).update(adData);
        } catch (e) {
          // Handle the error as needed
          print('Error updating ad: $e');
          Fluttertoast.showToast(
              msg: e.toString(),
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              textColor: Colors.white,
              fontSize: 10.0);
        } finally {
          Navigator.pop(context);
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _deleteAd() async {
    try {
      await _firestore.collection('ads').doc(widget.adId).delete();
      if (_imageName != null) {
        await FirebaseStorage.instance
            .ref()
            .child('ad_images')
            .child(_imageName!)
            .delete();
      }

      Fluttertoast.showToast(
          msg: "Ad deleted successfully!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          textColor: Colors.white,
          fontSize: 10.0);
      Navigator.of(context)
        ..pop()
        ..pop()
        ..pop();
    } catch (e) {
      print('Error updating ad: $e');
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          textColor: Colors.white,
          fontSize: 10.0);
    }
  }

  //List<File> selectedImages = [];
  //String? _userPhoneNumber;
  //final picker = ImagePicker();

  // @override
  // void initState() {
  //   super.initState();
  //   //_fetchUserPhoneNumber();
  // }

  // Future<void> _fetchUserPhoneNumber() async {
  //   final user = _auth.currentUser;
  //   if (user != null) {
  //     final userSnapshot =
  //         await _firestore.collection('users').doc(user.uid).get();
  //     final userData = userSnapshot.data() as Map<String, dynamic>;
  //     final phoneNumber = userData['phone_number'] as String?;
  //     if (phoneNumber != null) {
  //       setState(() {
  //         _userPhoneNumber = phoneNumber;
  //       });
  //     }
  //   }
  // }

  Future<void> _getImageFromGallery() async {
    bool isStoragePermissionGranted = await Permission.storage.isGranted;
    //bool isGalleryPermissionGranted = await Permission.photos.isGranted; // for ios

    if (isStoragePermissionGranted) {
      final pickedFile =
      await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
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
    bool isCameraPermissionGranted = await Permission.camera.isGranted;
    if (isCameraPermissionGranted) {
      final pickedFile =
      await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
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

  Future showOptions() async {
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

  // Future<void> getImage() async {
  //   final XFile? pickedFile =
  //       await _imagePicker.pickImage(source: ImageSource.camera);
  //
  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //     });
  //   }
  //
  //   final _pickedFile = await picker.pickMultiImage(
  //     imageQuality: 100,
  //     maxHeight: 1000,
  //     maxWidth: 1000,
  //   );
  //
  //   List<XFile> xfilePick = _pickedFile;
  //   if (xfilePick.isNotEmpty) {
  //     for (var i = 0; i < xfilePick.length; i++) {
  //       selectedImages.add(File(xfilePick[i].path));
  //     }
  //     setState(() {});
  //   } else {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(const SnackBar(content: Text('Nothing is Selected')));
  //   }
  // }

  void _getCurrentLocation() async {
    bool isLocationPermissionGranted = await Permission.location.isGranted;
    if(isLocationPermissionGranted) {
      // Get the user's current location
      final location = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (location != null) {
        // Save the location to your database or use it as needed
        _latitude = location.latitude.toString();
        _longitude = location.longitude.toString();
        Fluttertoast.showToast(
          msg: "Current Location Saved",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );
      } else {
        // Handle the case where location couldn't be obtained
        _latitude = "";
        _longitude = "";
        Fluttertoast.showToast(
          msg: "Location not saved",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );
      }
    } else {
      Fluttertoast.showToast(
          msg: "Please grant Location permission first!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          textColor: Colors.white,
          fontSize: 10.0);
      openAppSettings();
    }
  }

  void _getOtherLocation() {
    Fluttertoast.showToast(
      msg:
          "navigate to map screen where user can select its own location through marker.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
    );
  }

  Future<void> _postAd() async {
    final user = _auth.currentUser;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      if (user != null) {
        try {
          setState(() {
            _isLoading = true;
          });

          final adData = {
            'hostel_name': _hostelNameController.text,
            'description': _descriptionController.text,
            'price': _priceController.text,
            'gender': _selectedGender,
            'phone_number': _phoneNumberController.text,
            'address': _addressController.text,
            'area': _areaController.text,
            'FLM1': _FLM1.text,
            'FLM2': _FLM2.text,
            'FLM3': _FLM3.text,
            'city': _selectedCity,
            'AC': _selectedACOption,
            'UPS': _selectedUPSOption,
            'Internet': _selectedInternetOption,
            'Rooms': _selectedRoomsOption,
            'Parking': _selectedParkingOption,
            'latitude': _latitude,
            'longitude': _longitude,
            'userId': user.uid,
            'timestamp': FieldValue.serverTimestamp(),
          };

          if (_image != null) {
            final imageUrl = await uploadImage(_image!);
            if (imageUrl != null) {
              adData['image_name'] = imageUrl[0];
              adData['image_url'] = imageUrl[1];
            } else if (imageUrl.isEmpty || imageUrl == "") {
              adData['image_name'] = "";
              adData['image_url'] = "Image upload failed.";
            } else {
              // Handle image upload error
              print('Image upload failed.');
            }
          }
          await _firestore.collection('ads').add(adData);
        } catch (e) {
          // Handle the error as needed
          print('Error posting ad: $e');
          Fluttertoast.showToast(
              msg: e.toString(),
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              textColor: Colors.white,
              fontSize: 10.0);
        } finally {
          Navigator.pop(context);
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<List<String?>> uploadImage(File imageFile) async {
    try {
      String imageName = '${DateTime.now()}.jpg';
      final imageReference =
          FirebaseStorage.instance.ref().child('ad_images').child(imageName);
      await imageReference.putFile(imageFile);
      //imageReference.fullPath;
      final imageUrl = await imageReference.getDownloadURL();
      List<String> data = [imageName, imageUrl];
      return data;
    } catch (e) {
      print('Error uploading image: $e');
      return [];
    }
  }

  // Future<String?> uploadImage(File imageFile) async {
  //   // try {
  //   //   final Reference storageReference = FirebaseStorage.instance
  //   //       .ref()
  //   //       .child('ad_images')
  //   //       .child('${DateTime.now()}.jpg');
  //   //   final UploadTask uploadTask = storageReference.putFile(imageFile);
  //   //   final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
  //   //   final String imageUrl = await storageReference.getDownloadURL();
  //   //   return imageUrl;
  //   // } catch (e) {
  //   //   print('Error uploading image: $e');
  //   //   return null;
  //   // }
  //
  //   // try {
  //   //   final Reference storageReference = FirebaseStorage.instance
  //   //       .ref()
  //   //       .child('ad_images')
  //   //       .child('${DateTime.now()}.jpg');
  //   //   final String imageUrl = await storageReference.getDownloadURL();
  //   //   return imageUrl;
  //   // } catch (e) {
  //   //   print('Error uploading image: $e');
  //   //   return null;
  //   // }
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _isLoading ? false : true,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
                backgroundColor: const Color(0xFFFF5A5F),
                title: Text(
                  _isEdit ? 'Edit Your Ad' : 'Post Your Ad',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                iconTheme: const IconThemeData(
                  color: Colors.white,
                ),
                actions: _isEdit
                    ? [
                        IconButton(
                            icon: const Icon(
                              Icons.delete_forever,
                            ),
                            onPressed: () async {
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Are you sure?'),
                                  content: const Text(
                                      'This action will permanently delete this Ad'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: _deleteAd,
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (result == null || !result) {
                                return;
                              }
                            }),
                        const SizedBox(width: 10)
                      ]
                    : null),
            body: SingleChildScrollView(
                child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(70),//100
                            child: _image != null
                                ? Image.file(_image!)
                                : _imageUrl != null
                                    ? Image.network(_imageUrl!)
                                    :  IconButton(onPressed: showOptions, icon: const Icon(Icons.add_a_photo), iconSize: 50, color: const Color(0xFFFF5A5F)),
                          ),
                        ),
                        if (_image != null || _imageUrl != null)
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
                                color: const Color(0xFFFF5A5F),
                              ),
                              child: const Icon(LineAwesomeIcons.camera_retro),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: _hostelNameController,
                      keyboardType: TextInputType.text,
                      decoration:
                          const InputDecoration(labelText: 'Hostel name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Hostel Name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _descriptionController,
                      minLines: 1,
                      maxLines: 2,
                      keyboardType: TextInputType.text,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter Description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Monthly Rent'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter Monthly Rent';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Phone Number'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter Phone Number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _addressController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(labelText: 'Address'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter Address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _areaController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Sub Area', hintText: ("(Optional)")),
                      // validator: (value) {
                      //   if (value!.isEmpty) {
                      //     return 'Please enter Address';
                      //   }
                      //   return null;
                      // },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _FLM1,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Famous Landmark 1',
                          hintText: "(Optional)"),
                      // validator: (value) {
                      //   if (value!.isEmpty) {
                      //     return 'Please enter Address';
                      //   }
                      //   return null;
                      // },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _FLM2,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Famous Landmark 2',
                          hintText: "(Optional)"),
                      // validator: (value) {
                      //   if (value!.isEmpty) {
                      //     return 'Please enter Address';
                      //   }
                      //   return null;
                      // },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _FLM3,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Famous Landmark 3',
                          hintText: "(Optional)"),
                      // validator: (value) {
                      //   if (value!.isEmpty) {
                      //     return 'Please enter Address';
                      //   }
                      //   return null;
                      // },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Select City'),
                      value: _selectedCity,
                      onChanged: (value) =>
                          setState(() => _selectedCity = value),
                      validator: (value) =>
                          value == null ? 'Please select City' : null,
                      items: ['Lahore', 'Karachi', 'Islamabad']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: 'Select Hostel Type'),
                      value: _selectedGender,
                      onChanged: (value) =>
                          setState(() => _selectedGender = value),
                      validator: (value) =>
                          value == null ? 'Please select Hostel Gender' : null,
                      items: ['Boys Hostel', 'Girls Hostel']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Air Conditioning'),
                      value: _selectedACOption,
                      onChanged: (value) =>
                          setState(() => _selectedACOption = value),
                      validator: (value) =>
                          value == null ? 'Please select AC Option' : null,
                      items: ['Yes', 'No']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'UPS'),
                      value: _selectedUPSOption,
                      onChanged: (value) =>
                          setState(() => _selectedUPSOption = value),
                      validator: (value) =>
                          value == null ? 'Please select UPS Option' : null,
                      items: ['Yes', 'No']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Internet'),
                      value: _selectedInternetOption,
                      onChanged: (value) =>
                          setState(() => _selectedInternetOption = value),
                      validator: (value) => value == null
                          ? 'Please select Internet Option'
                          : null,
                      items: ['Yes', 'No']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Select Room Type'),
                      value: _selectedRoomsOption,
                      onChanged: (value) =>
                          setState(() => _selectedRoomsOption = value),
                      validator: (value) =>
                          value == null ? 'Please select Room Option' : null,
                      items: ['Single', 'Double', 'Triple', 'Quad']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Parking'),
                      value: _selectedParkingOption,
                      onChanged: (value) =>
                          setState(() => _selectedParkingOption = value),
                      validator: (value) =>
                          value == null ? 'Please select Parking Option' : null,
                      items: ['Yes', 'No']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5A5F)),
                        onPressed: _getCurrentLocation,
                        child: const Text(
                          'Save Current Location',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5A5F)),
                        onPressed: _getOtherLocation,
                        child: const Text(
                          'Save Other Location',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Center(
                      child: !_isEdit
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF5A5F)),
                              onPressed: _postAd,
                              child: const Text(
                                'Post Ad',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF5A5F)),
                              onPressed: _updateAd,
                              child: const Text(
                                'Update Ad',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            )),
          ),
          if (_isLoading)
            Positioned.fill(
                child: Container(
                    color: Colors.black.withOpacity(0.8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CupertinoActivityIndicator(
                            radius: 25, color: Color(0xFFFF5A5F)),
                        const SizedBox(height: 10),
                        Text(_isEdit ? "Updating..." : "Posting...",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                decoration: TextDecoration.none))
                      ],
                    ))),
        ],
      ),
    );
  }
}
