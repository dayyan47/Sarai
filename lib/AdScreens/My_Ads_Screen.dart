import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostel_add/Widgets/Ad_Home_Screen_Widget.dart';
import 'package:hostel_add/AdScreens/Post_Edit_Ads_Screen.dart';
import 'package:hostel_add/resources/values/colors.dart';

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});

  @override
  _MyAdsScreenState createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text('My Ads',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return StreamBuilder<QuerySnapshot>(
              stream: _fireStore
                  .collection('ads')
                  .where('userId', isEqualTo: _currentUser?.uid)
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
                        const SizedBox(height: 10),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const PostEditAdScreen(
                                            adId: "Post Ad")),
                              );
                            },
                            child: const Text('Start posting your first ad',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)))
                      ]));
                }
                if (snapshot.data != null) {
                  myAds = snapshot.data!.docs;
                  myAds.sort((a, b) {
                    Timestamp timestampA = a['timeStamp'];
                    Timestamp timestampB = b['timeStamp'];
                    return timestampB.compareTo(timestampA);
                  });
                }
                return ListView.builder(
                    itemCount: myAds.length,
                    itemBuilder: (context, index) {
                      final adData =
                          myAds[index].data() as Map<String, dynamic>;
                      final adId = myAds[index].id;
                      return Center(
                          child: SizedBox(
                              width: constraints.maxWidth >= 600
                                  ? constraints.maxWidth / 2
                                  : constraints.maxWidth,
                              child: AdHomeScreen(adData: adData, adId: adId)));
                    });
              });
        }));
  }
}
