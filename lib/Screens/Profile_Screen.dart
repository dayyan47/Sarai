import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hostel_add/AdScreens/Fav_Ads_Screen.dart';
import 'package:hostel_add/AdScreens/My_Ads_Screen.dart';
import 'package:hostel_add/User/Edit_Profile.dart';
import 'package:hostel_add/UserAuth/Login_Screen.dart';
import 'package:modern_form_line_awesome_icons/modern_form_line_awesome_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final userDoc = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid);

  void _logout(BuildContext context, FirebaseAuth auth) async {
    bool isLoggedIn = false;
    try {
      await auth.signOut();

      Fluttertoast.showToast(
          msg: "Log Out Successfully!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          textColor: Colors.white,
          fontSize: 10.0);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', isLoggedIn);
      prefs.remove('isLoggedIn');

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> r) => false);
    } catch (e) {
      print('Error Signing Out: $e');
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          textColor: Colors.white,
          fontSize: 10.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder<DocumentSnapshot>(
        stream: userDoc.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
                child: Text(
                    'User data not found.'));
          }
          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          if (userData == null) {
            return const Center(
                child: Text(
                    'User data is null.'));
          }
          final fullName = userData['full_name'] as String?;
          final email = userData['email'] as String?;
          final profileImageUrl = userData['profile_image_url'] as String?;

          return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: profileImageUrl == ""
                              ? const Icon(Icons.person_sharp,
                                  size: 100, color: Color(0xFFFF5A5F))
                              : Image.network(profileImageUrl!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: const Color(0xFFFF5A5F), width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      ' ${fullName ?? 'N/A'}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: const Color(0xFFFF5A5F), width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(' ${email ?? 'N/A'}',
                        style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EditProfile()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              width: 2, color: Color(0xFFFF5A5F)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Edit Profile',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(color: Colors.black),
                  const SizedBox(height: 10),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      side:
                          const BorderSide(width: 2, color: Color(0xFFFF5A5F)),
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
                        color: const Color(0xFFFF5A5F),
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
                        color: const Color(0xFFFF5A5F),
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
                      side:
                          const BorderSide(width: 2, color: Color(0xFFFF5A5F)),
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
                        color: const Color(0xFFFF5A5F),
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
                        color: const Color(0xFFFF5A5F),
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
                      side:
                          const BorderSide(width: 2, color: Color(0xFFFF5A5F)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onTap: () => _logout(context, auth),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: const Color(0xFFFF5A5F),
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
                        color: const Color(0xFFFF5A5F),
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
