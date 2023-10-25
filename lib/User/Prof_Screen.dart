import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostel_add/Ads/User_Ads.dart';
import 'package:hostel_add/UserAuth/Login_Screen.dart';
import 'package:modern_form_line_awesome_icons/modern_form_line_awesome_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Edit_profile.dart';

class ProfScreen extends StatelessWidget {
  const ProfScreen({Key? key});

  _logout(BuildContext context, FirebaseAuth auth) async {
    bool _isLoggedIn = false;
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', _isLoggedIn);
      prefs.remove('isLoggedIn');
      await auth.signOut();
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> LoginScreen()),   (Route<dynamic> r)=> false);
    } catch (e){
      print('Error Signing Out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user?.uid);

    //return Container(color: Colors.black,);

    return Container(
        child: SingleChildScrollView(
          child: StreamBuilder<DocumentSnapshot>(
            stream: userDoc.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (!snapshot.hasData || snapshot.data == null) {
                // Handle case where user data is not available
                return Center(child: Text('User data not found.'));
              }
              final userData = snapshot.data!.data() as Map<String, dynamic>?;
              if (userData == null) {
                // Handle case where user data is null
                return Center(child: Text('User data is null.'));
              }
              final fullName = userData['full_name'] as String?;
              final phoneNumber = userData['phone_number'] as String?;
              final profileImageUrl = userData['profile_image_url'] as String?;

              return Padding(padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: profileImageUrl != null
                                ? Image.network(
                              profileImageUrl,
                              errorBuilder: (context, error, stackTrace) {
                                // Handle image loading error here
                                return Placeholder(); // You can use a placeholder image or another fallback
                              },
                            )
                                : Placeholder(), // Placeholder if profile image is not available
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: const Color(0xFFFF5A5F),),
                            child: const Icon(
                              LineAwesomeIcons.pencil_square_o,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFFF5A5F), width: 2),
                        borderRadius: BorderRadius.circular(10),),
                      child:
                      Text(' ${fullName ?? 'N/A'}', style: Theme.of(context).textTheme.headlineSmall,),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFFF5A5F), width: 2),
                        borderRadius: BorderRadius.circular(10),),
                      child:
                          Text(' ${phoneNumber ?? 'N/A'}', style: Theme.of(context).textTheme.headlineSmall),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfile()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder( //<-- SEE HERE
                            side: BorderSide(width: 2, color: Color(0xFFFF5A5F)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Edit Profile', style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(color: Colors.black),
                    const SizedBox(height: 10),
                    ListTile(
                      //tileColor: Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 2, color: Color(0xFFFF5A5F)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>UserAdsScreen()));
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
                    SizedBox(height: 5,),
                    // ListTile(
                    //   //tileColor: Colors.grey.shade200,
                    //   shape: RoundedRectangleBorder( //<-- SEE HERE
                    //     side: BorderSide(width: 2, color: Color(0xFFFF5A5F)),
                    //     borderRadius: BorderRadius.circular(20),
                    //   ),
                    //   onTap: () {
                    //     // Handle the User Management action here
                    //   },
                    //   leading: Container(
                    //     width: 40,
                    //     height: 40,
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(100),
                    //       color: const Color(0xFFFF5A5F),
                    //     ),
                    //     child: const Icon(
                    //       LineAwesomeIcons.user,
                    //       color: Colors.black,
                    //     ),
                    //   ),
                    //   title: Text(
                    //     'User Management',
                    //     style: Theme.of(context)
                    //         .textTheme
                    //         .bodyLarge
                    //         ?.apply(color: Colors.black),
                    //   ),
                    //   trailing: Container(
                    //     width: 30,
                    //     height: 30,
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(100),
                    //       color: const Color(0xFFFF5A5F),
                    //     ),
                    //     child: const Icon(
                    //       LineAwesomeIcons.angle_right,
                    //       size: 18,
                    //       color: Colors.black,
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(height: 5,),
                    ListTile(
                      //tileColor: Colors.grey.shade200,
                      shape: RoundedRectangleBorder( //<-- SEE HERE
                        side: BorderSide(width: 2, color: Color(0xFFFF5A5F)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onTap: ()=> _logout(context, _auth),
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
                      title: Text('Logout', style: Theme.of(context).textTheme.bodyLarge?.apply(color: Colors.black),),
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
                    SizedBox(height: 10,),
                    const Divider(color: Colors.black),
                  ],
                )
              );
            },
          ),
        ),
    );
  }

}
