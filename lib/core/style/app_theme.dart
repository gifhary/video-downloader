import 'package:flutter/material.dart';

class AppTheme {
  static final main = ThemeData(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primaryColor: Colors.black,
    canvasColor: Colors.grey[200],
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: Colors.green),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: Colors.grey[300]!,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: Colors.grey[300]!,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
          color: Colors.green,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey[300]!,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      color: Colors.grey[200],
      iconTheme: const IconThemeData(color: Colors.green),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.green,
          fixedSize: const Size(double.maxFinite, 42),
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2),
    ),
    iconTheme: const IconThemeData(
      color: Colors.grey,
    ),
    dividerColor: Colors.grey[100],
  );
}
