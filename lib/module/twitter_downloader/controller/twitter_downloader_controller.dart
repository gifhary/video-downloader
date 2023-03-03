import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:validators/validators.dart';
import 'package:video_downloader/common/utils/common_utils.dart';
import 'package:video_downloader/core/toast/app_toast.dart';
import 'package:video_downloader/module/twitter_downloader/data/repo/twitter_downloader_repo.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TwitterDownloaderController extends GetxController
    with TwitterDownloaderRepo {
  final webCtrl = WebViewController();

  bool loadingDownloadUrl = false;
  bool loadingContentDetails = false;
  bool error = false;

  final Uri _url;

  String? thumbnail;
  String? title;
  String? _downloadUrl;

  TwitterDownloaderController(this._url);

  @override
  void onInit() async {
    initData();
    super.onInit();
  }

  initData() {
    error = false;
    update();
    _getDownloadUrlFromSavefromNet();
  }

  downloadContent([bool? audioOnly]) async {
    try {
      //TODO make it background service
      if (_downloadUrl == null || !isURL(_downloadUrl)) {
        throw 'Something went wrong when downloading the ${(audioOnly ?? false) ? 'audio' : 'video'}';
      }
      AppToast.showMsg(
          'Downloading ${(audioOnly ?? false) ? 'audio' : 'video'}');
      final dir = (audioOnly ?? false)
          ? await getTemporaryDirectory()
          : await CommonUtils.getSavingDirectory();

      final filePath =
          '${dir.path}/twitter-${DateTime.now().millisecondsSinceEpoch}.mp4';

      await repoDownload(
        Uri.parse(_downloadUrl ?? ''),
        filePath,
        onReceiveProgress: (received, total) {
          debugPrint('rec: $received, total: $total');
        },
      );

      if (audioOnly ?? false) {
        debugPrint('downloading audio');
        await _extractAudio(
            filePath, '${DateTime.now().millisecondsSinceEpoch}');
      }

      AppToast.showMsg(
          '${(audioOnly ?? false) ? 'Audio' : 'Video'} downloaded');
    } catch (e) {
      debugPrint('download content error: $e');
      AppToast.showMsg(
          'Failed downloading ${(audioOnly ?? false) ? 'audio' : 'video'}',
          toastLength: Toast.LENGTH_LONG);
    }
  }

  _extractAudio(String filePath, String finalFileName) async {
    try {
      final dir = await CommonUtils.getSavingDirectory();
      // ignore: unused_local_variable
      final finalFile = await repoExtreactAudio(
          filePath, '${dir.path}/twitter-$finalFileName.mp3');
    } catch (e) {
      rethrow;
    }
  }

  _getDownloadUrlFromSavefromNet() async {
    loadingDownloadUrl = true;
    update();
    try {
      await webCtrl.setJavaScriptMode(JavaScriptMode.unrestricted);
      webCtrl.loadRequest(Uri.parse('https://en.savefrom.net/383/'));
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
      debugPrint('page finish: $url');
      if (!Uri.parse(url).host.contains('savefrom.net')) return;

      await webCtrl
          .runJavaScript('document.getElementById("sf_url").value="$_url";');
      await webCtrl
          .runJavaScript('document.getElementById("sf_submit").click();');

      _downloadUrl = await _getVidUrl();
      thumbnail = await _getThumbUrl();
      title = await _getTweetText();

      if (!isURL(_downloadUrl)) throw 'Failed getting the content';
    } catch (e) {
      debugPrint('error on page finished: $e');
      error = true;
      AppToast.showMsg('Failed getting the content',
          toastLength: Toast.LENGTH_LONG);
    }
    loadingDownloadUrl = false;
    update();
  }

  Future<String?> _getVidUrl() async {
    int loopIndex = 0;
    String? url;
    while (url == null) {
      //terminate loop if its taking too long
      if (loopIndex >= 10) return null;

      await Future.delayed(const Duration(milliseconds: 500));
      final js =
          '''const getVidVar$loopIndex = document.getElementsByClassName("link link-download subname ga_track_events download-icon");
          getVidVar$loopIndex[0]?.getAttribute("href");''';
      final downloadLink =
          ((await webCtrl.runJavaScriptReturningResult(js)) as String?)
              ?.replaceAll('"', '');

      debugPrint('donwload url: $downloadLink');

      if (downloadLink != null &&
          downloadLink.toLowerCase() != 'null' &&
          downloadLink.isNotEmpty) {
        url = downloadLink;
      }
      loopIndex++;
    }
    return url;
  }

  Future<String?> _getThumbUrl() async {
    int loopIndex = 0;
    String? url;
    while (url == null) {
      //terminate loop if its taking too long
      if (loopIndex >= 10) return null;

      await Future.delayed(const Duration(milliseconds: 500));
      final js =
          '''const getThumbVar$loopIndex = document.getElementsByClassName("thumb");
          getThumbVar$loopIndex[0]?.getAttribute("src");''';
      final downloadLink =
          ((await webCtrl.runJavaScriptReturningResult(js)) as String?)
              ?.replaceAll('"', '');

      debugPrint('thumb url: $downloadLink');

      if (downloadLink != null &&
          downloadLink.toLowerCase() != 'null' &&
          downloadLink.isNotEmpty) {
        url = downloadLink;
      }
      loopIndex++;
    }
    return url;
  }

  Future<String?> _getTweetText() async {
    int loopIndex = 0;
    String? url;
    while (url == null) {
      //terminate loop if its taking too long
      if (loopIndex >= 10) return null;

      await Future.delayed(const Duration(milliseconds: 500));
      final js =
          '''const getTitleVar$loopIndex = document.getElementsByClassName("row title");
          getTitleVar$loopIndex[0]?.getAttribute("title");''';
      final downloadLink =
          ((await webCtrl.runJavaScriptReturningResult(js)) as String?)
              ?.replaceAll('"', '');

      debugPrint('tweet title: $downloadLink');

      if (downloadLink != null &&
          downloadLink.toLowerCase() != 'null' &&
          downloadLink.isNotEmpty) {
        url = downloadLink;
      }
      loopIndex++;
    }
    return url;
  }
}
