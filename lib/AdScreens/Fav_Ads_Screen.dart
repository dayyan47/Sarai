import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hostel_add/resources/values/colors.dart';
import '../Widgets/Ad_Home_Screen_Widget.dart';

class FavAdsScreen extends StatefulWidget {
  const FavAdsScreen({super.key});

  @override
  State<FavAdsScreen> createState() => _FavAdsScreenState();
}

class _FavAdsScreenState extends State<FavAdsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  Future<void> _removeDeletedAdsFromFavAds(List ads) async {
    final currentUserData =
        await _firestore.collection('users').doc(_user?.uid).get();
    if (ads.isNotEmpty) {
      for (var ad in ads) {
        DocumentSnapshot<Map<String, dynamic>> newAd =
            await _firestore.collection('ads').doc(ad).get();
        if (!newAd.exists) {
          currentUserData.reference.update({
            'fav_ads': FieldValue.arrayRemove([ad])
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
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
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Center(
                            child: Text('User have no Favorite Ads.'),
                          );
                        }

                        final List ads = snapshot.data!.get("fav_ads");
                        _removeDeletedAdsFromFavAds(ads); // to unFav ads that were deleted by users

                        if (ads.isNotEmpty) {
                          return StreamBuilder<QuerySnapshot>(
                              stream: _firestore
                                  .collection('ads')
                                  .where(FieldPath.documentId, whereIn: ads)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                List favoriteAds = [];
                                if (!snapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: Text('You have no Favorite Ads.'),
                                  );
                                }
                                if (snapshot.data != null) {
                                  favoriteAds = snapshot.data!.docs;
                                  favoriteAds.sort((a, b) {
                                    Timestamp timestampA = a['timestamp'];
                                    Timestamp timestampB = b['timestamp'];
                                    return timestampB.compareTo(timestampA);
                                  });
                                }
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
                        } else {
                          return const Center(
                            child: Text('You have no Favorite Ads.'),
                          );
                        }
                      }))
            ]));
  }
}
