import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hostel_add/resources/values/colors.dart';

class OtherLocationScreen extends StatefulWidget {
  final Function(LatLng) onSaveLocation; // Callback Function
  final String? lat, long;

  const OtherLocationScreen(this.onSaveLocation, this.lat, this.long,
      {super.key});

  @override
  _OtherLocationScreenState createState() => _OtherLocationScreenState();
}

class _OtherLocationScreenState extends State<OtherLocationScreen> {
  Set<Marker> markers = <Marker>{};
  GoogleMapController? mapController;
  final Completer<GoogleMapController> _controller = Completer();
  bool check = false;
  LatLng? location;

  @override
  void initState() {
    super.initState();
    if (widget.lat != null && widget.long != null) {
      setState(() {
        //location = widget.initialLocation;
        if (markers.isNotEmpty) markers.clear();
        markers.add(
          Marker(
            infoWindow: const InfoWindow(title: 'Existing Location'),
            markerId: const MarkerId('existing-location'),
            position:
                LatLng(double.parse(widget.lat!), double.parse(widget.long!)),
          ),
        );
        _moveToLocation(double.parse(widget.lat!), double.parse(widget.long!));
      });
    }
  }

  void _moveToLocation(double lat, double long) async {
    if (mapController != null) {
      await mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(lat, long),
            zoom: 15.0,
          ),
        ),
      );
    } else {
      // If mapController is null, wait for a short duration and try again
      // This is to handle the situation when onMapCreated is not called yet
      Future.delayed(const Duration(milliseconds: 500), () {
        _moveToLocation(lat, long); // Retry after a delay
      });
    }
  }

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
        backgroundColor: AppColors.primaryColor,
        title: const Text('Long press on map to save location',
            style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: Stack(
        children: [
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: const CameraPosition(
                target: LatLng(31.582045, 74.329376), zoom: 15),
            mapType: MapType.terrain,
            markers: markers,
            onLongPress: _onMapLongPress,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                        ),
                        child: const Text(
                          "Save this Location",
                          style: TextStyle(color: Colors.white),
                        ),
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
                  ),
                ],
              ),
            ),
          ),
          // Positioned(
          //     bottom: 15.0,
          //     left: 100.0,
          //     child: Center(
          //       child: ElevatedButton(
          //           style: ElevatedButton.styleFrom(
          //               backgroundColor: AppColors.primaryColor),
          //           child: const Text("Save this Location",
          //               style: TextStyle(color: Colors.white)),
          //           onPressed: () {
          //             if (check) {
          //               widget.onSaveLocation(location!);
          //               Navigator.pop(context);
          //             } else {
          //               Fluttertoast.showToast(
          //                 msg: "Please select location first!",
          //                 toastLength: Toast.LENGTH_SHORT,
          //                 gravity: ToastGravity.BOTTOM,
          //                 timeInSecForIosWeb: 1,
          //               );
          //             }
          //           }),
          //     ))
        ],
      ),
    );
  }
}
