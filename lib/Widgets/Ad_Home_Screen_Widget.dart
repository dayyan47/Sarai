import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hostel_add/AdScreens/Ad_Detail_Screen.dart';

class AdHomeScreen extends StatelessWidget {
  final Map<String, dynamic> adData;
  final String adId;

  const AdHomeScreen({super.key, required this.adData, required this.adId});

  @override
  Widget build(BuildContext context) {
    final hostelName = adData['hostel_name'] as String? ?? 'No Hostel nme';
    final price = adData['price'] as String? ?? 'No Price';
    final imageUrls = adData['image_urls'] ?? [];
    final address = adData['address'] as String? ?? 'No Address';
    final area = adData['area'] as String? ?? 'No Area';
    final city = adData['city'] as String? ?? 'No City';
    final postedBy = adData['owner'] as String? ?? 'No Owner Name';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AdDetailScreen(adId: adId)));
      },
      child: Card(
        elevation: 10,
        margin: const EdgeInsets.all(20),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imageUrls.isNotEmpty)
                Center(
                  child: SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageUrls.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CachedNetworkImage(
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            imageUrl: imageUrls[index],
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        text: TextSpan(children: [
                          TextSpan(
                              text: hostelName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: Colors.black)),
                          TextSpan(
                              text: ' / $city',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black))
                        ])),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text('Rs $price',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const Text(" / Month")
                      ],
                    ),
                    const SizedBox(height: 5),
                    RichText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        text: TextSpan(children: [
                          TextSpan(
                              text: area != "" ? '$address, $area' : address,
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.black))
                        ])),
                  ],
                ),
              ),
              Row(
                children: [
                  const Spacer(),
                  const Text("Posted by: "),
                  Text(postedBy,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
