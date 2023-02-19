import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:video_downloader/common/widget/app_image.dart';
import 'package:video_downloader/core/assets/app_asset.dart';
import 'package:video_downloader/module/insta_downloader/controller/insta_downloader_controller.dart';

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
                        description:
                            'Consider log in if you\'re having trouble getting the content or its from a private account',
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
              body: controller.loading
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
                      : Column(
                          children: [
                            SizedBox(
                              height: 400,
                              child: Center(
                                child: AppImage(controller
                                        .content.photoOrVideo?.thumbnail ??
                                    ''),
                              ),
                            ),
                            Text(
                                '${controller.content.photoOrVideo?.width} x ${controller.content.photoOrVideo?.height}')
                          ],
                        ),
            );
          },
        );
      }),
    );
  }
}
