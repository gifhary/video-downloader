import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_downloader/module/tt_downloader/controller/tt_downloader_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TtDownloaderScreen extends StatelessWidget {
  TtDownloaderScreen({super.key});

  final url = Get.arguments['url'] as Uri;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TtDownloaderController>(
      init: TtDownloaderController(url),
      builder: (controller) {
        return SafeArea(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              WebViewWidget(
                controller: controller.webCtrl,
                gestureRecognizers: {Factory(() => EagerGestureRecognizer())},
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ElevatedButton(
                  onPressed: controller.something,
                  child: const Text('Button'),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
