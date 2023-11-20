import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostel_add/Widgets/Ad_Home_Screen_Widget.dart';
import 'package:hostel_add/AdScreens/Post_Edit_Ads_Screen.dart';

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});

  @override
  _MyAdsScreenState createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  String? fullName;
  String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF5A5F),
        title: const Text('My Ads',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('ads')
                  .where('userId', isEqualTo: currentUser?.uid)
                  //.orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                List myAds = [];

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("You haven't posted any ad yet!"),
                          const SizedBox(height: 15),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF5A5F)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PostEditAdScreen(
                                              adId: "Post Ad")),
                                );
                              },
                              child: const Text('Start Posting your first AD',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)))
                        ]),
                  );
                }
                if (snapshot.data != null) {
                  myAds = snapshot.data!.docs;
                  myAds.sort((a, b) {
                    Timestamp timestampA = a['timestamp'];
                    Timestamp timestampB = b['timestamp'];
                    return timestampB.compareTo(timestampA);
                  });
                }

                return ListView.builder(
                  itemCount: myAds.length,
                  itemBuilder: (context, index) {
                    final adData = myAds[index].data() as Map<String, dynamic>;
                    final adId = myAds[index].id;
                    return AdHomeScreen(adData: adData, adId: adId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
