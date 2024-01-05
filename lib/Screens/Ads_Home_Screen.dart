import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hostel_add/Widgets/Ad_Home_Screen_Widget.dart';

class AdsScreen extends StatefulWidget {
  const AdsScreen({super.key});

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _fireStore
            .collection('ads')
            .orderBy("timeStamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No ads found.'));
          }
          final ads = snapshot.data!.docs;
          return ListView.builder(
              itemCount: ads.length,
              itemBuilder: (context, index) {
                final adData = ads[index].data() as Map<String, dynamic>;
                final adId = ads[index].id;
                return LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  return Center(
                      child: SizedBox(
                          width: constraints.maxWidth >= 600
                              ? constraints.maxWidth / 2
                              : constraints.maxWidth,
                          child: AdHomeScreen(adData: adData, adId: adId)));
                });
              });
        });
  }
}
