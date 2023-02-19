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
      child: Column(
        children: [
          Container(
            color: Colors.orange[200],
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notification_important_outlined,
                    color: Colors.yellow[900],
                  ),
                ),
                const SizedBox(width: 12),
                const Flexible(
                  child: Text(
                      'In order to download private account contents, you need to log in to be able to access it. Instagram also limit anonymous access to their data to a few times per hour. We do not record nor share your log in credentials to anyone.'),
                ),
              ],
            ),
          ),
          Flexible(
            child: WebViewWidget(
              controller: _webCtrl,
              gestureRecognizers: {Factory(() => EagerGestureRecognizer())},
            ),
          ),
        ],
      ),
    );
  }
}
