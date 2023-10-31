import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostel_add/Ads/Ad_Home_Screen.dart';
import 'package:hostel_add/Ads/Post_Edit_Ads.dart';
import 'package:hostel_add/User/Profile_Screen.dart';
import 'package:hostel_add/Widgets/Maps_Widget.dart';

class HScreen extends StatefulWidget {
  const HScreen({super.key});

  @override
  _HScreenState createState() => _HScreenState();
}

class _HScreenState extends State<HScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;
  late List<Widget> screens = [
    _buildDefaultLayout(),
    const MapViewScreen(),
    const ProfileScreen()
  ];
  static const List<Widget> _pages = <Widget>[
    Text('Home',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    Text('Map',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    Text('Profile',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xFFFF5A5F),
          title: _pages[_selectedIndex],
          centerTitle: true),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) => setState(() {
          _selectedIndex = index;
        }),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        backgroundColor: const Color(0xFFFF5A5F),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PostEditAdScreen(adId: "Post Ad")),
                );
              },
              backgroundColor: const Color(0xFFFF5A5F),
              label: const Row(children: [
                Text(
                  "Post AD",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Icon(
                  Icons.add,
                  color: Colors.white,
                )
              ]),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }

  // Widget _buildLargeScreenLayout() {
  //   return const Center(
  //     child: Text('Large Screen Layout'),
  //   );
  // }

  Widget _buildDefaultLayout() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('ads').snapshots(),
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

            return AdHomeScreen(adData: adData, adId: adId);
          },
        );
      },
    );
  }
}
