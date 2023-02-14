import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:video_downloader/core/assets/app_asset.dart';
import 'package:video_downloader/module/youtube_downloader/controller/youtube_downloader_controller.dart';

class YoutubeDownloaderScreen extends StatelessWidget {
  const YoutubeDownloaderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final url = Get.arguments['url'] as Uri;
    final isPLaylist = Get.arguments['isPlaylist'] as bool;

    return GetBuilder<YoutubeDownloaderController>(
      init: YoutubeDownloaderController(),
      builder: (YoutubeDownloaderController controller) {
        return Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(AppAsset.ytLogo),
              Text('url: $url'),
              Text('Playlist: $isPLaylist'),
            ],
          ),
        );
      },
    );
  }
}
