// import 'dart:developer';
// import 'dart:typed_data';
// import 'package:canvas_app/auth/login_scren.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:canvas_app/screens/show_edit_img.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:image_editor_plus/image_editor_plus.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ImageEditorExample extends StatefulWidget {
//   const ImageEditorExample({Key? key}) : super(key: key);

//   @override
//   _ImageEditorExampleState createState() => _ImageEditorExampleState();
// }

// class _ImageEditorExampleState extends State<ImageEditorExample> {
//   Uint8List? imageData;
//   final _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String userEmail = '';

//   @override
//   void initState() {
//     super.initState();
//     userData();
//   }

//   Future<void> userData() async {
//     userEmail = _auth.currentUser?.email ?? '';
//     setState(() {});
//   }

//   void _showDefaultLoading() {
//     EasyLoading.show(status: 'Loading...');
//     // Simulate a background task
//     Future.delayed(Duration(seconds: 2), () {
//       EasyLoading.dismiss();
//     });
//   }

//   Future<void> saveImageUrl(String url) async {
//     try {
//       DocumentReference userDoc = _firestore.collection('users').doc(userEmail);
//       await _firestore.runTransaction((transaction) async {
//         DocumentSnapshot snapshot = await transaction.get(userDoc);

//         if (!snapshot.exists) {
//           transaction.set(userDoc, {
//             'imageUrls': [url]
//           });
//         } else {
//           List<dynamic> imageUrls = snapshot.get('imageUrls');
//           imageUrls.add(url);
//           transaction.update(userDoc, {'imageUrls': imageUrls});
//         }
//       });
//     } catch (e) {
//       log('Error saving image URL: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text(userEmail),
//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ImageListScreen(userEmail: userEmail),
//                 ),
//               );
//             },
//             icon: Icon(Icons.image),
//           ),
//           IconButton(
//               onPressed: () async {
//                 _auth.signOut().then(
//                       (value) => Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const LoginScreen(),
//                         ),
//                       ),
//                     );
//               },
//               icon: const Icon(Icons.logout))
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             SizedBox(width: double.infinity),
//             if (imageData != null)
//               SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.6,
//                 width: double.infinity,
//                 child: Center(child: Image.memory(imageData!)),
//               ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               child: const Text("Select Image from Gallery"),
//               onPressed: () async {
//                 final pickedFile = await ImagePicker().pickImage(
//                   source: ImageSource.gallery,
//                 );

//                 if (pickedFile != null) {
//                   final imageBytes = await pickedFile.readAsBytes();
//                   setState(() {
//                     imageData = Uint8List.fromList(imageBytes);
//                   });
//                 }
//               },
//             ),
//             if (imageData != null)
//               ElevatedButton(
//                 child: const Text("Save Image to Gallery"),
//                 onPressed: () async {
//                   if (imageData != null) {
//                     final result = await ImageGallerySaver.saveImage(
//                       imageData!,
//                     );
//                     if (result['isSuccess']) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Image saved to gallery"),
//                         ),
//                       );
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Failed to save image"),
//                         ),
//                       );
//                     }
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text("No image selected"),
//                       ),
//                     );
//                   }
//                 },
//               ),
//             // ElevatedButton(
//             //     onPressed: () {
//             //       _showDefaultLoading();
//             //     },
//             //     child: Text("l")),
//             if (imageData != null)
//               ElevatedButton(
//                 child: const Text("Edit Image"),
//                 onPressed: () async {
//                   if (imageData != null) {
//                     var editedImage = await Navigator.push<Uint8List?>(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ImageEditor(
//                           image: imageData!,
//                         ),
//                       ),
//                     );

//                     // replace with edited image
//                     if (editedImage != null) {
//                       setState(() {
//                         imageData = editedImage;
//                       });
//                     }
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text("Please select an image first"),
//                       ),
//                     );
//                   }
//                 },
//               ),
//             if (imageData != null)
//               ElevatedButton(
//                 child: const Text('Upload'),
//                 onPressed: () async {
//                   log('upload');

//                   EasyLoading.show(status: 'Loading...');

//                   if (imageData != null) {
//                     var imageName =
//                         DateTime.now().millisecondsSinceEpoch.toString();
//                     var storageRef = FirebaseStorage.instance
//                         .ref()
//                         .child('images/$imageName.jpg');
//                     var uploadTask = storageRef.putData(imageData!);
//                     var snapshot = await uploadTask.whenComplete(() => null);
//                     var downloadUrl = await snapshot.ref.getDownloadURL();
//                     log("url: $downloadUrl");

//                     // Save download URL to Firestore
//                     await saveImageUrl(downloadUrl);
//                     imageData = null;
//                     setState(() {});
//                     Future.delayed(Duration(seconds: 1), () {
//                       EasyLoading.dismiss();
//                     });
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text("Image uploaded successfully"),
//                       ),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text("No image selected"),
//                       ),
//                     );
//                   }
//                 },
//               )
//           ],
//         ),
//       ),
//     );
//   }
// }
