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

import '../Splash_Screen.dart';

class EditAdScreen extends StatefulWidget {
  final String adId; // Pass the ad id to edit the specific ad
  EditAdScreen({required this.adId});

  @override
  _EditAdScreenState createState() => _EditAdScreenState();
}

class _EditAdScreenState extends State<EditAdScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  File? _image;
  String? _selectedCity;
  String? _selectedGender;
  String? _selectedACOption;
  String? _selectedUPSOption;
  String? _selectedInternetOption;
  String? _selectedRoomsOption;
  String? _selectedParkingOption;
  String? _imageUrl;
  String? _latitude;
  String? _longitude;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAdData();
  }

  // List<File> _images = [];
  //
  // @override
  // void initState() {
  //   super.initState();
  //   _fetchUserPhoneNumber();
  //   _fetchAdData();
  // }
  //
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

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _getLocation() async {
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
        msg: "Location saved",
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

  Future<void> _fetchAdData() async {
    try {
      final adDoc = await _firestore.collection('ads').doc(widget.adId).get();
      final adData = adDoc.data() as Map<String, dynamic>;
      setState(() {
        _titleController.text = adData['title'];
        _descriptionController.text = adData['description'];
        _priceController.text = adData['price'];
        _phoneNumberController.text = adData['phone_number'];
        _addressController.text = adData['address'];
        _selectedCity = adData['city'];
        _selectedGender = adData['gender'];
        _selectedACOption = adData['AC'];
        _selectedUPSOption = adData['UPS'];
        _selectedRoomsOption = adData['Rooms'];
        _selectedInternetOption = adData['Internet'];
        _selectedParkingOption = adData['Parking'];
        _imageUrl = adData['image_url'];
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
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => NewSplashScreen()));
          setState(() {
            _isLoading = true;
          });

          final adData = {
            'title': _titleController.text,
            'description': _descriptionController.text,
            'price': _priceController.text,
            'gender': _selectedGender,
            'phone_number': _phoneNumberController.text,
            'address': _addressController.text,
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

          if (_image != null) {
            final imageUrl = await uploadImage(_image!);
            if (imageUrl != null) {
              adData['image_url'] = imageUrl;
            } else {
              // Handle image upload error
              adData['image_url'] = "Image upload failed.";
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
      Fluttertoast.showToast(
          msg: "Ad deleted successfully!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          textColor: Colors.white,
          fontSize: 10.0);
      Navigator.of(context)
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

  Future<String?> uploadImage(File imageFile) async {
    try {
      final imageReference = FirebaseStorage.instance
          .ref()
          .child('ad_images')
          .child('${DateTime.now()}.jpg');
      await imageReference.putFile(imageFile!);
      final imageUrl = await imageReference.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFFFF5A5F),
              title: Text(
                'Edit Your Ad',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              iconTheme: IconThemeData(
                color: Colors.white,
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.delete_forever,
                  ),
                  onPressed: _deleteAd,
                ),
                SizedBox(width: 10)
              ],
            ),
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
                        onTap: _getImage,
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
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _titleController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Title';
                        }
                        return null;
                      },
                      //onSaved: (value) => _titleController.text = value!,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _descriptionController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: 'Description'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter Description';
                        }
                        return null;
                      },
                      onSaved: (value) => _descriptionController.text = value!,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Price'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter Price';
                        }
                        return null;
                      },
                      onSaved: (value) => _priceController.text = value!,
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
                      onSaved: (value) => _phoneNumberController.text = value!,
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
                      onSaved: (value) => _addressController.text = value!,
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      hint: Text('Select City'),
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
                      value: _selectedGender,
                      hint: Text('Select Hostel Type'),
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
                      value: _selectedACOption,
                      hint: Text('Air Conditioning'),
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
                      value: _selectedUPSOption,
                      hint: Text('UPS'),
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
                      value: _selectedInternetOption,
                      hint: Text('Internet'),
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
                      value: _selectedRoomsOption,
                      hint: Text('Room Type'),
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
                      value: _selectedParkingOption,
                      hint: Text('Parking'),
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
                        onPressed: _getLocation,
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
                        onPressed: _updateAd,
                        child: Text(
                          'Post Ad',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
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
