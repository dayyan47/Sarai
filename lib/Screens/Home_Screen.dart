import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:hostel_add/Widgets/Ad_Home_Screen_Widget.dart';
import 'package:hostel_add/AdScreens/Fav_Ads_Screen.dart';
import 'package:hostel_add/AdScreens/Post_Edit_Ads_Screen.dart';
import 'package:hostel_add/Screens/Profile_Screen.dart';
import 'package:hostel_add/Screens/Maps_Screen.dart';
import 'package:hostel_add/resources/values/colors.dart';
import 'package:modern_form_line_awesome_icons/modern_form_line_awesome_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _showFab = true;
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

  Widget _buildDefaultLayout() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('ads')
          .orderBy("timestamp", descending: true)
          .snapshots(),
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

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 300);

    return Scaffold(
      appBar: AppBar(
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: const Icon(LineAwesomeIcons.heart, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FavAdsScreen()));
                  },
                ),
                const SizedBox(width: 10)
              ]
            : null,
        backgroundColor: AppColors.PRIMARY_COLOR,
        title: _pages[_selectedIndex],
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            final ScrollDirection direction = notification.direction;
            setState(() {
              if (direction == ScrollDirection.reverse) {
                _showFab = false;
              } else if (direction == ScrollDirection.forward) {
                _showFab = true;
              }
            });
            return true;
          },
          child: IndexedStack(index: _selectedIndex, children: screens)),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) => setState(() {
          _selectedIndex = index;
        }),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        backgroundColor: AppColors.PRIMARY_COLOR,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? AnimatedSlide(
              duration: duration,
              offset: _showFab ? Offset.zero : const Offset(0, 2),
              child: AnimatedOpacity(
                  duration: duration,
                  opacity: _showFab ? 1 : 0,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const PostEditAdScreen(adId: "Post Ad")),
                      );
                    },
                    backgroundColor: AppColors.PRIMARY_COLOR,
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
                  )))
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }
}
