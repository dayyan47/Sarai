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
    final imageUrls = adData['image_urls'] != null ? adData['image_urls'] : [];
    final address = adData['address'] as String;
    final area = adData['area'] as String;
    final city = adData['city'] as String;
    final postedBy = adData['owner'];

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
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageUrls.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Image.network(imageUrls[index]),
                          // child: Image(
                          //     image: ResizeImage(NetworkImage(imageUrls[index]),
                          //         height: 250,
                          //         width: MediaQuery.of(context)
                          //             .size
                          //             .width
                          //             .toInt())),
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
