import 'package:flutter/material.dart';

class AppInputStyles{
  static InputDecoration roundedInput({
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey,
      ),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon,color: Colors.grey,) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey[200],

      contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none
      ),
    );
  }
}