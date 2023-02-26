import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validators/validators.dart';
import 'package:video_downloader/core/toast/app_toast.dart';
import 'package:video_downloader/module/tt_downloader/data/constant/tt_downloader_constant.dart';
import 'package:video_downloader/module/tt_downloader/data/model/tt_content_model.dart';
import 'package:video_downloader/module/tt_downloader/data/repo/tt_downloader_repo.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TtDownloaderController extends GetxController with TtDownloaderRepo {
  final webCtrl = WebViewController();

  bool loadingDownloadUrl = false;
  bool loadingContentDetails = false;
  bool error = false;

  final Uri _url;

  TtContentModel? content;
  String? _downloadUrl;

  TtDownloaderController(this._url);

  @override
  void onInit() async {
    _getContentDetails();
    _getDownloadUrlFromSavefromNet();
    super.onInit();
  }

  launchTtProfile(String username) async {
    debugPrint('launching: ${TtDownloaderConstant.ttProfileUrl(username)}');
    if (!await launchUrl(
        Uri.parse(TtDownloaderConstant.ttProfileUrl(username)))) {
      debugPrint(
          'cannot launch url: ${TtDownloaderConstant.ttProfileUrl(username)}');
    }
  }

  downloadContent([bool? audioOnly]) {
    try {
      if (_downloadUrl == null || !isURL(_downloadUrl)) {
        throw 'Something went wrong when downloading the ${(audioOnly ?? false) ? 'audio' : 'video'}';
      }
      debugPrint('download here: $_downloadUrl $audioOnly');
      //TODO download
    } catch (e) {
      AppToast.showMsg(e.toString(), toastLength: Toast.LENGTH_LONG);
    }
  }

  Future<void> _getContentDetails() async {
    loadingContentDetails = true;
    update();
    try {
      content = await repoGetTiktokData(_url.toString());
    } catch (e) {
      debugPrint('error getting content details: $e');
      if (_downloadUrl != null && isURL(_downloadUrl)) {
        AppToast.showMsg(
            'Failed getting content details, but you can still download the video',
            toastLength: Toast.LENGTH_LONG);
      }
    }
    loadingContentDetails = false;
    update();
  }

  _getDownloadUrlFromSavefromNet() async {
    loadingDownloadUrl = true;
    update();
    try {
      await webCtrl.setJavaScriptMode(JavaScriptMode.unrestricted);
      await webCtrl.loadRequest(
          Uri.parse('https://en.savefrom.net/189/download-from-tiktok'));
      await webCtrl.setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) => _onPageFinished(webCtrl, url),
      ));
    } catch (e) {
      debugPrint('error: $e');
      loadingDownloadUrl = false;
      error = true;
      update();
      AppToast.showMsg('Something went wrong, please try again later',
          toastLength: Toast.LENGTH_LONG);
    }
  }

  _onPageFinished(WebViewController webCtrl, String url) async {
    try {
      if (!Uri.parse(url).host.contains('savefrom.net')) return;

      await webCtrl
          .runJavaScript('document.getElementById("sf_url").value="$_url";');
      await webCtrl
          .runJavaScript('document.getElementById("sf_submit").click();');

      int loopIndex = 0;
      while (_downloadUrl == null) {
        await Future.delayed(const Duration(milliseconds: 500));
        final js =
            'const element$loopIndex = document.getElementsByClassName("link link-download subname ga_track_events download-icon"); element$loopIndex[0]?.getAttribute("href");';
        final downloadLink =
            ((await webCtrl.runJavaScriptReturningResult(js)) as String?)
                ?.replaceAll('"', '');
        if (downloadLink != null &&
            downloadLink.toLowerCase() != 'null' &&
            downloadLink.isNotEmpty) {
          _downloadUrl = downloadLink;
        }
        loopIndex++;
      }

      if (!isURL(_downloadUrl)) throw 'Failed getting the content';
    } catch (e) {
      error = true;
      AppToast.showMsg('Failed getting the content',
          toastLength: Toast.LENGTH_LONG);
    }
    loadingDownloadUrl = false;
    update();
  }
}
