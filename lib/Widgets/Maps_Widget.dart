import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapViewScreen extends StatefulWidget {
  @override
  _MapViewScreenState createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  Future<List<DocumentSnapshot>> getMarkers() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('ads').get();
    return querySnapshot.docs;
  }

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGoogle =
      const CameraPosition(target: LatLng(31.582045, 74.329376), zoom: 15);

  final List<Marker> _markers = <Marker>[
    Marker(
        markerId: MarkerId('1'),
        position: LatLng(31.582045, 74.329376),
        infoWindow: InfoWindow(
          title: 'My Position',
        )),
  ];

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR" + error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                backgroundColor: Color(0xFFFF5A5F),
                label: Row(children: [
                  Text("Current Location",
                      style: TextStyle(color: Colors.white)),
                  SizedBox(width: 4.0),
                  Icon(Icons.location_on, color: Colors.white)
                ]),
                onPressed: () async {
                  getUserCurrentLocation().then((value) async {
                    print(value.latitude.toString() +
                        " " +
                        value.longitude.toString());
                    // marker added for current users location
                    _markers.add(Marker(
                      markerId: MarkerId("2"),
                      position: LatLng(value.latitude, value.longitude),
                    ));

                    // specified current users location
                    CameraPosition cameraPosition = new CameraPosition(
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
