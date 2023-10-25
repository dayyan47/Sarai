import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hostel_add/New_Splash_Screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';

class PostEditAdScreen extends StatefulWidget {
  final String adId; // Pass the ad id to edit the specific ad
  PostEditAdScreen({required this.adId});

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
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => NewSplashScreen()));
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
          if(_imageName != null) //delete old picture from storage first
            await FirebaseStorage.instance.ref().child('ad_images').child(_imageName!).delete();

          if (_image != null) {
            final imageUrl = await uploadImage(_image!);
            if (imageUrl != null) {
              adData['image_name'] = imageUrl[0];
              adData['image_url'] = imageUrl[1];
            }  else if (imageUrl == null || imageUrl.isEmpty || imageUrl == "") {
              adData['image_name'] = "";
              adData['image_url'] = "Image upload failed.";
            } else {
              // Handle image upload error
              print('Image upload failed.');
            }
          }

          await _firestore.collection('ads').doc(widget.adId).update(adData);

          Navigator.pop(context);
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
          //Navigator.of(context)..pop()..pop();
          Navigator.pop(context);
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
      if(_imageName != null)
        await FirebaseStorage.instance.ref().child('ad_images').child(_imageName!).delete();

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

    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _getImageFromCamera() async {

    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  //Show options to get image from camera or gallery
  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text('Photo Gallery'),
            onPressed: () {
              Navigator.of(context).pop();
              _getImageFromGallery(); // get image from gallery
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Camera'),
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
    // Request location permission
    await Permission.location.request();

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
          // Show the loading indicator and navigate to the splash screen
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => NewSplashScreen()));
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
            } else if (imageUrl == null || imageUrl.isEmpty || imageUrl == "") {
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
          //Navigator.of(context)..pop()..pop();
          Navigator.pop(context);
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
      final imageReference = FirebaseStorage.instance
          .ref()
          .child('ad_images')
          .child(imageName);
      await imageReference.putFile(imageFile!);
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
    return _isLoading
        ? CircularProgressIndicator()
        : Scaffold(
            appBar: AppBar(
                backgroundColor: Color(0xFFFF5A5F),
                title: Text(
                  _isEdit ? 'Edit Your Ad' : 'Post Your Ad',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                iconTheme: IconThemeData(
                  color: Colors.white,
                ),
                actions: _isEdit
                    ? [
                        IconButton(
                            icon: Icon(
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
                        SizedBox(width: 10)
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
                    Center(
                        child: GestureDetector(
                      onTap: showOptions,
                      child: _image != null
                          ? AspectRatio(
                              aspectRatio: 10 / 2,
                              child: Image.file(
                                _image!,
                                fit: BoxFit.contain,
                              ),
                            )
                          : _imageUrl != null
                              ? AspectRatio(
                                  aspectRatio: 10 / 2,
                                  child: Image.network(
                                    _imageUrl!,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Icon(Icons.add_a_photo,
                                  size: 50, color: Color(0xFFFF5A5F)),
                    )),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _hostelNameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: 'Hostel name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Hostel Name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _descriptionController,
                      minLines: 1,
                      maxLines: 2,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: 'Description'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter Description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Monthly Rent'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter Monthly Rent';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter Phone Number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _addressController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: 'Address'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter Address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _areaController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: 'Sub Area', hintText: ("(Optional)")),
                      // validator: (value) {
                      //   if (value!.isEmpty) {
                      //     return 'Please enter Address';
                      //   }
                      //   return null;
                      // },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _FLM1,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: 'Famous Landmark 1',
                          hintText: "(Optional)"),
                      // validator: (value) {
                      //   if (value!.isEmpty) {
                      //     return 'Please enter Address';
                      //   }
                      //   return null;
                      // },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _FLM2,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: 'Famous Landmark 2',
                          hintText: "(Optional)"),
                      // validator: (value) {
                      //   if (value!.isEmpty) {
                      //     return 'Please enter Address';
                      //   }
                      //   return null;
                      // },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _FLM3,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          labelText: 'Famous Landmark 3',
                          hintText: "(Optional)"),
                      // validator: (value) {
                      //   if (value!.isEmpty) {
                      //     return 'Please enter Address';
                      //   }
                      //   return null;
                      // },
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Select City'),
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
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration:
                          InputDecoration(labelText: 'Select Hostel Type'),
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
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration:
                          InputDecoration(labelText: 'Air Conditioning'),
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
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'UPS'),
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
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Internet'),
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
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration:
                          InputDecoration(labelText: 'Select Room Type'),
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
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Parking'),
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
                    SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF5A5F)),
                        onPressed: _getCurrentLocation,
                        child: Text(
                          'Save Current Location',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF5A5F)),
                        onPressed: _getOtherLocation,
                        child: Text(
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
                                  backgroundColor: Color(0xFFFF5A5F)),
                              onPressed: _postAd,
                              child: Text(
                                'Post Ad',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFF5A5F)),
                              onPressed: _updateAd,
                              child: Text(
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
          );
  }
}
