import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppToast {
  static Future<bool?> showMsg(String msg, {Toast? toastLength}) async {
    return Fluttertoast.showToast(
      msg: msg,
      toastLength: toastLength,
      backgroundColor: Colors.grey[700],
    );
  }
}
