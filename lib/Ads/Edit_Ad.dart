import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class EditAdScreen extends StatefulWidget {
  final String adId; // Pass the ad ID to edit the specific ad

  EditAdScreen({required this.adId});

  @override
  _EditAdScreenState createState() => _EditAdScreenState();
}

class _EditAdScreenState extends State<EditAdScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  File? _image;
  String? _selectedACOption;
  String? _selectedGender;
  String? _selectedUPSOption;
  String? _selectedInternetOption;
  String? _selectedRoomsOption;
  String? _selectedParkingOption;
  String? _userPhoneNumber;
  String? _imageUrl;

  List<File> _images = [];

  @override
  void initState() {
    super.initState();
    _fetchUserPhoneNumber();
    _fetchAdData();
  }

  Future<void> _fetchUserPhoneNumber() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userSnapshot =
          await _firestore.collection('users').doc(user.uid).get();
      final userData = userSnapshot.data() as Map<String, dynamic>;
      final phoneNumber = userData['phone_number'] as String?;
      if (phoneNumber != null) {
        setState(() {
          _userPhoneNumber = phoneNumber;
        });
      }
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
        _cityController.text = adData['city'];
        _provinceController.text = adData['province'];
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

  Future<String?> uploadImage(File imageFile) async {
    try {
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('ad_images')
          .child('${DateTime.now()}.jpg');
      final UploadTask uploadTask = storageReference.putFile(imageFile);
      //final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      final String imageUrl = await storageReference.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _updateAd() async {
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
          // You may also update other fields like 'timestamp' if needed.
        };

        if (_image != null) {
          final imageUrl = await uploadImage(_image!);
          if (imageUrl != null) {
            adData['image_url'] = imageUrl;
            setState(() {
              _imageUrl = imageUrl;
            });
          } else {
            // Handle image upload error
            print('Image upload failed.');
          }
        }

        await _firestore.collection('ads').doc(widget.adId).update(adData);

        // Clear input fields and reset state
        _titleController.value;
        _descriptionController.value;
        _priceController.value;
        _phoneNumberController.value;
        _addressController.value;
        _cityController.value;
        _provinceController.value;
        setState(() {
          _image = null;
          _selectedGender = null;
          _selectedACOption = null;
          _selectedUPSOption = null;
          _selectedInternetOption = null;
          _selectedRoomsOption = null;
          _selectedParkingOption = null;
        });

        // Navigate back to the previous screen or perform other actions as needed
        Navigator.pop(context);
      } catch (e) {
        print('Error updating ad: $e');
        // Handle the error as needed
      }
    }
  }

  Future<void> _getImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFFF5A5F),
        title: Text('Edit Your Ad'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
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
                onChanged: (newValue) {
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
                decoration: InputDecoration(labelText: 'UPS'),
              ),
              SizedBox(
                height: 10,
              ),
              DropdownButtonFormField<String>(
                value: _selectedInternetOption,
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
                items:
                ['Single', 'Double', 'Triple', 'Quad'].map<DropdownMenuItem<String>>((String value) {
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
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF5A5F)),
                  onPressed: _updateAd,
                  child: Text(
                    'Save Changes',
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
