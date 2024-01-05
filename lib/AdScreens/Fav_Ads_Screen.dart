import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hostel_add/Widgets/Ad_Home_Screen_Widget.dart';
import 'package:hostel_add/resources/values/colors.dart';

class FavAdsScreen extends StatefulWidget {
  const FavAdsScreen({super.key});

  @override
  State<FavAdsScreen> createState() => _FavAdsScreenState();
}

class _FavAdsScreenState extends State<FavAdsScreen> {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  Future<void> _removeDeletedAdsFromFavAds(List ads) async {
    final currentUserData =
        await _fireStore.collection('users').doc(_user?.uid).get();
    if (ads.isNotEmpty) {
      for (var ad in ads) {
        DocumentSnapshot<Map<String, dynamic>> newAd =
            await _fireStore.collection('ads').doc(ad).get();
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
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return StreamBuilder(
                stream:
                    _fireStore.collection('users').doc(_user?.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                      child: Text('You have no Favorite Ads.'),
                    );
                  }
                  final List ads = snapshot.data!.get("fav_ads");
                  // to unFav ads that were deleted by owners but are still available in other users fav_ads array!
                  _removeDeletedAdsFromFavAds(ads);
                  if (ads.isNotEmpty) {
                    return StreamBuilder<QuerySnapshot>(
                        stream: _fireStore
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
                              Timestamp timestampA = a['timeStamp'];
                              Timestamp timestampB = b['timeStamp'];
                              return timestampB.compareTo(timestampA);
                            });
                          }
                          return ListView.builder(
                              itemCount: favoriteAds.length,
                              itemBuilder: (context, index) {
                                final adData = favoriteAds[index].data()
                                    as Map<String, dynamic>;
                                final adId = favoriteAds[index].id;
                                return Center(
                                    child: SizedBox(
                                        width: constraints.maxWidth >= 600
                                            ? constraints.maxWidth / 2
                                            : constraints.maxWidth,
                                        child: AdHomeScreen(
                                            adData: adData, adId: adId)));
                              });
                        });
                  } else {
                    return const Center(
                      child: Text('You have no Favorite Ads.'),
                    );
                  }
                });
          },
        ));
  }
}
