import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_downloader/common/constant/common_const.dart';
import 'package:video_downloader/core/route/route_const.dart';
import 'package:video_downloader/core/toast/app_toast.dart';
import 'package:video_downloader/module/home/data/repo/home_repo.dart';
import 'package:validators/validators.dart';

class HomeController extends GetxController with HomeRepo {
  final mainTextFieldCtrl = TextEditingController();

  @override
  void onInit() {
    // Future.delayed(
    //   const Duration(seconds: 2),
    //   () async {
    //     if (!(await Permission.storage.isGranted)) {
    //       final status = await Permission.storage.request();
    //       debugPrint('status: $status');
    //     }
    //   },
    // );
    super.onInit();
  }

  download() {
    try {
      String urlStr = mainTextFieldCtrl.text;

      if (!urlStr.contains('http')) urlStr = 'https://$urlStr';
      if (!isURL(urlStr)) throw 'Link invalid';

      final url = Uri.parse(urlStr);
      switch (url.host.replaceAll('www.', '')) {
        case CommonConst.ytDomain:
          _goToYtDownloader(url);
          break;
        case CommonConst.ytShortDomain:
          _goToYtDownloader(url);
          break;
        case CommonConst.igDomain:
          _goToInstaDownloader(url);
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

  _goToInstaDownloader(Uri url) {
    Get.toNamed(RouteConst.instaDownloader, arguments: {'url': url});
  }

  _goToYtDownloader(Uri url) {
    Get.toNamed(RouteConst.ytDownloader, arguments: {'url': url});
  }
}
