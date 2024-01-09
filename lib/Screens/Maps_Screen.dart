import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hostel_add/resources/values/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  _MapViewScreenState createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  Set<Marker> markers = {};
  GoogleMapController? _controller;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final CameraPosition _initialCameraPosition =
      const CameraPosition(target: LatLng(31.582045, 74.329376), zoom: 10);

  @override
  void initState() {
    super.initState();
    _fireStore.collection('ads').snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          markers = _buildMarkers(snapshot.docs);
        });
      }
    });
  }

  Set<Marker> _buildMarkers(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> allAds) {
    for (QueryDocumentSnapshot document in allAds) {
      double latitude = double.parse(document.get('latitude'));
      double longitude = double.parse(document.get('longitude'));
      String adName = document.get('hostelName');
      String adId = document.id;
      markers.add(Marker(
          markerId: MarkerId(adId),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
              title: adName,
              snippet: document.get('area') != ""
                  ? document.get('address') +
                      ", " +
                      document.get('area') +
                      ", " +
                      document.get('city')
                  : document.get('address') + ", " + document.get('city'),
              onTap: () {
                kIsWeb ? _showAlertDialog(context, latitude, longitude) : null;
              })));
    }
    return markers;
  }

  void _showAlertDialog(
      BuildContext context, double latitude, double longitude) {
    Widget noButton = TextButton(
        child: const Text("No"),
        onPressed: () {
          Navigator.pop(context);
        });

    Widget yesButton = TextButton(
        child: const Text("Yes"),
        onPressed: () async {
          String googleMapsUrl =
              "https://www.google.com/maps/dir/?api=1&origin=current+location&destination=$latitude,$longitude";
          if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
            await launchUrl(Uri.parse(googleMapsUrl));
          } else {
            throw 'Could not launch $googleMapsUrl';
          }
          Navigator.pop(context);
        });

    AlertDialog alert = AlertDialog(
        title: const Text("Open Google Maps"),
        content: const Text("Are you sure you want to open google maps?"),
        actions: [noButton, yesButton]);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void _setCurrentLocationMarker(double latitude, double longitude) {
    setState(() {
      markers.add(Marker(
          markerId: const MarkerId('UserLocation'),
          position: LatLng(latitude, longitude),
          infoWindow:
              const InfoWindow(title: 'Your Location', snippet: 'You are here'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)));
    });
  }

  Future<void> _goToUserLocation() async {
    try {
      await [Permission.location].request();
      bool isLocationPermissionGranted = await Permission.location.isGranted;
      if (isLocationPermissionGranted) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        print('Position: $position');
        _setCurrentLocationMarker(position.latitude, position.longitude);
        _controller!.animateCamera(
            CameraUpdate.newCameraPosition(CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 18.0)));
      }
      else {
        Fluttertoast.showToast(
            msg: !kIsWeb
                ? "Please grant Location permission first!"
                : "Please grant Location permission from browsers settings!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            textColor: Colors.white,
            fontSize: 10.0);
        if (!kIsWeb) {
          openAppSettings();
        }
      }

    } catch (e) {
      print('Error getting current location: $e');

    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Stack(children: [
        GoogleMap(
            padding: const EdgeInsets.only(top: 30.0),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            markers: markers,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            }),
        Positioned.fill(
            child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                    margin: const EdgeInsets.all(20.0),
                    color: Colors.white.withOpacity(0.7),
                    child: const Text(
                        !kIsWeb
                            ? " Tap on red marker to show options "
                            : " Tap on red marker to show info ",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold))))),
        Positioned(
            bottom: 20,
            width: MediaQuery.of(context).size.width,
            child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor),
                    onPressed: _goToUserLocation,
                    child: const Text('Go to My Location',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)))))
      ]);
    });
  }
}
