import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InstaLoginScreen extends StatelessWidget {
  InstaLoginScreen({super.key});

  final _webCtrl = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse('https://www.instagram.com/accounts/login/'));

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight:
            (Get.height - MediaQuery.of(context).viewInsets.bottom) * 0.8,
      ),
      child: WebViewWidget(
        controller: _webCtrl,
        gestureRecognizers: {Factory(() => EagerGestureRecognizer())},
      ),
    );
  }
}
