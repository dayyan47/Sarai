import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostel_add/Ads/Ad_detail%20_screen.dart';

class UserAdsScreen extends StatefulWidget {
  const UserAdsScreen({super.key});

  @override
  _UserAdsScreenState createState() => _UserAdsScreenState();
}

class _UserAdsScreenState extends State<UserAdsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  String? fullName;
  String? phoneNumber;
  String? dateOfBirth;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userSnapshot =
          await _firestore.collection('users').doc(user.uid).get();
      final userData = userSnapshot.data() as Map<String, dynamic>;
      setState(() {
        fullName = userData['full_name'] as String?;
        phoneNumber = userData['phone_number'] as String?;
        dateOfBirth = userData['date_of_birth'] as String?;
        profileImageUrl = userData['profile_image_url'] as String?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF5A5F),
        title: const Center(
            child: Text(
          'My Ads',
          style: TextStyle(color: Colors.white),
        )),
      ),
      // backgroundColor: Color(0xFFFF5A5F),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // User profile information
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: profileImageUrl != null
                        ? Image.network(
                            profileImageUrl!,
                            errorBuilder: (context, error, stackTrace) {
                              return const Placeholder(); // Handle image loading error here
                            },
                          )
                        : const Placeholder(), // Placeholder if profile image is not available
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  ' ${fullName ?? 'N/A'}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),

          // User's Ads
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('ads')
                  .where('userId', isEqualTo: currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No ads found for the logged-in user.'),
                  );
                }

                final ads = snapshot.data?.docs;

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: ads?.length,
                  itemBuilder: (context, index) {
                    final adData = ads?[index].data() as Map<String, dynamic>;

                    return GestureDetector(
                      onTap: () {
                        final adId = ads?[index].id;
                        _navigateToAdDetails(adId);
                      },
                      child: AdCard(adData: adData),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAdDetails(String? adId) {
    if (adId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AdDetailScreen(adId: adId),
        ),
      );
    }
  }
}

class AdCard extends StatelessWidget {
  final Map<String, dynamic> adData;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdCard({super.key, required this.adData});

  @override
  Widget build(BuildContext context) {
    final title = adData['title'] as String? ?? 'No Title';
    final price = adData['price'] as String? ?? 'No Price';
    final imageUrl = adData['image_url'] as String?;
    final userId = adData['userId'];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine the screen width
        final screenWidth = constraints.maxWidth;

        // Define the number of columns based on screen width
        int columns = 2;
        if (screenWidth > 600) {
          columns = 3;
        }

        // Calculate image dimensions based on the number of columns
        final imageSize = screenWidth / columns - 16.0; // Subtract spacing

        return Card(
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null)
                Image.network(
                  imageUrl,
                  height: imageSize,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text('Price: $price'),
                    StreamBuilder<DocumentSnapshot>(
                      stream: _firestore
                          .collection('users')
                          .doc(userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (!snapshot.hasData || snapshot.data == null) {
                          return const Text('User profile data not found.');
                        }

                        final userData =
                            snapshot.data!.data() as Map<String, dynamic>;

                        final username =
                            userData['full_name'] as String? ?? 'No Username';

                        return Text('Posted by: $username');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
