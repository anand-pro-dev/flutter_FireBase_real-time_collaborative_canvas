import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;
import 'package:canvas_app/auth/login_scren.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../utils/snack_bar.dart';

class MyCanvas extends StatefulWidget {
  final String drawingId;

  MyCanvas({required this.drawingId});

  @override
  _MyCanvasState createState() => _MyCanvasState();
}

class _MyCanvasState extends State<MyCanvas> {
  final GlobalKey _key = GlobalKey();

  // Other existing code
  Future<void> _saveDrawingAsImage() async {
    RenderRepaintBoundary boundary =
        _key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    // Convert ByteData to Uint8List
    Uint8List imageData = byteData!.buffer.asUint8List();

    // Check if there's already an image stored
    var documentSnapshot =
        await _firestore.collection('images').doc(widget.drawingId).get();

    // Update or save the image data
    if (documentSnapshot.exists) {
      // If an image already exists, update its data
      String imageUrl = documentSnapshot.data()!['imageUrl'];
      Reference ref = FirebaseStorage.instance.refFromURL(imageUrl);

      await ref.putData(imageData);
      print(imageUrl.toString());
    } else {
      // If no image exists, save the new image data
      Reference ref =
          FirebaseStorage.instance.ref().child('${widget.drawingId}.png');
      await ref.putData(imageData);
      String downloadUrl = await ref.getDownloadURL();

      // Save the download URL to Firestore
      await _firestore.collection('images').doc(widget.drawingId).set({
        'imageUrl': downloadUrl,
      });
      print(downloadUrl.toString());
    }
  }

  final List<List<Offset>> _lines = [];
  final List<Color> _lineColors = [];
  int _currentColorIndex = 0;
  final List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.black,
  ];

  late final FirebaseFirestore _firestore;

  late StreamSubscription<QuerySnapshot> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _streamSubscription = _firestore
        .collection('drawings')
        .doc(widget.drawingId)
        .collection('lines')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _lines.clear();
        _lineColors.clear();
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final flattenedLine = (data['line'] as List).cast<double>();
          final line = List<Offset>.generate(
            flattenedLine.length ~/ 2,
            (i) => Offset(flattenedLine[i * 2], flattenedLine[i * 2 + 1]),
          );
          _lines.add(line);
          _lineColors.add(Color(data['color']));
        }
      });
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  void _changeColor() {
    setState(() {
      _currentColorIndex = (_currentColorIndex + 1) % _colors.length;
    });
  }

  Future<void> _saveDrawingData(List<Offset> line, Color color) async {
    final List<double> flattenedLine = [];
    for (final offset in line) {
      flattenedLine.add(offset.dx);
      flattenedLine.add(offset.dy);
    }

    await _firestore
        .collection('drawings')
        .doc(widget.drawingId)
        .collection('lines')
        .add({
      'line': flattenedLine,
      'color': color.value,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing Canvas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _undoLastLine,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDrawingAsImage,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed:
                _deleteAllLines, // Call _deleteAllLines method when delete button is pressed
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _key, // Assign _key to the RepaintBoundary widget
        child: GestureDetector(
          onTap: _changeColor,
          onPanUpdate: (details) {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            final localPosition =
                renderBox.globalToLocal(details.globalPosition);
            setState(() {
              if (_lines.isNotEmpty) {
                _lines.last.add(localPosition);
              }
            });
          },
          onPanStart: (details) {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            final localPosition =
                renderBox.globalToLocal(details.globalPosition);
            setState(() {
              final newLine = [localPosition];
              _lines.add(newLine);
              _lineColors.add(_colors[_currentColorIndex]);
            });
          },
          onPanEnd: (details) {
            if (_lines.isNotEmpty && _lineColors.isNotEmpty) {
              _saveDrawingData(_lines.last, _lineColors.last);
            }
          },
          child: CustomPaint(
            painter: MyCanvasPainter(
              lines: _lines,
              colors: _lineColors,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  void _undoLastLine() {
    if (_lines.isNotEmpty) {
      // Remove the last line from the local state
      setState(() {
        _lines.removeLast();
        _lineColors.removeLast();
      });

      // Remove the last line from Firestore
      _removeLastLineFromFirestore();
    }
  }

  void _removeLastLineFromFirestore() async {
    if (_lines.isNotEmpty) {
      // Get the reference to the last added line
      final lastLineReference = _firestore
          .collection('drawings')
          .doc(widget.drawingId)
          .collection('lines')
          .doc();

      // Delete the last line from Firestore
      await lastLineReference.delete();
    }
  }

  void _deleteAllLines() async {
    // Delete all lines from Firestore
    final snapshot = await _firestore
        .collection('drawings')
        .doc(widget.drawingId)
        .collection('lines')
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    // Clear the local state
    setState(() {
      _lines.clear();
      _lineColors.clear();
    });
  }
}

class MyCanvasPainter extends CustomPainter {
  final List<List<Offset>> lines;
  final List<Color> colors;

  MyCanvasPainter({required this.lines, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    for (int j = 0; j < lines.length; j++) {
      if (j >= colors.length) {
        // Safety check to prevent index out of range errors
        continue;
      }
      final line = lines[j];
      final color = colors[j];
      final paint = Paint()
        ..color = color
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < line.length - 1; i++) {
        canvas.drawLine(line[i], line[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DisplayCanvas extends StatelessWidget {
  final String drawingId;

  DisplayCanvas({required this.drawingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Drawing'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('drawings')
            .doc(drawingId)
            .collection('lines')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading drawing data'));
          } else {
            final drawingData = snapshot.data!.docs;
            final lines = drawingData.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final flattenedLine = (data['line'] as List).cast<double>();
              final line = List<Offset>.generate(
                flattenedLine.length ~/ 2,
                (i) => Offset(flattenedLine[i * 2], flattenedLine[i * 2 + 1]),
              );
              return line;
            }).toList();
            final colors = drawingData.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Color(data['color']);
            }).toList();

            return CustomPaint(
              painter: MyCanvasPainter(
                lines: lines,
                colors: colors,
              ),
              size: Size.infinite,
            );
          }
        },
      ),
    );
  }
}
