import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  final String imageUrl;

  ImageWidget({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return Image.network(
      imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
    );
    } else {
      return Icon(Icons.image_not_supported_sharp,
    size: 100,
    color: Colors.grey,);
    } // Return an empty SizedBox if imageUrl is null.
  }
}
