import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hostel_add/resources/values/colors.dart';
import 'package:permission_handler/permission_handler.dart';

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
        if (markers.isNotEmpty) markers.clear();
        markers.add(Marker(
            infoWindow: const InfoWindow(title: 'Existing Location'),
            markerId: const MarkerId('existing-location'),
            position:
                LatLng(double.parse(widget.lat!), double.parse(widget.long!))));
        _moveToLocation(double.parse(widget.lat!), double.parse(widget.long!));
      });
    }
  }

  void _moveToLocation(double lat, double long) async {
    if (mapController != null) {
      await mapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, long), zoom: 15.0)));
    } else {
      // If mapController is null, wait for a short duration and try again
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
      markers.add(Marker(
          infoWindow: const InfoWindow(title: 'New Location'),
          markerId: const MarkerId('selected-location'),
          position: point));
    });
  }

  Future<void> _getCurrentLocation() async {
    await [Permission.location].request();
    bool isLocationPermissionGranted = await Permission.location.isGranted;
    if (isLocationPermissionGranted) {
      final currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      markers.clear();
      check = true;
      setState(() {
        location = LatLng(currentLocation.latitude, currentLocation.longitude);
        markers.add(Marker(
            infoWindow: const InfoWindow(title: 'New Location'),
            markerId: const MarkerId('selected-location'),
            position:
                LatLng(currentLocation.latitude, currentLocation.longitude)));
      });
      _moveToLocation(currentLocation.latitude, currentLocation.longitude);
    } else {
      Fluttertoast.showToast(
          msg: !kIsWeb ? "Please grant Location permission first!" : "Please grant Location permission from browsers settings!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          textColor: Colors.white,
          fontSize: 10.0);
      if(!kIsWeb) {
        openAppSettings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 30,
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: AppColors.primaryColor,
          title: const Text(
              kIsWeb
                  ? 'Tap on your custom location'
                  : 'Long press on map to save location',
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
        body: Column(children: [
          Expanded(
              child: GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  initialCameraPosition: const CameraPosition(
                      target: LatLng(31.582045, 74.329376), zoom: 15),
                  mapType: MapType.terrain,
                  markers: markers,
                  onTap: kIsWeb ? _onMapLongPress : null,
                  onLongPress: _onMapLongPress,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    mapController = controller;
                  })),
          const SizedBox(height: 10),
          Row(children: [
            Flexible(
                fit: FlexFit.tight,
                child: FractionallySizedBox(
                    widthFactor: 1,
                    child: Center(
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor),
                            onPressed: _getCurrentLocation,
                            child: const Text('Go to my Location',
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center))))),
            const SizedBox(width: 10),
            Flexible(
                fit: FlexFit.tight,
                child: FractionallySizedBox(
                    widthFactor: 1,
                    child: Center(
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor),
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
                                    timeInSecForIosWeb: 1);
                              }
                            }))))
          ]),
          const SizedBox(height: 10)
        ]));
  }
}
