import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hostel_add/AdScreens/Post_Edit_Ads_Screen.dart';
import 'package:intl/intl.dart';
import 'package:modern_form_line_awesome_icons/modern_form_line_awesome_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hostel_add/resources/values/colors.dart';

class AdDetailScreen extends StatefulWidget {
  final String adId;

  const AdDetailScreen({super.key, required this.adId});

  @override
  _AdDetailScreenState createState() => _AdDetailScreenState();
}

class _AdDetailScreenState extends State<AdDetailScreen> {
  final _user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isAdOwner = false;
  bool _isFav = false;
  Icon favIcon = const Icon(LineAwesomeIcons.heart, color: Colors.white);
  Icon unFavIcon = const Icon(LineAwesomeIcons.heart_o, color: Colors.white);
  Icon _myIcon = const Icon(LineAwesomeIcons.heart_o, color: Colors.white);
  GoogleMapController? _mapController;
  double? _latitude, _longitude;

  @override
  void initState() {
    super.initState();
    _checkIfUserIsAdOwner();
    _checkIfAdIsFav(); //check if the logged in user has this ad as fav, then turn logo to fav
  }

  Future<void> _checkIfAdIsFav() async {
    final userData = await _firestore.collection('users').doc(_user?.uid).get();
    if (userData.exists || userData.data() != null) {
      List ads = userData.get("fav_ads");
      if (ads.contains(widget.adId)) {
        setState(() {
          _myIcon = favIcon;
          _isFav = true;
        });
      }
    }
  }

  Future<void> _checkIfUserIsAdOwner() async {
    if (_user == null) {
      return; // User is not logged in.
    }

    final adSnapshot =
        await _firestore.collection('ads').doc(widget.adId).get();
    final adData = adSnapshot.data() as Map<String, dynamic>;

    setState(() {
      _isAdOwner = _user?.uid ==
          adData[
              'userId']; // Check if the logged-in user is the owner of the ad.
    });
  }

  Future<void> _unFavoriteAd() async {
    String adToUnFav = widget.adId;
    final userData = await _firestore.collection('users').doc(_user?.uid).get();
    if (userData.exists || userData.data() != null) {
      List favAdsList = userData.get("fav_ads");
      try {
        if (favAdsList.contains(adToUnFav)) {
          var docRef =
              await _firestore.collection('users').doc(_user?.uid).get();

          docRef.reference.update({
            'fav_ads': FieldValue.arrayRemove([adToUnFav])
          });

          Fluttertoast.showToast(
              msg: "Ad Removed from Favorites!",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              textColor: Colors.white,
              fontSize: 10.0);

          setState(() {
            _isFav = false;
            _myIcon = unFavIcon;
          });
        }
      } catch (e) {
        print('Error removing Ad from Favorites: ${e.toString()}');
        Fluttertoast.showToast(
            msg: e.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            textColor: Colors.white,
            fontSize: 10.0);
      }
    }
  }

