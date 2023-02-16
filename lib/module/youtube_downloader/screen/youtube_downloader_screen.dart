import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:video_downloader/common/widget/app_image.dart';
import 'package:video_downloader/common/widget/duration_tag.dart';
import 'package:video_downloader/core/assets/app_asset.dart';
import 'package:video_downloader/core/style/app_shadow.dart';
import 'package:video_downloader/module/youtube_downloader/controller/youtube_downloader_controller.dart';
import 'package:video_downloader/module/youtube_downloader/widget/list_video_item.dart';
import 'package:video_downloader/module/youtube_downloader/widget/yt_quality_picker.dart';

class YoutubeDownloaderScreen extends StatelessWidget {
  YoutubeDownloaderScreen({Key? key}) : super(key: key);
  final url = Get.arguments['url'] as Uri;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<YoutubeDownloaderController>(
      init: YoutubeDownloaderController(url),
      builder: (YoutubeDownloaderController controller) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: SvgPicture.asset(AppAsset.ytLogo),
          ),
          body: controller.loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: controller.playList.isNotEmpty
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: controller.mainVid != null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.green, width: 2),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: AppShadow.primary,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        AppImage(
                                          controller.mainVid?.thumbnails
                                                  .highResUrl ??
                                              '',
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: DurationTag(
                                              controller.mainVid?.duration ??
                                                  const Duration()),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8, bottom: 16),
                              child: Text(
                                controller.mainVid?.title ?? '',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(
                                  () => YtQualityPicker(
                                    quality:
                                        controller.selectedMainVidQuality.value,
                                    qualities: controller.mainVidQualities,
                                    onSelected: (quality) => controller
                                        .selectedMainVidQuality.value = quality,
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: ElevatedButton(
                                    onPressed: controller.downloadMainVid,
                                    child: const Icon(
                                        Icons.file_download_outlined),
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: ElevatedButton(
                                    onPressed: controller.downloadMainVidMp3,
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
                              ],
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: controller.playList.isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: Text(
                            'Other video in the list',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                      Flexible(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          shrinkWrap: true,
                          itemCount: controller.playList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ListVideoItem(
                                thumbnail: controller
                                    .playList[index].thumbnails.mediumResUrl,
                                title: controller.playList[index].title,
                                duration: controller.playList[index].duration ??
                                    const Duration(),
                                downloadProgress: index % 2 == 0 ? 0.2 : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
