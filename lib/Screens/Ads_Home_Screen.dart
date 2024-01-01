import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Widgets/Ad_Home_Screen_Widget.dart';

class AdsScreen extends StatefulWidget {
  const AdsScreen({super.key});

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('ads')
          .orderBy("timestamp", descending: true)
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

            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth < 600) {
                  // For smaller screens (phones)
                  return AdHomeScreen(adData: adData, adId: adId);
                } else {
                  // For larger screens (tablets, web)
                  return Center(
                      child: Container(
                          width: constraints.maxWidth / 2,
                          child: AdHomeScreen(adData: adData, adId: adId)));
                }
              },
            );
          },
        );
      },
    );
  }
}