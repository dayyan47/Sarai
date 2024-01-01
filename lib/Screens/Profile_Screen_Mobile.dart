import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostel_add/AdScreens/Fav_Ads_Screen.dart';
import 'package:hostel_add/AdScreens/My_Ads_Screen.dart';
import 'package:hostel_add/Screens/Profile_Screen.dart';
import 'package:hostel_add/User/Edit_Profile.dart';
import 'package:hostel_add/resources/values/colors.dart';
import 'package:modern_form_line_awesome_icons/modern_form_line_awesome_icons.dart';

class ProfileScreenMobile extends StatefulWidget {
  const ProfileScreenMobile({super.key});

  @override
  State<ProfileScreenMobile> createState() => _ProfileScreenMobileState();
}

class _ProfileScreenMobileState extends State<ProfileScreenMobile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ProfileScreenState mainClass = ProfileScreenState();

  @override
  Widget build(BuildContext context) {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser?.uid);
    return SingleChildScrollView(
      child: StreamBuilder<DocumentSnapshot>(
        stream: userDoc.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('User data not found.'));
          }
          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          if (userData == null) {
            mainClass.deleteUser(_auth.currentUser);
            return Center(
                child: Column(
                  children: [
                    const Text('User data is null.'),
                    TextButton(
                        onPressed: () => mainClass.logout(context, _auth),
                        child: const Text("Logout"))
                  ],
                ));
          }
          final fullName = userData['full_name'] as String;
          final email = userData['email'] as String;
          final profileImageUrl = userData['profile_image_url'] as String;

          return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Card(
                      elevation: 10,
                      color: Colors.white,
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(40.0, 20.0, 40.0, 20.0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: profileImageUrl == ""
                                    ? const Icon(Icons.person_sharp,
                                        size: 100,
                                        color: AppColors.primaryColor)
                                    : CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        imageUrl: profileImageUrl,
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.primaryColor, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                fullName,
                                textAlign: TextAlign.center,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.primaryColor, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(email,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const EditProfile()));
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        width: 2,
                                        color: AppColors.primaryColor),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text('Edit Profile',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                              ),
                            )
                          ],
                        ),
                      )),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.black),
                  const SizedBox(height: 10),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          width: 2, color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyAdsScreen()));
                    },
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: AppColors.primaryColor,
                      ),
                      child: const Icon(
                        LineAwesomeIcons.bookmark,
                        color: Colors.black,
                      ),
                    ),
                    title: Text(
                      'My Ads',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.apply(color: Colors.black),
                    ),
                    trailing: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: AppColors.primaryColor,
                      ),
                      child: const Icon(
                        LineAwesomeIcons.angle_right,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          width: 2, color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FavAdsScreen()));
                    },
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: AppColors.primaryColor,
                      ),
                      child: const Icon(
                        LineAwesomeIcons.heart_o,
                        color: Colors.black,
                      ),
                    ),
                    title: Text(
                      'Favorite Ads',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.apply(color: Colors.black),
                    ),
                    trailing: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: AppColors.primaryColor,
                      ),
                      child: const Icon(
                        LineAwesomeIcons.angle_right,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          width: 2, color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onTap: () => mainClass.launchWhatsapp(),
                    leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: AppColors.primaryColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Image.asset('assets/WhatsAppLogoBlack.png'),
                        )),
                    title: Text(
                      'Contact Support',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.apply(color: Colors.black),
                    ),
                    trailing: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: AppColors.primaryColor,
                      ),
                      child: const Icon(
                        LineAwesomeIcons.angle_right,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          width: 2, color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onTap: () => mainClass.showAlertDialog(context, _auth),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: AppColors.primaryColor,
                      ),
                      child: const Icon(
                        LineAwesomeIcons.sign_out,
                        color: Colors.black,
                      ),
                    ),
                    title: Text(
                      'Logout',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.apply(color: Colors.black),
                    ),
                    trailing: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: AppColors.primaryColor,
                      ),
                      child: const Icon(
                        LineAwesomeIcons.angle_right,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.black),
                ],
              ));
        },
      ),
    );
  }
}
