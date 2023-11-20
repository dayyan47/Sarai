import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OtherLocationScreen extends StatefulWidget {
  final Function(LatLng) onSaveLocation; // Callback Function

  const OtherLocationScreen(this.onSaveLocation, {super.key});

  @override
  _OtherLocationScreenState createState() => _OtherLocationScreenState();
}

class _OtherLocationScreenState extends State<OtherLocationScreen> {
  Set<Marker> markers = <Marker>{};
  GoogleMapController? mapController;
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGoogle =
      CameraPosition(target: LatLng(31.582045, 74.329376), zoom: 15);
  bool check = false;
  LatLng? location;

  void _onMapLongPress(LatLng point) {
    check = true;
    setState(() {
      location = point;
      markers.clear();
      markers.add(
        Marker(
          infoWindow: const InfoWindow(title: 'New Location'),
          markerId: const MarkerId('selected-location'),
          position: point,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 30,
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: const Color(0xFFFF5A5F),
        title: const Text('Long press on map to save location',
            style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: Stack(
        children: [
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGoogle,
            mapType: MapType.terrain,
            markers: markers,
            onLongPress: _onMapLongPress,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Positioned(
              bottom: 15.0,
              left: 100.0,
              child: Center(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5A5F)),
                    child: const Text("Save this Location",
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      if (check) {
                        widget.onSaveLocation(location!);
                        Navigator.pop(context);
                      } else {
                        Fluttertoast.showToast(
                          msg: "Please select location first!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                        );
                      }
                    }),
              ))
        ],
      ),
    );
  }
}
