import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hostel_add/resources/values/colors.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  _MapViewScreenState createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final CameraPosition _initialCameraPosition =
      const CameraPosition(target: LatLng(31.582045, 74.329376), zoom: 10);
  Set<Marker> markers = {};
  Completer<GoogleMapController> _controllerCompleter = Completer();

  Set<Marker> _buildMarkers(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> allAds) {
    for (QueryDocumentSnapshot document in allAds) {
      double latitude = double.parse(document.get('latitude'));
      double longitude = double.parse(document.get('longitude'));
      String adName = document.get('hostelName');
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
            //onTap: todo set option to open in google maps!
          ),
        ),
      );
    }
    return markers;
  }

  // void _setCurrentLocationMarker(double latitude, double longitude) {
  //   if (mounted) {
  //     setState(() {
  //       markers.add(
  //         Marker(
  //           markerId: const MarkerId('UserLocation'),
  //           position: LatLng(latitude, longitude),
  //           infoWindow: const InfoWindow(
  //             title: 'Your Location',
  //             snippet: 'You are here',
  //           ),
  //           icon:
  //               BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //         ),
  //       );
  //     });
  //   }
  // }

  Future<void> _goToUserLocation() async {
    try {
      bool isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        print('Location service is not enabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          print('Location permission denied');
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('Position: $position');
      GoogleMapController controller = await _controllerCompleter.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16.0,
          ),
        ),
      );

      //_setCurrentLocationMarker(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _fireStore.collection('ads').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final allAds = snapshot.data!.docs;
          markers = _buildMarkers(allAds);
          return Builder(builder: (context) {
            return Stack(children: [
              GoogleMap(
                  padding: const EdgeInsets.only(top: 30.0),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  initialCameraPosition: _initialCameraPosition,
                  markers: markers,
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller) {
                    _controllerCompleter.complete(controller);
                  }),
              Positioned.fill(
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                          margin: const EdgeInsets.all(20.0),
                          color: Colors.white.withOpacity(0.7),
                          child: const Text(
                              " Tap on red marker to show options ",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold))))),
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
                                fontWeight: FontWeight.bold)),
                      )))
            ]);
          });
        });
  }
}
