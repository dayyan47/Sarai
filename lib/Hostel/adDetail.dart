import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hostel_add/Hostel/hostel_room_Detail.dart';

class RoomDetail extends StatefulWidget {
  final String adId;

  RoomDetail({required this.adId});

  @override
  _RoomDetailState createState() => _RoomDetailState();
}

class _RoomDetailState extends State<RoomDetail> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isAdOwner = false;

  @override
  void initState() {
    super.initState();
    _checkIfUserIsAdOwner();
  }

  Future<void> _checkIfUserIsAdOwner() async {
    final user = _auth.currentUser;
    if (user == null) {
      // User is not logged in.
      return;
    }

    final adSnapshot = await FirebaseFirestore.instance
        .collection('ads')
        .doc(widget.adId)
        .get();
    final adData = adSnapshot.data() as Map<String, dynamic>;

    setState(() {
      // Check if the logged-in user is the owner of the ad.
      _isAdOwner = user.uid == adData['userId'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Detail'),
      // ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ads')
            .doc(widget.adId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading indicator while fetching data.
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Handle error state.
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            // Handle case when ad data doesn't exist.
            return Center(child: Text('Ad not found'));
          }

          final adData = snapshot.data!.data() as Map<String, dynamic>;

          // Calculate image dimensions based on screen size using MediaQuery.
          Size size = MediaQuery.of(context).size;
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = size.height*0.35;
          final imageSize = screenWidth < screenHeight
              ? screenWidth * 0.6
              : screenHeight * 0.6;

          Widget imageWidget;
          if (adData['image_url'] != null) {
            imageWidget = Image.network(
              adData['image_url'],
              height: screenHeight,
              fit: BoxFit.cover,
            );
          } else {
            // Display a "No Image" icon when there's no image URL.
            imageWidget = Icon(Icons.image_not_supported,
                size: imageSize, color: Colors.grey);
          }

          return Scaffold(
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Column(
                  children: [
                    Stack(
                      children: [imageWidget],
                    ),
                    HostelRoomDetail(adData: adData),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
