import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:video_downloader/common/widget/app_image.dart';
import 'package:video_downloader/core/assets/app_asset.dart';
import 'package:video_downloader/core/style/app_shadow.dart';
import 'package:video_downloader/module/twitter_downloader/controller/twitter_downloader_controller.dart';

class TwitterDownloaderScreen extends StatelessWidget {
  TwitterDownloaderScreen({super.key});

  final url = Get.arguments['url'] as Uri;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TwitterDownloaderController>(
      init: TwitterDownloaderController(url),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: SvgPicture.asset(
              AppAsset.twitterLogo,
              height: 24,
            ),
          ),
          body: controller.loadingDownloadUrl ||
                  controller.loadingContentDetails
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : controller.error
                  ? Center(
                      child: SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: controller.initData,
                          child: const Text('Try Again'),
                        ),
                      ),
                    )
                  : Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 12 / 16,
                              child: Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.green, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: AppShadow.primary,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      AppImage(
                                        controller.thumbnail ?? '',
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            shape: BoxShape.circle),
                                        child: const Icon(
                                          Icons.videocam,
                                          size: 30,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: controller.title != null,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  controller.title ?? '',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Flexible(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        controller.downloadContent(true),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.file_download_outlined),
                                        SizedBox(width: 5),
                                        Text('MP3'),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Flexible(
                                  child: ElevatedButton(
                                    onPressed: controller.downloadContent,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.file_download_outlined),
                                        SizedBox(width: 5),
                                        Text('MP4'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
        );
      },
    );
  }
}
