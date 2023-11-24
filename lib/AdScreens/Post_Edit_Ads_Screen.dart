import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hostel_add/Widgets/CheckBoxFormField_Widget.dart';
import 'package:hostel_add/Widgets/Other_Location_Widget.dart';
import 'package:hostel_add/resources/values/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
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

  final TextEditingController _hostelNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _fLM1 = TextEditingController();
  final TextEditingController _fLM2 = TextEditingController();
  final TextEditingController _fLM3 = TextEditingController();
  final RegExp _pakPhoneNumRegExp = RegExp(r'^03[0-9]{2}[0-9]{7}$');

  String? _userName;
  String? _selectedCity;
  String? _selectedGender;
  String? _selectedACOption;
  String? _selectedUPSOption;
  String? _selectedInternetOption;
  String? _selectedRoomsOption;
  String? _selectedParkingOption;
  String? _latitude;
  String? _longitude;
  String loading = "";
  bool _isLoading = false;
  bool _isEdit = false;
  List<XFile> _images = [];
  List<dynamic> _imageUrls = [];
  List<XFile> _newImages = [];
  List<dynamic> _selectedRoomTypes = [];

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // to save owner name of ad when posting ad!
    if (widget.adId != "Post Ad") {
      //Check, if we want to edit ad or post
      setState(() {
        _isEdit = true;
      });
      _fetchAdData();
    }
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
        _fLM1.text = adData['FLM1'];
        _fLM2.text = adData['FLM2'];
        _fLM3.text = adData['FLM3'];
        _userName = adData['owner'];
        _selectedCity = adData['city'];
        _selectedGender = adData['gender'];
        _selectedACOption = adData['AC'];
        _selectedUPSOption = adData['UPS'];
        _selectedRoomsOption = adData['Rooms'];
        _selectedInternetOption = adData['Internet'];
        _selectedParkingOption = adData['Parking'];
        _latitude = adData['latitude'];
        _longitude = adData['longitude'];
        _selectedRoomTypes = adData['room_types'];
        if (adData['image_urls'] != null) {
          _imageUrls = adData['image_urls'];
        }
      });

    } catch (e) {
      print('Error fetching ad data: $e');
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          textColor: Colors.white,
          fontSize: 10.0);
    }
  }

  Future<void> _uploadImages(List<XFile> images) async {
    try {
      for (var image in images) {
        String imageName = '${DateTime.now()}.jpg';
        final imageReference =
            FirebaseStorage.instance.ref().child('ad_images').child(imageName);
        await imageReference.putFile(File(image.path));
        final imageUrl = await imageReference.getDownloadURL();
        _imageUrls.add(imageUrl);
      }
      print('Uploaded image URLs: $_imageUrls');
    } catch (e) {
      print('Error uploading images: $e');
    }
  }

  Future<void> _fetchUserName() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userSnapshot =
          await _firestore.collection('users').doc(user.uid).get();
      final userData = userSnapshot.data() as Map<String, dynamic>;
      final name = userData['full_name'] as String?;
      if (name != null) {
        setState(() {
          _userName = name;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    await [Permission.location].request();

    bool isLocationPermissionGranted = await Permission.location.isGranted;
    if (isLocationPermissionGranted) {
      final location = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (location.latitude.toString().isNotEmpty &&
          location.longitude.toString().isNotEmpty) {
        _latitude = location.latitude.toString();
        _longitude = location.longitude.toString();
        Fluttertoast.showToast(
          msg: "Current Location Saved",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );
      } else {
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

  Future<void> _getSelectedLocation(LatLng location) async {
    await [Permission.location].request();

    bool isLocationPermissionGranted = await Permission.location.isGranted;
    if (isLocationPermissionGranted) {
      if (location.latitude.toString().isNotEmpty &&
          location.longitude.toString().isNotEmpty) {
        _latitude = location.latitude.toString();
        _longitude = location.longitude.toString();
        Fluttertoast.showToast(
          msg: "New Location Saved",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );
      } else {
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

  Future<void> _postAd() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final user = _auth.currentUser;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      if (user != null) {
        try {
          setState(() {
            _isLoading = true;
            loading = "Posting...";
          });

          final Map<String, dynamic> adData = {
            'hostel_name': _hostelNameController.text,
            'description': _descriptionController.text,
            'price': _priceController.text,
            'gender': _selectedGender,
            'phone_number': _phoneNumberController.text,
            'address': _addressController.text,
            'area': _areaController.text,
            'FLM1': _fLM1.text,
            'FLM2': _fLM2.text,
            'FLM3': _fLM3.text,
            'city': _selectedCity,
            'AC': _selectedACOption,
            'UPS': _selectedUPSOption,
            'Internet': _selectedInternetOption,
            'Rooms': _selectedRoomsOption,
            'Parking': _selectedParkingOption,
            'latitude': _latitude,
            'longitude': _longitude,
            'userId': user.uid,
            'owner': _userName,
            'ownerEmail': user.email,
            'room_types': _selectedRoomTypes,
            'timestamp': FieldValue.serverTimestamp(),
          };

          if (_images.isNotEmpty) {
            await _uploadImages(_images);
            adData['image_urls'] = _imageUrls;
            print('Images uploaded Successfully.');
          }

          await _firestore.collection('ads').add(adData);
          Fluttertoast.showToast(
              msg: "Ad Posted Successfully!",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              textColor: Colors.white,
              fontSize: 10.0);
        } catch (e) {
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
            loading = "";
          });
        }
      }
    }
  }

  Future<void> _updateAd() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final user = _auth.currentUser;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      if (user != null) {
        try {
          setState(() {
            _isLoading = true;
            loading = "Updating...";
          });

          final Map<String, dynamic> adData = {
            'hostel_name': _hostelNameController.text,
            'description': _descriptionController.text,
            'price': _priceController.text,
            'gender': _selectedGender,
            'phone_number': _phoneNumberController.text,
            'address': _addressController.text,
            'area': _areaController.text,
            'FLM1': _fLM1.text,
            'FLM2': _fLM2.text,
            'FLM3': _fLM3.text,
            'city': _selectedCity,
            'AC': _selectedACOption,
            'UPS': _selectedUPSOption,
            'Internet': _selectedInternetOption,
            'Rooms': _selectedRoomsOption,
            'Parking': _selectedParkingOption,
            'latitude': _latitude,
            'longitude': _longitude,
            'room_types': _selectedRoomTypes
          };

          if (_newImages.isNotEmpty) {
            await _uploadImages(_newImages);
            adData['image_urls'] = _imageUrls;
            print('Images uploaded Successfully.');
          }

          //   //delete old picture from storage first
          //   if (_imageName != null && _imageName != "") {
          //     await FirebaseStorage.instance
          //         .ref()
          //         .child('ad_images')
          //         .child(_imageName!)
          //         .delete();
          //   }

          await _firestore.collection('ads').doc(widget.adId).update(adData);
          Fluttertoast.showToast(
              msg: "Ad Updated Successfully!",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              textColor: Colors.white,
              fontSize: 10.0);
        } catch (e) {
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
            loading = "";
          });
        }
      }
    }
  }

  Future<void> _deleteAd() async {
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      setState(() {
        _isLoading = true;
        loading = "Deleting...";
      });
      await _firestore.collection('ads').doc(widget.adId).delete();
      if (_imageUrls.isNotEmpty) {
        for (var imageUrl in _imageUrls) {
          await FirebaseStorage.instance.refFromURL(imageUrl).delete();
        }
      }

      Fluttertoast.showToast(
          msg: "Ad deleted successfully!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          textColor: Colors.white,
          fontSize: 10.0);
    } catch (e) {
      print('Error updating ad: $e');
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          textColor: Colors.white,
          fontSize: 10.0);
    } finally {
      Navigator.of(context)
        ..pop()
        ..pop();
      setState(() {
        _isLoading = false;
        loading = "";
      });
    }
  }

  Future<void> _getImageFromGallery() async {
    await [Permission.camera, Permission.storage, Permission.photos].request();
    bool isStoragePermissionGranted = await Permission.storage.isGranted;
    //bool isGalleryPermissionGranted = await Permission.photos.isGranted; // for ios
    if (isStoragePermissionGranted) {
      List<XFile>? selectedImages = await ImagePicker().pickMultiImage();

      if (_isEdit) {
        if (selectedImages.isNotEmpty) {
          setState(() {
            _newImages.addAll(selectedImages);
          });
        }
      } else {
        if (selectedImages.isNotEmpty) {
          setState(() {
            _images.addAll(selectedImages);
          });
        }
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
      if (_isEdit) {
        if (pickedFile != null) {
          setState(() {
            _newImages.add(XFile(pickedFile.path));
          });
        }
      } else {
        if (pickedFile != null) {
          setState(() {
            _images.add(XFile(pickedFile.path));
          });
        }
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _isLoading ? false : true,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
                backgroundColor: AppColors.primaryColor,
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
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteAd();
                                      },
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
                    if (_isEdit &&
                        _imageUrls
                            .isNotEmpty) // for old images that are already uploaded for edit ad
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _imageUrls.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CachedNetworkImage(
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                imageUrl: _imageUrls[index],
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            );
                          },
                        ),
                      ),
                    if ((_isEdit && _newImages.isNotEmpty) ||
                        (_images.isNotEmpty &&
                            !_isEdit)) // for new images that are going to be uploaded for edit ad
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: (_isEdit && _newImages.isNotEmpty)
                              ? _newImages.length
                              : (_images.isNotEmpty && !_isEdit)
                                  ? _images.length
                                  : 0,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: (_isEdit && _newImages.isNotEmpty)
                                    ? Image.file(File(_newImages[index].path))
                                    : (_images.isNotEmpty && !_isEdit)
                                        ? Image.file(File(_images[index].path))
                                        : null);
                          },
                        ),
                      ),
                    if ((_images.isNotEmpty && !_isEdit) ||
                        (_isEdit &&
                            (_imageUrls.isNotEmpty ||
                                _newImages.isNotEmpty))) // for post ad
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor),
                        onPressed: showOptions,
                        child: const Text('Add More Images',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    if ((_images.isEmpty && !_isEdit) ||
                        (_isEdit &&
                            _imageUrls.isEmpty &&
                            _newImages.isEmpty)) // for post ad
                      IconButton(
                          onPressed: showOptions,
                          icon: const Icon(Icons.add_a_photo),
                          iconSize: 50,
                          color: AppColors.primaryColor),
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
                          return 'Please enter your Phone Number';
                        } else if (!_pakPhoneNumRegExp.hasMatch(value)) {
                          return 'Please enter Valid Phone Number';
                        } else {
                          return null;
                        }
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
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _fLM1,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Famous Landmark 1',
                          hintText: "(Optional)"),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _fLM2,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Famous Landmark 2',
                          hintText: "(Optional)"),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _fLM3,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          labelText: 'Famous Landmark 3',
                          hintText: "(Optional)"),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Room Type',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        CheckboxFormField(
                          value: _selectedRoomTypes.contains('Single'),
                          errorColor: AppColors.primaryColor,
                          title: const Text('1. Single person room'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value != null && value) {
                                _selectedRoomTypes.add('Single');
                              } else {
                                _selectedRoomTypes.remove('Single');
                              }
                            });
                          },
                          validator: (bool? value) {
                            if (_selectedRoomTypes.isEmpty) {
                              return 'Please Select!';
                            } else if (value!) {
                              return null;
                            }
                          },
                        ),
                        CheckboxFormField(
                          value: _selectedRoomTypes.contains('Double'),
                          errorColor: AppColors.primaryColor,
                          title: const Text('2. Two persons sharing room'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value != null && value) {
                                _selectedRoomTypes.add('Double');
                              } else {
                                _selectedRoomTypes.remove('Double');
                              }
                            });
                          },
                          validator: (bool? value) {
                            if (_selectedRoomTypes.isEmpty) {
                              return 'Please Select!';
                            } else if (value!) {
                              return null;
                            }
                          },
                        ),
                        CheckboxFormField(
                          value: _selectedRoomTypes.contains('Triple'),
                          errorColor: AppColors.primaryColor,
                          title: const Text('3. Three persons sharing room'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value != null && value) {
                                _selectedRoomTypes.add('Triple');
                              } else {
                                _selectedRoomTypes.remove('Triple');
                              }
                            });
                          },
                          validator: (bool? value) {
                            if (_selectedRoomTypes.isEmpty) {
                              return 'Please Select!';
                            } else if (value!) {
                              return null;
                            }
                          },
                        ),
                        CheckboxFormField(
                          value: _selectedRoomTypes.contains('Quad'),
                          errorColor: AppColors.primaryColor,
                          title: const Text('4. Four persons sharing room'),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value != null && value) {
                                _selectedRoomTypes.add('Quad');
                              } else {
                                _selectedRoomTypes.remove('Quad');
                              }
                            });
                          },
                          validator: (bool? value) {
                            if (_selectedRoomTypes.isEmpty) {
                              return 'Please Select!';
                            } else if (value!) {
                              return null;
                            }
                          },
                        ),
                      ],
                    ),
                    // DropdownButtonFormField<String>(
                    //   decoration:
                    //       const InputDecoration(labelText: 'Select Room Type'),
                    //   value: _selectedRoomsOption,
                    //   onChanged: (value) =>
                    //       setState(() => _selectedRoomsOption = value),
                    //   validator: (value) =>
                    //       value == null ? 'Please select at least one Room Option' : null,
                    //   items: ['Single', 'Double', 'Triple', 'Quad']
                    //       .map<DropdownMenuItem<String>>((String value) {
                    //     return DropdownMenuItem<String>(
                    //       value: value,
                    //       child: Text(value),
                    //     );
                    //   }).toList(),
                    // ),
                    const SizedBox(height: 15),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor),
                        onPressed: _getCurrentLocation,
                        child: const Text(
                          'Save Current Location',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor),
                        onPressed: () {
                          showFlexibleBottomSheet(
                            isDismissible: false,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            context: context,
                            builder: (BuildContext context,
                                ScrollController scrollController,
                                double bottomSheetOffset) {
                              return OtherLocationScreen(_getSelectedLocation);
                            },
                          );
                        },
                        child: const Text(
                          'Save Other Location',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: !_isEdit
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor),
                              onPressed: () {
                                if (_latitude == null || _longitude == null) {
                                  Fluttertoast.showToast(
                                    msg: "Please select your location!",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                  );
                                }
                                // else if (_selectedRoomTypes.isEmpty){
                                //   Fluttertoast.showToast(
                                //     msg: "Please select at least one room type!",
                                //     toastLength: Toast.LENGTH_LONG,
                                //     gravity: ToastGravity.BOTTOM,
                                //     timeInSecForIosWeb: 1,
                                //   );
                                // }
                                else {
                                  _postAd();
                                }
                              },
                              child: const Text(
                                'Post Ad',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor),
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
                            radius: 25, color: AppColors.primaryColor),
                        const SizedBox(height: 10),
                        Text(loading,
                            style: const TextStyle(
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
