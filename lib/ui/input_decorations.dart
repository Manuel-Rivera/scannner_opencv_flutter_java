import 'package:flutter/material.dart';

class InputDecorations {
  static InputDecoration authInputDecoration(
      {required String hintText, IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      border: const OutlineInputBorder(),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
    );
  }
}
