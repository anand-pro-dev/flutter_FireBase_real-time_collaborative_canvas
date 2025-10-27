  //sdk: '>=3.0.6 <4.0.0'

import 'package:canvas_app/auth/login_scren.dart';
import 'package:canvas_app/canvas/canvas_room.dart';
import 'package:canvas_app/screens/image_edit.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Canvas App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data == null) {
              return LoginScreen();
            } else {
              return CanvasScreen();
            }
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      builder: EasyLoading.init(),
      // home: MobileExample(),
      // home: ImageEditorExample(),
    );
  }
}
