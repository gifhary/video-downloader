import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_downloader/module/tt_downloader/data/repo/tt_downloader_repo.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TtDownloaderController extends GetxController with TtDownloaderRepo {
  final webCtrl = WebViewController();

  final Uri _url;

  TtDownloaderController(this._url);

  @override
  void onInit() {
    webCtrl
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
          Uri.parse('https://en.savefrom.net/189/download-from-tiktok'));
    webCtrl.setNavigationDelegate(NavigationDelegate(
      onPageFinished: (url) {
        debugPrint('page finish: $url');
        webCtrl
            .runJavaScript('document.getElementById("sf_url").value="$_url";');
        webCtrl.runJavaScript('document.getElementById("sf_submit").click();');
      },
    ));

    super.onInit();
  }

  something() async {
    //TODO change variable name every calling [element]
    const js = '''
const element = document.getElementsByClassName("link link-download subname ga_track_events download-icon"); 
element[0].getAttribute("href");
''';

    final downloadLink = await webCtrl.runJavaScriptReturningResult(js);
    debugPrint('tag: ${(downloadLink as String).replaceAll('"', '')}');
  }
}
