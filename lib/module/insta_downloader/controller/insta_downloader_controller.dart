import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_downloader/common/widget/app_bottom_sheet.dart';
import 'package:video_downloader/core/toast/app_toast.dart';
import 'package:video_downloader/module/insta_downloader/data/enum/insta_media_type.dart';
import 'package:video_downloader/module/insta_downloader/data/repo/insta_downloader_repo.dart';
import 'package:video_downloader/module/insta_downloader/screen/insta_login_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InstaDownloaderController extends GetxController
    with InstaDownloaderRepo {
  bool loading = false;
  final Uri _url;

  InstaMediaType? mediaType;

  InstaDownloaderController(this._url);

  @override
  void onInit() async {
    initDataFromWebview();
    super.onInit();
  }

  initDataFromWebview() async {
    try {
      final webCtrl = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted);

      await webCtrl.loadRequest(Uri.parse('$_url?__a=1&__d=dis'));
      await webCtrl.setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) async {
          final res = await webCtrl.runJavaScriptReturningResult(
              "document.documentElement.innerText");

          _parseMedia(res);
        },
      ));
    } catch (e) {
      debugPrint('error: $e');
    }
  }

  _parseMedia(dynamic res) {
    try {
      //i dont know why, you have to decode the string twice
      final map = json.decode(json.decode(res.toString()));

      final items = (map['items'] as List?)?.map((e) => e).toList();
      if (items == null || items.isEmpty) throw 'Post not found: $map';

      mediaType = _getMediaType(items[0]['media_type']);
      if (mediaType == null) throw 'Unsupported media type';
      //TODO here
    } catch (e) {
      debugPrint('error parsing: $e');
      AppToast.showMsg(e.toString());
    }
  }

  InstaMediaType? _getMediaType(int type) {
    switch (type) {
      case 1:
        return InstaMediaType.photo;
      case 2:
        return InstaMediaType.video;
      case 8:
        return InstaMediaType.carousel;
      default:
        return null;
    }
  }

  loginInsta() async {
    await AppBottomSheet.show(InstaLoginScreen());
    initDataFromWebview();
  }
}
