import 'package:flutter/material.dart';

class loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0),
          shape: BoxShape.circle
        ),
        child: const CircularProgressIndicator(
          color: Colors.blue,
        ),
      ),
    );
  }
}