import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SaveLocationScreen extends StatefulWidget {
  @override
  _SaveLocationScreenState createState() => _SaveLocationScreenState();
}

class _SaveLocationScreenState extends State<SaveLocationScreen>{

  Completer<GoogleMapController> _controller = Completer();
  // on below line we have specified camera position
  static final CameraPosition _kGoogle = const CameraPosition(target: LatLng(31.582045, 74.329376), zoom: 15);

  final List<Marker> _markers = <Marker>[ Marker(
      markerId: MarkerId('1'),
      position: LatLng(20.42796133580664, 75.885749655962),
      infoWindow: InfoWindow(
        title: 'My Position',)
  ),];

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value){}).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR"+error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    // Implement your map view here
    return Scaffold(
      appBar: AppBar(
        title: Text('Save Location'),
      ),
      body: GoogleMap(
          zoomControlsEnabled: false,
          initialCameraPosition: _kGoogle,
          markers: Set<Marker>.of(_markers),
          mapType: MapType.terrain,
          onMapCreated: (GoogleMapController controller){
            _controller.complete(controller);
          }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async{
          getUserCurrentLocation().then((value) async {
            print(value.latitude.toString() +" "+value.longitude.toString());
            // marker added for current users location
            _markers.add( Marker(
              markerId: MarkerId("2"),
              position: LatLng(value.latitude, value.longitude),));

            // specified current users location
            CameraPosition cameraPosition = new CameraPosition(
              target: LatLng(value.latitude, value.longitude),
              zoom: 14,
            );
            final GoogleMapController controller = await _controller.future;
            controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            setState(() {});
          });
        },
        backgroundColor: Color(0xFFFF5A5F),
        label: Text("Save Location"),
        // child: Icon(Icons.location_on_rounded),

      ),
    );
  }
}