  Future<void> _favoriteAd() async {
    String adToUnFav = widget.adId;
    final userData = await _firestore.collection('users').doc(_user?.uid).get();
    if (!_isFav) {
      List ads = userData.get("fav_ads");
      try {
        if (!ads.contains(widget.adId)) {
          var docRef =
              await _firestore.collection('users').doc(_user?.uid).get();
          docRef.reference.update({
            'fav_ads': FieldValue.arrayUnion([adToUnFav])
          });

          Fluttertoast.showToast(
              msg: "Added to Favorites!",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              textColor: Colors.white,
              fontSize: 10.0);

          setState(() {
            _isFav = true;
            _myIcon = favIcon;
          });
        }
      } catch (e) {
        print('Error updating document: ${e.toString()}');
        Fluttertoast.showToast(
            msg: e.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            textColor: Colors.white,
            fontSize: 10.0);
      }
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    Uri url = Uri(scheme: "tel", path: phoneNumber);
    if (!await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print("Can't open dial pad.");
    }
  }

  void _showAlertDialog(BuildContext context, String phoneNumber) {
    Widget noButton = TextButton(
      child: const Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget yesButton = TextButton(
      child: const Text("Yes"),
      onPressed: () {
        _makePhoneCall(phoneNumber);
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Call"),
      content:
          Text("Would you like to call the following number: $phoneNumber"),
      actions: [
        noButton,
        yesButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // void _showImageDialog(BuildContext context, List imageUrls) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
  //         child: Stack(
  //           children: [
  //             SizedBox(
  //               width: MediaQuery.of(context).size.width * 0.8,
  //               height: MediaQuery.of(context).size.height * 0.8,
  //               child: Container(
  //                 margin: const EdgeInsets.all(5.0),
  //                 child: PageView.builder(
  //                   itemCount: imageUrls.length,
  //                   itemBuilder: (context, index) {
  //                     return Center(
  //                       child: Stack(
  //                         children: [
  //                           CachedNetworkImage(
  //                             imageUrl: imageUrls[index],
  //                             placeholder: (context, url) => const Center(
  //                                 child: CircularProgressIndicator()),
  //                             errorWidget: (context, url, error) =>
  //                                 const Icon(Icons.error),
  //                             fit: BoxFit.cover,
  //                           ),
  //                           Container(
  //                             padding: const EdgeInsets.all(8),
  //                             color: Colors.black.withOpacity(0.7),
  //                             child: Text(
  //                               '${index + 1}/${imageUrls.length}',
  //                               style: const TextStyle(
  //                                 color: Colors.white,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ),
  //             Positioned(
  //               top: 8,
  //               right: 8,
  //               child: GestureDetector(
  //                 onTap: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: const CircleAvatar(
  //                   backgroundColor: Colors.white,
  //                   radius: 16,
  //                   child: Icon(
  //                     Icons.close,
  //                     color: Colors.black,
  //                     size: 20,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // void _showImageDialog(BuildContext context, List<dynamic> imageUrls) {
  //   int currentPage = 0;
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
  //         child: Stack(
  //           children: [
  //             SizedBox(
  //               width: MediaQuery.of(context).size.width * 0.8,
  //               height: MediaQuery.of(context).size.height * 0.8,
  //               child: Container(
  //                 margin: const EdgeInsets.all(5.0),
  //                 child: PageView.builder(
  //                   itemCount: imageUrls.length,
  //                   onPageChanged: (index) {
  //                     currentPage = index;
  //                   },
  //                   itemBuilder: (context, index) {
  //                     return Center(
  //                       child: Stack(
  //                         children: [
  //                           CachedNetworkImage(
  //                             imageUrl: imageUrls[index],
  //                             placeholder: (context, url) => const Center(
  //                               child: CircularProgressIndicator(),
  //                             ),
  //                             errorWidget: (context, url, error) =>
  //                             const Icon(Icons.error),
  //                             fit: BoxFit.cover,
  //                           ),
  //                           Container(
  //                             padding: const EdgeInsets.all(8),
  //                             color: Colors.black.withOpacity(0.7),
  //                             child: Text(
  //                               '${index + 1}/${imageUrls.length}',
  //                               style: const TextStyle(
  //                                 color: Colors.white,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ),
  //             Positioned(
  //               top: 8,
  //               right: 8,
  //               child: GestureDetector(
  //                 onTap: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: const CircleAvatar(
  //                   backgroundColor: Colors.white,
  //                   radius: 16,
  //                   child: Icon(
  //                     Icons.close,
  //                     color: Colors.black,
  //                     size: 20,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             // Row(
  //             //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             //   children: [
  //             //     if (currentPage > 0)
  //             //       IconButton(
  //             //         icon: const Icon(Icons.arrow_back),
  //             //         onPressed: () {
  //             //           setState(() {
  //             //             currentPage--;
  //             //           });
  //             //         },
  //             //       ),
  //             //     if (currentPage < imageUrls.length - 1)
  //             //       IconButton(
  //             //         icon: const Icon(Icons.arrow_forward),
  //             //         onPressed: () {
  //             //           setState(() {
  //             //             currentPage++;
  //             //           });
  //             //         },
  //             //       ),
  //             //   ],
  //             // ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  void _showImageDialog(BuildContext context, List<dynamic> imageUrls) {
    int currentPage = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (RawKeyEvent event) {
              if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                if (currentPage > 0) {
                  setState(() {
                    currentPage--;
                  });
                }
              } else if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowRight) {
                if (currentPage < imageUrls.length - 1) {
                  setState(() {
                    currentPage++;
                  });
                }
              }
            },
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Stack(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: PageView.builder(
                      itemCount: imageUrls.length,
                      controller: PageController(initialPage: currentPage),
                      onPageChanged: (index) {
                        currentPage = index;
                      },
                      itemBuilder: (context, index) {
                        return Center(
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: imageUrls[index],
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                                fit: BoxFit.cover,
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                color: Colors.black.withOpacity(0.7),
                                child: Text(
                                  '${index + 1}/${imageUrls.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 16,
                      child: Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // void _showImageDialog(BuildContext context, List<dynamic> imageUrls) {
  //   int currentPage = 0;
  //   GlobalKey _dialogKey = GlobalKey();
  //
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         key: _dialogKey,
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
  //         child: GestureDetector(
  //           onTap: () {
  //             Navigator.of(context).pop();
  //           },
  //           child: RawKeyboardListener(
  //             focusNode: FocusNode(),
  //             autofocus: true,
  //             onKey: (RawKeyEvent event) {
  //               if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
  //                 if (currentPage > 0) {
  //                   currentPage--;
  //                 }
  //               } else if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowRight) {
  //                 if (currentPage < imageUrls.length - 1) {
  //                   currentPage++;
  //                 }
  //               }
  //
  //               // Update the dialog content based on currentPage
  //               setState(() {});
  //             },
  //             child: Stack(
  //               children: [
  //                 SizedBox(
  //                   width: MediaQuery.of(context).size.width * 0.8,
  //                   height: MediaQuery.of(context).size.height * 0.8,
  //                   child: PageView.builder(
  //                     itemCount: imageUrls.length,
  //                     controller: PageController(initialPage: currentPage),
  //                     onPageChanged: (index) {
  //                       currentPage = index;
  //                     },
  //                     itemBuilder: (context, index) {
  //                       return Center(
  //                         child: Stack(
  //                           children: [
  //                                 SizedBox(
  //                                         width: MediaQuery.of(context).size.width * 0.8,
  //                                         height: MediaQuery.of(context).size.height * 0.8,
  //                                         child: Container(
  //                                           margin: const EdgeInsets.all(5.0),
  //                                           child: PageView.builder(
  //                                             itemCount: imageUrls.length,
  //                                             itemBuilder: (context, index) {
  //                                               return Center(
  //                                                 child: Stack(
  //                                                   children: [
  //                                                     CachedNetworkImage(
  //                                                       imageUrl: imageUrls[index],
  //                                                       placeholder: (context, url) => const Center(
  //                                                           child: CircularProgressIndicator()),
  //                                                       errorWidget: (context, url, error) =>
  //                                                           const Icon(Icons.error),
  //                                                       fit: BoxFit.cover,
  //                                                     ),
  //                                                     Container(
  //                                                       padding: const EdgeInsets.all(8),
  //                                                       color: Colors.black.withOpacity(0.7),
  //                                                       child: Text(
  //                                                         '${index + 1}/${imageUrls.length}',
  //                                                         style: const TextStyle(
  //                                                           color: Colors.white,
  //                                                           fontWeight: FontWeight.bold,
  //                                                         ),
  //                                                       ),
  //                                                     ),
  //                                                   ],
  //                                                 ),
  //                                               );
  //                                             },
  //                                           ),
  //                                         ),
  //                                       ),                            ],
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                 ),
  //                 Positioned(
  //                   top: 8,
  //                   right: 8,
  //                   child: const CircleAvatar(
  //                     backgroundColor: Colors.white,
  //                     radius: 16,
  //                     child: Icon(
  //                       Icons.close,
  //                       color: Colors.black,
  //                       size: 20,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }


  void _updateCameraPosition() {
    if (_mapController != null && _latitude != null && _longitude != null) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_latitude!, _longitude!),
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  Widget _buildPhoneLayout() {
    return StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('ads').doc(widget.adId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Ad not found'));
          }

          final adData = snapshot.data!.data() as Map<String, dynamic>;
          _latitude = double.parse(adData['latitude']);
          _longitude = double.parse(adData['longitude']);
          _updateCameraPosition();
          final Timestamp timestamp = adData['timestamp'];
          final List imageUrls = adData['image_urls'] ?? [];
          final phoneNum = adData['phone_number'] as String;
          final fLM1 = adData['FLM1'] as String;
          final fLM2 = adData['FLM2'] as String;
          final fLM3 = adData['FLM3'] as String;
          final roomTypes = adData['room_types'] ?? [];
          final postDate =
          DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
          final Widget imageWidget;

          if (imageUrls.isNotEmpty) {
            imageWidget = SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CachedNetworkImage(
                      placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                      imageUrl: imageUrls[index],
                      errorWidget: (context, url, error) =>
                      const Icon(Icons.error),
                    ),
                  );
                },
              ),
            );
          } else {
            imageWidget = const Icon(Icons.no_photography_outlined,
                size: 80, color: AppColors.primaryColor);
          }

          return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            GestureDetector(
                                child: Center(child: imageWidget),
                                onTap: () => imageUrls.isNotEmpty
                                    ? _showImageDialog(context, imageUrls)
                                    : null),
                            const SizedBox(height: 10),
                            Center(
                                child: Text(
                                  adData['hostel_name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
                                  textAlign: TextAlign.center,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                )),
                            const SizedBox(height: 10),
                            Text(
                              adData['area'] != ""
                                  ? '${adData['address']}, ${adData['area']}, ${adData['city']}'
                                  : '${adData['address']}, ${adData['city']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text('Rs ${adData['price']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const Text(" / Month")
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('About this hostel ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                Text(
                                  '${adData['description']}',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (fLM1 != "" || fLM2 != "" || fLM3 != "")
                      Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                    'Famous Landmarks near this hostel',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                if (fLM1 != "") Text('${adData['FLM1']}'),
                                if (fLM2 != "") Text('${adData['FLM2']}'),
                                if (fLM3 != "") Text('${adData['FLM3']}'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (fLM1 != "" || fLM2 != "" || fLM3 != "")
                      const SizedBox(height: 10),
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            const Center(
                                child: Text(
                                  "Amenities",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                )),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Text('Internet: ',
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight.bold)),
                                        Text('${adData['Internet']}'),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Text('Parking: ',
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight.bold)),
                                        Text('${adData['Parking']}'),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Text('Gender: ',
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight.bold)),
                                        Text('${adData['gender']}'),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Text('UPS: ',
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight.bold)),
                                        Text('${adData['UPS']}'),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Text('Air Conditioning: ',
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight.bold)),
                                        Text('${adData['AC']}'),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Available Room Types',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                const SizedBox(height: 5),
                                Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      if (roomTypes.contains('Single'))
                                        Container(
                                          margin:
                                          const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: adData['gender'] ==
                                                    'Boys Hostel'
                                                    ? CupertinoColors
                                                    .activeBlue
                                                    : CupertinoColors
                                                    .systemPink,
                                                width: 2),
                                            borderRadius:
                                            BorderRadius.circular(5),
                                          ),
                                          child: const Text('SINGLE',
                                              textAlign: TextAlign.center,
                                              style:
                                              TextStyle(fontSize: 13)),
                                        ),
                                      if (roomTypes.contains('Double'))
                                        Container(
                                          margin:
                                          const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: adData['gender'] ==
                                                    'Boys Hostel'
                                                    ? CupertinoColors
                                                    .activeBlue
                                                    : CupertinoColors
                                                    .systemPink,
                                                width: 2),
                                            borderRadius:
                                            BorderRadius.circular(5),
                                          ),
                                          child: const Text('DOUBLE',
                                              textAlign: TextAlign.center,
                                              semanticsLabel: "hello",
                                              style:
                                              TextStyle(fontSize: 13)),
                                        ),
                                      if (roomTypes.contains('Triple'))
                                        Container(
                                          margin:
                                          const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: adData['gender'] ==
                                                    'Boys Hostel'
                                                    ? CupertinoColors
                                                    .activeBlue
                                                    : CupertinoColors
                                                    .systemPink,
                                                width: 2),
                                            borderRadius:
                                            BorderRadius.circular(5),
                                          ),
                                          child: const Text('TRIPLE',
                                              textAlign: TextAlign.center,
                                              style:
                                              TextStyle(fontSize: 13)),
                                        ),
                                      if (roomTypes.contains('Quad'))
                                        Container(
                                          margin:
                                          const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: adData['gender'] ==
                                                    'Boys Hostel'
                                                    ? CupertinoColors
                                                    .activeBlue
                                                    : CupertinoColors
                                                    .systemPink,
                                                width: 2),
                                            borderRadius:
                                            BorderRadius.circular(5),
                                          ),
                                          child: const Text('QUAD',
                                              textAlign: TextAlign.center,
                                              style:
                                              TextStyle(fontSize: 13)),
                                        )
                                    ])
                              ],
                            )),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            "Tap on red marker to show options",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Container(
                            padding: const EdgeInsets.all(15),
                            height: 300,
                            child: GoogleMap(
                              zoomControlsEnabled: false,
                              mapType: MapType.terrain,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(_latitude!, _longitude!),
                                zoom: 15.0,
                              ),
                              markers: {
                                Marker(
                                  markerId:
                                  const MarkerId('hostel_location'),
                                  position: LatLng(_latitude!, _longitude!),
                                  infoWindow: InfoWindow(
                                    title: '${adData["hostel_name"]}',
                                  ),
                                ),
                              },
                              onMapCreated:
                                  (GoogleMapController controller) {
                                _mapController = controller;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 3,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            const Center(
                                child: Text(
                                  "Contact Info",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                )),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Text('Owner Name: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text('${adData['owner']}'),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text('Phone Number: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                TextButton(
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.blue,
                                        padding: const EdgeInsets.all(0)),
                                    onPressed: () => _showAlertDialog(
                                        context, phoneNum),
                                    child: Text(
                                      adData['phone_number'],
                                      textAlign: TextAlign.start,
                                    )),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Ad Posted on: ${DateFormat('MMM d, y HH:mm').format(postDate)}',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ]));
        });
  }

  Widget _buildTabletAndWebLayout(double width) {
    return StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('ads').doc(widget.adId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Ad not found'));
          }

          final adData = snapshot.data!.data() as Map<String, dynamic>;
          _latitude = double.parse(adData['latitude']);
          _longitude = double.parse(adData['longitude']);
          _updateCameraPosition();
          final Timestamp timestamp = adData['timestamp'];
          final List imageUrls = adData['image_urls'] ?? [];
          final phoneNum = adData['phone_number'] as String;
          final fLM1 = adData['FLM1'] as String;
          final fLM2 = adData['FLM2'] as String;
          final fLM3 = adData['FLM3'] as String;
          final roomTypes = adData['room_types'] ?? [];
          final postDate =
          DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
          final Widget imageWidget;

          if (imageUrls.isNotEmpty) {
            imageWidget = SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CachedNetworkImage(
                      placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                      imageUrl: imageUrls[index],
                      errorWidget: (context, url, error) =>
                      const Icon(Icons.error),
                    ),
                  );
                },
              ),
            );
          } else {
            imageWidget = const Icon(Icons.no_photography_outlined,
                size: 80, color: AppColors.primaryColor);
          }

          return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Container(
                  width: width/2,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              children: [
                                GestureDetector(
                                    child: Center(child: imageWidget),
                                    onTap: () => imageUrls.isNotEmpty
                                        ? _showImageDialog(context, imageUrls)
                                        : null),
                                const SizedBox(height: 10),
                                Center(
                                    child: Text(
                                      adData['hostel_name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25),
                                      textAlign: TextAlign.center,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                const SizedBox(height: 10),
                                Text(
                                  adData['area'] != ""
                                      ? '${adData['address']}, ${adData['area']}, ${adData['city']}'
                                      : '${adData['address']}, ${adData['city']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text('Rs ${adData['price']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const Text(" / Month")
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('About this hostel ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    Text(
                                      '${adData['description']}',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                )),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (fLM1 != "" || fLM2 != "" || fLM3 != "")
                          Card(
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                        'Famous Landmarks near this hostel',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    if (fLM1 != "") Text('${adData['FLM1']}'),
                                    if (fLM2 != "") Text('${adData['FLM2']}'),
                                    if (fLM3 != "") Text('${adData['FLM3']}'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (fLM1 != "" || fLM2 != "" || fLM3 != "")
                          const SizedBox(height: 10),
                        Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                const Center(
                                    child: Text(
                                      "Amenities",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    )),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Text('Internet: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                    FontWeight.bold)),
                                            Text('${adData['Internet']}'),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Text('Parking: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                    FontWeight.bold)),
                                            Text('${adData['Parking']}'),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Text('Gender: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                    FontWeight.bold)),
                                            Text('${adData['gender']}'),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Text('UPS: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                    FontWeight.bold)),
                                            Text('${adData['UPS']}'),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Text('Air Conditioning: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                    FontWeight.bold)),
                                            Text('${adData['AC']}'),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Available Room Types',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    const SizedBox(height: 5),
                                    Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          if (roomTypes.contains('Single'))
                                            Container(
                                              margin:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: adData['gender'] ==
                                                        'Boys Hostel'
                                                        ? CupertinoColors
                                                        .activeBlue
                                                        : CupertinoColors
                                                        .systemPink,
                                                    width: 2),
                                                borderRadius:
                                                BorderRadius.circular(5),
                                              ),
                                              child: const Text('SINGLE',
                                                  textAlign: TextAlign.center,
                                                  style:
                                                  TextStyle(fontSize: 13)),
                                            ),
                                          if (roomTypes.contains('Double'))
                                            Container(
                                              margin:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: adData['gender'] ==
                                                        'Boys Hostel'
                                                        ? CupertinoColors
                                                        .activeBlue
                                                        : CupertinoColors
                                                        .systemPink,
                                                    width: 2),
                                                borderRadius:
                                                BorderRadius.circular(5),
                                              ),
                                              child: const Text('DOUBLE',
                                                  textAlign: TextAlign.center,
                                                  semanticsLabel: "hello",
                                                  style:
                                                  TextStyle(fontSize: 13)),
                                            ),
                                          if (roomTypes.contains('Triple'))
                                            Container(
                                              margin:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: adData['gender'] ==
                                                        'Boys Hostel'
                                                        ? CupertinoColors
                                                        .activeBlue
                                                        : CupertinoColors
                                                        .systemPink,
                                                    width: 2),
                                                borderRadius:
                                                BorderRadius.circular(5),
                                              ),
                                              child: const Text('TRIPLE',
                                                  textAlign: TextAlign.center,
                                                  style:
                                                  TextStyle(fontSize: 13)),
                                            ),
                                          if (roomTypes.contains('Quad'))
                                            Container(
                                              margin:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: adData['gender'] ==
                                                        'Boys Hostel'
                                                        ? CupertinoColors
                                                        .activeBlue
                                                        : CupertinoColors
                                                        .systemPink,
                                                    width: 2),
                                                borderRadius:
                                                BorderRadius.circular(5),
                                              ),
                                              child: const Text('QUAD',
                                                  textAlign: TextAlign.center,
                                                  style:
                                                  TextStyle(fontSize: 13)),
                                            )
                                        ])
                                  ],
                                )),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              const Text(
                                "Tap on red marker to show options",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Container(
                                padding: const EdgeInsets.all(15),
                                height: 300,
                                child: GoogleMap(
                                  zoomControlsEnabled: false,
                                  mapType: MapType.terrain,
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(_latitude!, _longitude!),
                                    zoom: 15.0,
                                  ),
                                  markers: {
                                    Marker(
                                      markerId:
                                      const MarkerId('hostel_location'),
                                      position: LatLng(_latitude!, _longitude!),
                                      infoWindow: InfoWindow(
                                        title: '${adData["hostel_name"]}',
                                      ),
                                    ),
                                  },
                                  onMapCreated:
                                      (GoogleMapController controller) {
                                    _mapController = controller;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 3,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                const Center(
                                    child: Text(
                                      "Contact Info",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    )),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Text('Owner Name: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text('${adData['owner']}'),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text('Phone Number: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextButton(
                                        style: TextButton.styleFrom(
                                            foregroundColor: Colors.blue,
                                            padding: const EdgeInsets.all(0)),
                                        onPressed: () => _showAlertDialog(
                                            context, phoneNum),
                                        child: Text(
                                          adData['phone_number'],
                                          textAlign: TextAlign.start,
                                        )),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Ad Posted on: ${DateFormat('MMM d, y HH:mm').format(postDate)}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      ]),
                ),
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: AppColors.primaryColor,
            title: const Text('Ad Details',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              if (_isAdOwner) // Conditionally show the "Edit" button if the logged-in user is the owner of the ad.
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PostEditAdScreen(adId: widget.adId),
                      ),
                    );
                  },
                ),
              IconButton(
                icon: _myIcon,
                onPressed: () {
                  if (_isFav) {
                    _unFavoriteAd();
                  } else {
                    _favoriteAd();
                  }
                },
              ),
              const SizedBox(width: 10)
            ]),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth < 600) {
              // For smaller screens (phones)
              return _buildPhoneLayout();
            } else {
              // For larger screens (tablets, web)
              return _buildTabletAndWebLayout(constraints.maxWidth);
            }
          },
        ));
  }
}
