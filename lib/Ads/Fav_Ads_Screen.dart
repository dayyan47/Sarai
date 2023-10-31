import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Ad_Home_Screen.dart';

class FavAdsScreen extends StatefulWidget {
  const FavAdsScreen({super.key});

  @override
  State<FavAdsScreen> createState() => _FavAdsScreenState();
}

class _FavAdsScreenState extends State<FavAdsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF5A5F),
          title: const Text('Favorite Ads',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: StreamBuilder(
                      stream: _firestore
                          .collection('users')
                          .doc(_user?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData|| !snapshot.data!.exists) {
                          return const Center(
                            child: Text('You have no Favorite Ads.'), // to do
                          );
                        }

                        final List ads = snapshot.data!.get("fav_ads");
                        if (!ads.isEmpty)
                          return StreamBuilder<QuerySnapshot>(
                              stream: _firestore
                                  .collection('ads')
                                  .where(FieldPath.documentId, whereIn: ads)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: Text('You have no Favorite Ads.'),
                                  );
                                }
                                final favoriteAds = snapshot.data!.docs;
                                return ListView.builder(
                                    itemCount: favoriteAds.length,
                                    itemBuilder: (context, index) {
                                      final adData = favoriteAds[index].data()
                                          as Map<String, dynamic>;
                                      final adId = favoriteAds[index].id;
                                      return AdHomeScreen(
                                          adData: adData, adId: adId);
                                    });
                              });
                        else
                          return const Center(
                            child: Text('You have no Favorite Ads.'), // to do
                          );
                      }))
            ]));
  }
}
