import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_downloader/common/constant/common_const.dart';
import 'package:video_downloader/core/route/route_const.dart';
import 'package:video_downloader/core/toast/app_toast.dart';
import 'package:video_downloader/module/home/data/repo/home_repo.dart';
import 'package:validators/validators.dart';

class HomeController extends GetxController with HomeRepo {
  final mainTextFieldCtrl = TextEditingController();

  download() {
    try {
      String urlStr = mainTextFieldCtrl.text;

      if (!urlStr.contains('http')) urlStr = 'https://$urlStr';
      if (!isURL(urlStr)) throw 'Link invalid';

      final url = Uri.parse(urlStr);
      switch (url.host.replaceAll('www.', '')) {
        case CommonConst.ytDomain:
          _validateYtUrl(url);
          break;
        case CommonConst.ytShortDomain:
          _validateYtUrl(url);
          break;
        case CommonConst.igDomain:
          break;
        default:
          AppToast.showMsg('Your link is not supported yet');
          return;
      }
    } catch (e) {
      debugPrint('error: $e');
      AppToast.showMsg('Your link is invalid');
    }
  }

  _validateYtUrl(Uri url) {
    final videoId = url.queryParameters['v'];
    final playlistId = url.queryParameters['list'];

    if (videoId == null || videoId.isEmpty) {
      AppToast.showMsg('Your link is invalid');
      return;
    }
    Get.toNamed(RouteConst.ytDownloader, arguments: {
      'url': url,
      'isPlaylist': playlistId != null,
    });
  }
}
