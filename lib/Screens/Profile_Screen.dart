import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hostel_add/AdScreens/Fav_Ads_Screen.dart';
import 'package:hostel_add/AdScreens/My_Ads_Screen.dart';
import 'package:hostel_add/User/Edit_Profile.dart';
import 'package:hostel_add/UserAuth/Login_Screen.dart';
import 'package:hostel_add/resources/values/colors.dart';
import 'package:modern_form_line_awesome_icons/modern_form_line_awesome_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DocumentReference? userDoc;
  bool isLoggedIn = true;

  @override
  void initState() {
    super.initState();
    userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser?.uid);
  }

  void _showLogoutDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.pop(context);
              }),
          TextButton(
              child: const Text("Yes"),
              onPressed: () {
                _logout(context);
                Navigator.pop(context);
              })
        ]);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void _launchWhatsapp() async {
    String phoneNumber = '+923032777297';
    String message = 'Hi guys, I need your help!';
    String whatsappUrl = 'https://wa.me/$phoneNumber/?text=$message';
    if (kIsWeb) {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        print("Can't open WhatsApp on web.");
        Fluttertoast.showToast(
            msg: "Can't open WhatsApp on Web",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            textColor: Colors.white,
            fontSize: 10.0);
      }
    } else {
      if (!await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        print("Can't open WhatsApp on Mobile.");
        Fluttertoast.showToast(
            msg: "Can't open WhatsApp on Mobile",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            textColor: Colors.white,
            fontSize: 10.0);
      }
    }
  }

  // void _showContactUsDialogWeb(BuildContext context) {
  //   final Uri whatsApp = kIsWeb
  //       ? Uri.parse('https://wa.me/+923032777297')
  //       : Uri.parse('whatsapp://send?phone=+923032777297');
  //
  //   Widget closeButton = TextButton(
  //     child: const Text("Close"),
  //     onPressed: () {
  //       Navigator.pop(context);
  //     },
  //   );
  //
  //   AlertDialog alert = AlertDialog(
  //     title: const Text("Contact Us"),
  //     content: const Text(
  //         "Please contact us on WhatsApp on the following number: 0303-2777297"),
  //     actions: [closeButton],
  //   );
  //
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }

  void _logout(BuildContext context) async {
    isLoggedIn = false;
    try {
      await _auth.signOut();
      Fluttertoast.showToast(
          msg: "Logged Out Successfully!",
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

  Future<void> _deleteUser(User? currentUser) async {
    try {
      if (currentUser != null) {
        await currentUser.delete();
        Fluttertoast.showToast(
            msg: "Account deleted successfully!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            textColor: Colors.white,
            fontSize: 10.0);

        print("User deleted successfully.");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', false);
        prefs.remove('isLoggedIn');

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> r) => false);
        //To Do: delete all ads of this user too?
      } else {
        print("No user is currently signed in.");
      }
    } catch (e) {
      print("Error deleting user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return SingleChildScrollView(
          child: StreamBuilder<DocumentSnapshot>(
              stream: userDoc!.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('User data not found.'));
                }
                final userData = snapshot.data!.data() as Map<String, dynamic>?;
                if (userData == null) {
                  _deleteUser(_auth.currentUser);
                  return Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).height,
                      padding: const EdgeInsets.all(20),
                      child: Column(children: [
                        const Text('User data is null.'),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor),
                            onPressed: () => _logout(context),
                            child: const Text("Logout",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)))
                      ]));
                }
                final fullName = userData['full_name'] as String;
                final email = userData['email'] as String;
                final profileImageUrl = userData['profile_image_url'] as String;

                return Center(
                    child: Container(
                        width: constraints.maxWidth >= 600
                            ? constraints.maxWidth / 2
                            : constraints.maxWidth,
                        padding: const EdgeInsets.all(20),
                        child: Column(children: [
                          Card(
                              elevation: 10,
                              color: Colors.white,
                              child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      40.0, 20.0, 40.0, 20.0),
                                  child: Column(children: [
                                    SizedBox(
                                        width: 120,
                                        height: 120,
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child: profileImageUrl != ""
                                                ? CachedNetworkImage(
                                                    placeholder: (context,
                                                            url) =>
                                                        const Center(
                                                            child:
                                                                CircularProgressIndicator()),
                                                    imageUrl: profileImageUrl,
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        const Icon(Icons.error))
                                                : const Icon(Icons.person_sharp,
                                                    size: 100,
                                                    color: AppColors
                                                        .primaryColor))),
                                    const SizedBox(height: 10),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: AppColors.primaryColor,
                                                width: 2),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Text(fullName,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall)),
                                    const SizedBox(height: 10),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: AppColors.primaryColor,
                                                width: 2),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Text(email,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall)),
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
                                                      color: AppColors
                                                          .primaryColor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20))),
                                          child: const Text('Edit Profile',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                        ))
                                  ]))),
                          const SizedBox(height: 20),
                          const Divider(color: Colors.black),
                          const SizedBox(height: 10),
                          ListTile(
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 2, color: AppColors.primaryColor),
                                  borderRadius: BorderRadius.circular(20)),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const MyAdsScreen()));
                              },
                              leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: AppColors.primaryColor),
                                  child: const Icon(LineAwesomeIcons.bookmark,
                                      color: Colors.black)),
                              title: Text('My Ads',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.apply(color: Colors.black)),
                              trailing: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: AppColors.primaryColor),
                                  child: const Icon(
                                      LineAwesomeIcons.angle_right,
                                      size: 18,
                                      color: Colors.black))),
                          const SizedBox(height: 5),
                          ListTile(
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 2, color: AppColors.primaryColor),
                                  borderRadius: BorderRadius.circular(20)),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const FavAdsScreen()));
                              },
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: AppColors.primaryColor),
                                child: const Icon(LineAwesomeIcons.heart_o,
                                    color: Colors.black),
                              ),
                              title: Text('Favorite Ads',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.apply(color: Colors.black)),
                              trailing: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: AppColors.primaryColor),
                                  child: const Icon(
                                      LineAwesomeIcons.angle_right,
                                      size: 18,
                                      color: Colors.black))),
                          const SizedBox(height: 5),
                          ListTile(
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 2, color: AppColors.primaryColor),
                                  borderRadius: BorderRadius.circular(20)),
                              onTap: _launchWhatsapp,
                              leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: AppColors.primaryColor),
                                  child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Image.asset(
                                          'assets/WhatsAppLogoBlack.png'))),
                              title: Text('Contact Support',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.apply(color: Colors.black)),
                              trailing: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: AppColors.primaryColor),
                                  child: const Icon(
                                      LineAwesomeIcons.angle_right,
                                      size: 18,
                                      color: Colors.black))),
                          const SizedBox(height: 5),
                          ListTile(
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 2, color: AppColors.primaryColor),
                                  borderRadius: BorderRadius.circular(20)),
                              onTap: () => _showLogoutDialog(context),
                              leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: AppColors.primaryColor),
                                  child: const Icon(LineAwesomeIcons.sign_out,
                                      color: Colors.black)),
                              title: Text('Logout',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.apply(color: Colors.black)),
                              trailing: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: AppColors.primaryColor),
                                  child: const Icon(
                                      LineAwesomeIcons.angle_right,
                                      size: 18,
                                      color: Colors.black))),
                          const SizedBox(height: 10),
                          const Divider(color: Colors.black),
                        ])));
              }));
    });
  }
}
