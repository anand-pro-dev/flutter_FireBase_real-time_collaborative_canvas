import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String title;
  final bool? loading;
  final VoidCallback onTap;
  const RoundedButton(
      {Key? key,
      required this.title,
      required this.onTap,
      this.loading = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7), color: Colors.deepPurple),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: loading == true
              ? const CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                )
              : Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 25),
                ),
        ),
      ),
    );
  }
}
