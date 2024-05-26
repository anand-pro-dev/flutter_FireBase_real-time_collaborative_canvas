import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;
import 'package:canvas_app/auth/login_scren.dart';
import 'package:canvas_app/canvas/canvas_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../utils/snack_bar.dart';

class CanvasScreen extends StatefulWidget {
  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      // Handle sign out errors
      print('Error signing out: $e');
      // Optionally, show a snackbar or display an error message to the user
    }
  }

  String? canvasId;
  final TextEditingController _rooId = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Canvas '),
        actions: [
          IconButton(
            onPressed: () async {
              await _signOut(context);
            },
            icon: const Icon(Icons.logout_rounded),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: _rooId,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+$')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Enter a number',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    canvasId = _rooId.text;
                  });
                },
                child: const Text('Submit')),
            const SizedBox(height: 40),
            Text("Canvas Room id:  $canvasId"),
            const SizedBox(height: 20),
            if (canvasId != null && canvasId! != "")
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyCanvas(drawingId: canvasId!)),
                  );
                  Utils().snackBar(
                      "double tap on screen to change the brush color", context,
                      color: Colors.green);
                },
                child: const Text('Draw and Save'),
              ),
            if (canvasId != null && canvasId! != "")
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DisplayCanvas(
                              drawingId: canvasId!,
                            )),
                  );
                },
                child: const Text('View Drawing'),
              ),
          ],
        ),
      ),
    );
  }
}
