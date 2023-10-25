import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hostel_add/Ads/Post_Edit_Ads.dart';

class AdDetailScreen extends StatefulWidget {
  final String adId;

  AdDetailScreen({required this.adId});

  @override
  _AdDetailScreenState createState() => _AdDetailScreenState();
}

class _AdDetailScreenState extends State<AdDetailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isAdOwner =
      false; // If the User is logged-in, user is the owner of the ad.

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
      appBar: AppBar(
        backgroundColor: Color(0xFFFF5A5F),
        title: Text('Ad Details',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: Colors.white),
        actions:
            _isAdOwner // Conditionally show the "Edit" button if the logged-in user is the owner of the ad.
                ? [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Navigate to the edit screen when the "Edit" button is pressed.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PostEditAdScreen(adId: widget.adId),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 10)
                  ]
                : null,
      ),
      body: Stack(children: [
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('ads')
              .doc(widget.adId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Loading indicator while fetching data.
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              // Handle error state.
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              // Handle case when ad data doesn't exist.
              return const Center(child: Text('Ad not found'));
            }

            final adData = snapshot.data!.data() as Map<String, dynamic>;

            // Calculate image dimensions based on screen size using MediaQuery.
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final imageSize = MediaQuery.of(context).size;

            // Widget to display the image or "No Image" icon if no image URL.
            Widget imageWidget;
            if (adData['image_url'] != null) {
              final width = imageSize.width;
              final height = imageSize.height;

              imageWidget = SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: Image.network(
                  adData['image_url'],
                  //width: width,
                  //height: height,
                  fit: BoxFit.fitWidth,
                ),
              );
            } else {
              // Display a "No Image" icon when there's no image URL.
              imageWidget = const Icon(Icons.image_not_supported,
                  size: 30, color: Colors.grey);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  imageWidget,
                  // Display ad details here using adData.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Hostel Name:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(' ${adData['hostel_name']}')
                        ],
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Price:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(' ${adData['price']}'),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Phone Number: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${adData['phone_number']}')
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Address:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${adData['address']}')
                        ],
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Province: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${adData['province']}')
                        ],
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'City: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${adData['city']}')
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Gender: ${adData['gender']}'),
                      const SizedBox(
                        width: 10,
                      ),
                      Text('UPS: ${adData['UPS']}'),
                      const SizedBox(
                        width: 10,
                      ),
                      Text('Internet: ${adData['Internet']}'),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rooms: ${adData['Rooms']}'),
                      const SizedBox(
                        width: 10,
                      ),
                      Text('Parking: ${adData['Parking']}'),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Description: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${adData['description']}'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ]),
    );
  }
}
