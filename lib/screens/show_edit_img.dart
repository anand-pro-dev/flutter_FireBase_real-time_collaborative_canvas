// image_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageListScreen extends StatelessWidget {
  final String userEmail;

  const ImageListScreen({Key? key, required this.userEmail}) : super(key: key);

  Future<List<String>> fetchImageUrls() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    List<String> imageUrls = [];

    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userEmail).get();
    if (userDoc.exists && userDoc.data() != null) {
      imageUrls = List<String>.from(userDoc.get('imageUrls'));
    }

    return imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Edited List'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<String>>(
        future: fetchImageUrls(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No images found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              reverse: true,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(child: Image.network(snapshot.data![index])),
                );
              },
            );
          }
        },
      ),
    );
  }
}
