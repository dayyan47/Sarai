import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  _MapViewScreenState createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGoogle =
      CameraPosition(target: LatLng(31.582045, 74.329376), zoom: 10);
  Set<Marker> markers = {};

  @override
  initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    await [Permission.location].request();
  }

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
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                    initialCameraPosition: _kGoogle,
                    markers: markers,
                    mapType: MapType.terrain,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
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
              )
            ],
          );
        });
  }
}
