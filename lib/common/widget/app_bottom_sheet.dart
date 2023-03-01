import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBottomSheet {
  static Future<void> show(Widget widget, {bool isDismissable = true}) async {
    await Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 16),
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(3)),
              ),
              height: 5,
              width: 110,
            ),
            const SizedBox(height: 24),
            widget
          ],
        ),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      isDismissible: isDismissable,
    );
  }
}
