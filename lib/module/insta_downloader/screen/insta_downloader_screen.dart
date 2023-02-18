import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:video_downloader/core/assets/app_asset.dart';
import 'package:video_downloader/module/insta_downloader/controller/insta_downloader_controller.dart';

class InstaDownloaderScreen extends StatelessWidget {
  InstaDownloaderScreen({Key? key}) : super(key: key);
  final url = Get.arguments['url'] as Uri;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InstaDownloaderController>(
      init: InstaDownloaderController(),
      builder: (InstaDownloaderController controller) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: SvgPicture.asset(AppAsset.ytLogo),
          ),
        );
      },
    );
  }
}
