import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:video_downloader/common/widget/app_image.dart';
import 'package:video_downloader/core/assets/app_asset.dart';
import 'package:video_downloader/module/insta_downloader/controller/insta_downloader_controller.dart';
import 'package:video_downloader/module/insta_downloader/data/enum/insta_media_type.dart';
import 'package:video_downloader/module/insta_downloader/widget/media_type_photo_display.dart';

class InstaDownloaderScreen extends StatelessWidget {
  InstaDownloaderScreen({Key? key}) : super(key: key);
  final url = Get.arguments['url'] as Uri;

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: Builder(builder: (context) {
        return GetBuilder<InstaDownloaderController>(
          init: InstaDownloaderController(url, context),
          builder: (InstaDownloaderController controller) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: false,
                title: SvgPicture.asset(
                  AppAsset.instaLogo,
                  height: 24,
                ),
                actions: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Showcase(
                        key: controller.showcaseKey,
                        description: controller.loginShowCaseText,
                        child: InkWell(
                          onTap: controller.loginInsta,
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Log in',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              body: SafeArea(
                child: controller.loading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : controller.error
                        ? Center(
                            child: SizedBox(
                              width: 120,
                              child: ElevatedButton(
                                onPressed: controller.initDataFromWebview,
                                child: const Text('Try Again'),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GestureDetector(
                                    onTap: () => controller.launchInstaProfile(
                                        controller.content.author ?? ''),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: AppImage(
                                            controller
                                                    .content.authorProfilePic ??
                                                '',
                                            height: 30,
                                            width: 30,
                                            placeholderSize: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(controller.content.author ?? ''),
                                      ],
                                    ),
                                  ),
                                ),
                                Builder(builder: (context) {
                                  if (controller.content.mediaType ==
                                          InstaMediaType.photo ||
                                      controller.content.mediaType ==
                                          InstaMediaType.video) {
                                    return MediaTypePhotoDisplay(
                                        onQualitySelected: controller
                                            .onSingleVidQualitySelected,
                                        selectedQuality: controller.content
                                            .photoOrVideo?.selectedResolution,
                                        hasAudio: controller
                                            .content.photoOrVideo?.hasAudio,
                                        duration: controller.content
                                            .photoOrVideo?.videoDuration,
                                        type: controller.content.mediaType,
                                        qualities: controller.content
                                                .photoOrVideo?.sizeOptions ??
                                            [],
                                        onDownload: controller.content.photoOrVideo != null
                                            ? () => controller.downloadMedia(
                                                controller
                                                    .content.photoOrVideo!)
                                            : null,
                                        onDownloadAudio:
                                            controller.content.photoOrVideo != null
                                                ? () => controller.downloadMedia(
                                                    controller.content.photoOrVideo!,
                                                    audioOnly: true)
                                                : null,
                                        url: controller.content.photoOrVideo?.thumbnail ?? '',
                                        height: controller.content.photoOrVideo?.height.toInt() ?? 0,
                                        width: controller.content.photoOrVideo?.width.toInt() ?? 0);
                                  }

                                  if (controller.content.mediaType ==
                                          InstaMediaType.carousel ||
                                      controller.content.mediaType ==
                                          InstaMediaType.stories) {
                                    return Flexible(
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: controller
                                                .content.carouselContent
                                                ?.map((e) => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 24),
                                                      child:
                                                          MediaTypePhotoDisplay(
                                                        onQualitySelected: (quality) =>
                                                            controller.onCarouselVidQualitySelected(
                                                                controller
                                                                        .content
                                                                        .carouselContent
                                                                        ?.indexOf(
                                                                            e) ??
                                                                    -1,
                                                                quality),
                                                        duration:
                                                            e.videoDuration,
                                                        selectedQuality: e
                                                            .selectedResolution,
                                                        hasAudio: e.hasAudio,
                                                        type: e.mediaType,
                                                        qualities:
                                                            e.sizeOptions,
                                                        onDownload: () =>
                                                            controller
                                                                .downloadMedia(
                                                                    e),
                                                        onDownloadAudio: () =>
                                                            controller
                                                                .downloadMedia(
                                                                    e,
                                                                    audioOnly:
                                                                        true),
                                                        url: e.thumbnail,
                                                        height:
                                                            e.height.toInt(),
                                                        width: e.width.toInt(),
                                                      ),
                                                    ))
                                                .toList() ??
                                            [],
                                      ),
                                    );
                                  }

                                  return Container();
                                }),
                              ],
                            ),
                          ),
              ),
            );
          },
        );
      }),
    );
  }
}
