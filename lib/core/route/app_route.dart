import 'package:get/route_manager.dart';
import 'package:video_downloader/module/home/screen/home_screen.dart';
import 'package:video_downloader/core/route/route_const.dart';
import 'package:video_downloader/module/insta_downloader/screen/insta_downloader_screen.dart';
import 'package:video_downloader/module/insta_downloader/screen/insta_login_screen.dart';
import 'package:video_downloader/module/youtube_downloader/screen/youtube_downloader_screen.dart';

class AppRoute {
  static final all = [
    GetPage(name: RouteConst.home, page: () => const HomeScreen()),
    GetPage(
        name: RouteConst.ytDownloader, page: () => YoutubeDownloaderScreen()),
    GetPage(
        name: RouteConst.instaDownloader, page: () => InstaDownloaderScreen()),
    GetPage(name: RouteConst.instaLogin, page: () => InstaLoginScreen())
  ];
}
