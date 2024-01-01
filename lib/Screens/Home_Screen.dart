import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hostel_add/Screens/Ads_Home_Screen.dart';
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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _showFab = true;
  int _selectedIndex = 0;
  late List<Widget> screens = [
    const AdsScreen(),
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

  Widget _buildAppBarItemsForWeb() {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: IconButton(
            icon: Icon(Icons.home,
                color: _selectedIndex == 0 ? Colors.white : Colors.grey),
            onPressed: () {
              setState(() {
                _selectedIndex = 0;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: IconButton(
            icon: Icon(Icons.map,
                color: _selectedIndex == 1 ? Colors.white : Colors.grey),
            onPressed: () {
              setState(() {
                _selectedIndex = 1;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: IconButton(
            icon: Icon(Icons.person,
                color: _selectedIndex == 2 ? Colors.white : Colors.grey),
            onPressed: () {
              setState(() {
                _selectedIndex = 2;
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 300);
    const bool isWeb = kIsWeb;
    return Scaffold(
      appBar: AppBar(
        actions: isWeb
            ? [
                _buildAppBarItemsForWeb(),
                if (_selectedIndex == 0)
                  IconButton(
                    icon:
                        const Icon(LineAwesomeIcons.heart, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FavAdsScreen()));
                    },
                  ),
                const SizedBox(width: 10)
              ]
            : _selectedIndex == 0
                ? [
                    IconButton(
                      icon: const Icon(LineAwesomeIcons.heart,
                          color: Colors.white),
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
        backgroundColor: AppColors.primaryColor,
        title: _pages[_selectedIndex],
        centerTitle: !isWeb ? true : false,
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
          //child: screens[_selectedIndex]),
          child: IndexedStack(index: _selectedIndex, children: screens)),
      bottomNavigationBar: isWeb
          ? null
          : BottomNavigationBar(
              onTap: (index) => setState(() {
                _selectedIndex = index;
              }),
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.black,
              backgroundColor: AppColors.primaryColor,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: "Profile"),
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
                    backgroundColor: AppColors.primaryColor,
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
