import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:video_downloader/common/widget/app_image.dart';
import 'package:video_downloader/common/widget/duration_tag.dart';
import 'package:video_downloader/core/assets/app_asset.dart';
import 'package:video_downloader/core/style/app_shadow.dart';
import 'package:video_downloader/module/tt_downloader/controller/tt_downloader_controller.dart';

class TtDownloaderScreen extends StatelessWidget {
  TtDownloaderScreen({super.key});

  final url = Get.arguments['url'] as Uri;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TtDownloaderController>(
      init: TtDownloaderController(url),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: SvgPicture.asset(
              AppAsset.ttLogo,
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
                          onPressed: () {},
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
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () => controller.launchTtProfile(
                                    controller.content?.username ?? ''),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: AppImage(
                                        controller.content?.profilePicUrl ?? '',
                                        height: 30,
                                        width: 30,
                                        placeholderSize: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(controller.content?.username ?? ''),
                                  ],
                                ),
                              ),
                            ),
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
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      AppImage(
                                        controller.content?.thumbnail ?? '',
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: DurationTag(
                                            controller.content?.duration ??
                                                const Duration()),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8, bottom: 16),
                              child: Text(
                                controller.content?.description ?? '',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
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
