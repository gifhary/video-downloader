import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppToast {
  static Future<bool?> showMsg(String msg) async {
    return Fluttertoast.showToast(
      msg: msg,
      backgroundColor: Colors.grey[700],
    );
  }
}
