import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Hostel/adDetail.dart';

class AdsHomeScreen extends StatelessWidget {
  final Map<String, dynamic> adData;
  final String adId;

  AdsHomeScreen({super.key, required this.adData, required this.adId});

  @override
  Widget build(BuildContext context) {
    final title = adData['title'] as String? ?? 'No Title';
    final price = adData['price'] as String? ?? 'No Price';
    final imageUrl = adData['image_url'] as String?;
    final address = adData['address'] as String;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => RoomDetail(adId: adId)));
      },
      child: Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        color: Colors.white70,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text('Price: $price'),
                    const SizedBox(height: 4),
                    Text('Address: $address'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}