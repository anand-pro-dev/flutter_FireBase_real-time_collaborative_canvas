import 'package:flutter/material.dart';

class Utils {
  snackBar(String message, BuildContext context, {Color? color}) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color ?? Colors.red,
        content: Text(message),
      ),
    );
  }
}
