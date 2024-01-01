import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hostel_add/resources/values/colors.dart';
import 'package:permission_handler/permission_handler.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  _MapViewScreenState createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  GoogleMapController? _controller;
  static const CameraPosition _kGoogle =
      CameraPosition(target: LatLng(31.582045, 74.329376), zoom: 10);
  Set<Marker> markers = {};

  Set<Marker> _buildMarkers(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> allAds) {
    for (QueryDocumentSnapshot document in allAds) {
      double latitude = double.parse(document.get('latitude'));
      double longitude = double.parse(document.get('longitude'));
      String adName = document.get('hostel_name');
      String adId = document.id;
      markers.add(
        Marker(
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
          ),
        ),
      );
    }
    return markers;
  }

  Future<void> _getCurrentLocation() async {
    await [Permission.location].request();
    bool isLocationPermissionGranted = await Permission.location.isGranted;
    if (isLocationPermissionGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        // Animate the map to the user's current position

        if (_controller != null) {
          setState(() {
            _controller!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 15.0,
                ),
              ),
            );
          });


          setState(() {
            markers.add(
              Marker(
                markerId: MarkerId('UserLocation'),
                position: LatLng(position.latitude, position.longitude),
                // Add more marker properties as needed
              ),
            );
          });
        }
      } catch (e) {
        print('Error getting current location: $e');
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: fireStore.collection('ads').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final allAds = snapshot.data!.docs;
          markers = _buildMarkers(allAds);
          return Stack(
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: GoogleMap(
                    padding: const EdgeInsets.only(top: 30.0),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                    initialCameraPosition: _kGoogle,
                    markers: markers,
                    mapType: MapType.terrain,
                    onMapCreated: (GoogleMapController controller) {
                      _controller = controller;
                    },
                  )),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                      margin: const EdgeInsets.all(20.0),
                      color: Colors.white.withOpacity(0.7),
                      child: const Text(
                        " Tap on red marker to show options ",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      )),
                ),
              ),
              Positioned(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ElevatedButton(
                      onPressed: () async { await _getCurrentLocation();},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor),
                      child: const Text("Current Location",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }
}
