import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hostel_add/Screens/Profile_Screen_Mobile.dart';
import 'package:hostel_add/UserAuth/Login_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Profile_Screen_Web.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  void showAlertDialog(BuildContext context, FirebaseAuth auth) {
    Widget noButton = TextButton(
      child: const Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget yesButton = TextButton(
      child: const Text("Yes"),
      onPressed: () {
        logout(context, auth);
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Logout"),
      content: const Text("Are you sure you want to logout?"),
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

  void logout(BuildContext context, FirebaseAuth auth) async {
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

  Future<void> deleteUser(User? currentUser) async {
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

  void launchWhatsapp() async {
    String phoneNumber = '+923032777297';
    String message = 'Hi guys, I need your help!';
    String whatsappUrl =
        'https://wa.me/$phoneNumber/?text=${Uri.parse(message)}';
    if (!await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      print("Can't open WhatsApp.");
    }
  }

  void showWebDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: const Text("Close"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Contact Us"),
      content: const Text(
          "Please contact us on whatsapp on the following number: 0303-2777297"),
      actions: [okButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 600) {
          // For smaller screens (phones)
          return const ProfileScreenMobile();
        } else if (constraints.maxWidth >= 600 || kIsWeb) {
          // For larger screens (tablets, web)
          return const ProfileScreenWeb();
        } else {
          return const Text("Not available!");
        }
      },
    );
  }
}
