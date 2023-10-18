import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';

class PostAdScreen extends StatefulWidget {
  @override
  _PostAdScreenState createState() => _PostAdScreenState();
}

class _PostAdScreenState extends State<PostAdScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  File? _image;
  String? _selectedGender;
  String? _selectedACOption;
  String? _selectedUPSOption;
  String? _selectedInternetOption;
  String? _selectedRoomsOption;
  String? _selectedParkingOption;
  List<File> selectedImages = [];
  final picker = ImagePicker();
  String? _latitude;
  String? _longitude;

  @override
  void initState() {
    super.initState();
    _fetchUserPhoneNumber();
  }

  Future<void> _fetchUserPhoneNumber() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userSnapshot =
          await _firestore.collection('users').doc(user.uid).get();
      final userData = userSnapshot.data() as Map<String, dynamic>;
      final phoneNumber = userData['phone_number'] as String?;
      if (phoneNumber != null) {
        setState(() {});
      }
    }
  }

  Future<void> getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
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
        msg: "Location saved! LAT: ${_latitude}, LONG: $_longitude",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
      // You can now use latitude and longitude for your ad posting logic.
    } else {
      // Handle the case where location couldn't be obtained
    }
  }

  Future<void> _postAd() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final adData = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'price': _priceController.text,
          'gender': _selectedGender,
          'phone_number': _phoneNumberController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'province': _provinceController.text,
          'AC': _selectedACOption,
          'UPS': _selectedUPSOption,
          'Internet': _selectedInternetOption,
          'Rooms': _selectedRoomsOption,
          'Parking': _selectedParkingOption,
          'userId': user.uid,
          'latitude': _latitude,
          'longitude': _longitude,
          'timestamp': FieldValue.serverTimestamp(),
        };

        if (_image != null) {
          final imageUrl = await uploadImage(_image!);
          if (imageUrl != null) {
            adData['image_url'] = imageUrl;
            //setState(() {});
          } else {
            // Handle image upload error
            print('Image upload failed.');
          }
        }

        await _firestore.collection('ads').add(adData);

        // Clear input fields and reset state
        // _titleController.clear();
        // _descriptionController.clear();
        // _priceController.clear();
        // _phoneNumberController.clear();
        // _addressController.clear();
        // _cityController.clear();
        // _provinceController.clear();
        // setState(() {
        //   _image = null;
        //   _selectedGender = null;
        //   _selectedACOption = null;
        //   _selectedUPSOption = null;
        //   _selectedInternetOption = null;
        //   _selectedRoomsOption = null;
        //   _selectedParkingOption = null;
        // });

        Navigator.pop(context);
      } catch (e) {
        print('Error posting ad: $e');
        Fluttertoast.showToast(msg: e.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            textColor: Colors.white,
            fontSize: 10.0);
        // Handle the error as needed
      }
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
      //final UploadTask uploadTask = storageReference.putFile(imageFile);
      //final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      //final String imageUrl = await storageReference.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFF5A5F),
        title: Text(
          'Post Your Ad',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        //centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: GestureDetector(
                  onTap: getImage,
                  child: _image != null
                      ? AspectRatio(
                          aspectRatio: 10 / 2,
                          child: Image.file(
                            _image!,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Icon(Icons.add_a_photo,
                          size: 50, color: Color(0xFFFF5A5F)),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'City'),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _provinceController,
                decoration: InputDecoration(labelText: 'Province'),
              ),
              SizedBox(
                height: 10,
              ),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                onChanged: (newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                items: ['Boys Hostel', 'Girls Hostel']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Hostel Type'),
              ),
              SizedBox(
                height: 10,
              ),
              DropdownButtonFormField<String>(
                value: _selectedACOption,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedACOption = newValue;
                  });
                },
                items:
                    ['Yes', 'No'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Air Conditioner AC'),
              ),
              SizedBox(
                height: 10,
              ),
              DropdownButtonFormField<String>(
                value: _selectedUPSOption,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUPSOption = newValue;
                  });
                },
                items:
                    ['Yes', 'No'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'UPS'),
              ),
              SizedBox(
                height: 10,
              ),
              DropdownButtonFormField<String>(
                value: _selectedInternetOption,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedInternetOption = newValue;
                  });
                },
                items:
                    ['Yes', 'No'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Internet'),
              ),
              SizedBox(
                height: 10,
              ),
              DropdownButtonFormField<String>(
                value: _selectedRoomsOption,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRoomsOption = newValue;
                  });
                },
                items: ['Single', 'Double', 'Triple', 'Quad']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Rooms Type'),
              ),
              SizedBox(
                height: 10,
              ),
              DropdownButtonFormField<String>(
                value: _selectedParkingOption,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedParkingOption = newValue;
                  });
                },
                items:
                    ['Yes', 'No'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Parking'),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF5A5F)),
                  onPressed: _getLocation,
                  child: Text(
                    'Save Location',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF5A5F)),
                  onPressed: _postAd,
                  child: Text(
                    'Post Ad',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
