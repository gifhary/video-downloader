import 'package:get/route_manager.dart';
import 'package:video_downloader/module/home/screen/home_screen.dart';
import 'package:video_downloader/core/route/route_const.dart';
import 'package:video_downloader/module/youtube_downloader/screen/youtube_downloader_screen.dart';

class AppRoute {
  static final all = [
    GetPage(name: RouteConst.home, page: () => const HomeScreen()),
    GetPage(
        name: RouteConst.ytDownloader, page: () => YoutubeDownloaderScreen()),
  ];
}
