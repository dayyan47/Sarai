import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  _MapViewScreenState createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  Future<List<DocumentSnapshot>> getMarkers() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('ads').get();
    return querySnapshot.docs;
  }

  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _kGoogle =
      CameraPosition(target: LatLng(31.582045, 74.329376), zoom: 15);

  final List<Marker> _markers = <Marker>[
    const Marker(
        markerId: MarkerId('1'),
        position: LatLng(31.582045, 74.329376),
        infoWindow: InfoWindow(
          title: 'My Position',
        )),
  ];

   getUserCurrentLocation() async {
    // await Geolocator.requestPermission()
    //     .then((value) {})
    //     .onError((error, stackTrace) async {
    //   await Geolocator.requestPermission();
    //   print("ERROR$error");
    // });
    bool isLocationPermissionGranted = await Permission.location.isGranted;
    if(isLocationPermissionGranted) {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    }
    else{
      Fluttertoast.showToast(
          msg: "Please grant Location permission first!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          textColor: Colors.white,
          fontSize: 10.0);
      openAppSettings();
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            GoogleMap(
              zoomControlsEnabled: false,
              initialCameraPosition: _kGoogle,
              markers: Set<Marker>.of(_markers),
              mapType: MapType.terrain,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              //onLongPress: addMarker(), // to do
            ),
            Positioned(
              bottom: 15.0, // Places the FAB on top of the bottom app bar
              right: 20.0,
              child: FloatingActionButton.extended(
                backgroundColor: const Color(0xFFFF5A5F),
                label: const Row(children: [
                  Text("Current Location",
                      style: TextStyle(color: Colors.white)),
                  SizedBox(width: 4.0),
                  Icon(Icons.location_on, color: Colors.white)
                ]),
                onPressed: () async {
                  getUserCurrentLocation().then((value) async {
                    print("${value.latitude} ${value.longitude}");
                    // marker added for current users location
                    _markers.add(Marker(
                      markerId: const MarkerId("2"),
                      position: LatLng(value.latitude, value.longitude),
                    ));

                    // specified current users location
                    CameraPosition cameraPosition = CameraPosition(
                      target: LatLng(value.latitude, value.longitude),
                      zoom: 14,
                    );

                    final GoogleMapController controller =
                        await _controller.future;
                    controller.animateCamera(
                        CameraUpdate.newCameraPosition(cameraPosition));
                    setState(() {});
                  });
                },
              ),
            )
          ],
        ));
  }
}
