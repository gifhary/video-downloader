import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:video_downloader/common/utils/common_utils.dart';
import 'package:video_downloader/common/widget/app_image.dart';
import 'package:video_downloader/common/widget/duration_tag.dart';
import 'package:video_downloader/core/assets/app_asset.dart';
import 'package:video_downloader/core/style/app_shadow.dart';
import 'package:video_downloader/module/youtube_downloader/controller/youtube_downloader_controller.dart';
import 'package:video_downloader/module/youtube_downloader/widget/yt_quality_picker.dart';

class YoutubeDownloaderScreen extends StatelessWidget {
  const YoutubeDownloaderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final url = Get.arguments['url'] as Uri;

    return GetBuilder<YoutubeDownloaderController>(
      init: YoutubeDownloaderController(url),
      builder: (YoutubeDownloaderController controller) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: SvgPicture.asset(AppAsset.ytLogo),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 2),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: AppShadow.primary,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            AppImage(
                              controller.mainVid?.thumbnails.standardResUrl ??
                                  '',
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: DurationTag(controller.mainVid?.duration ??
                                  const Duration()),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    YtQualityPicker(),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Download'),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
