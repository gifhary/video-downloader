import 'package:get/get.dart';
import 'package:video_downloader/core/toast/app_toast.dart';
import 'package:video_downloader/module/youtube_downloader/data/repo/youtube_downloader_repo.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeDownloaderController extends GetxController
    with YoutubeDownloaderRepo {
  final ytExplode = YoutubeExplode();

  final Uri _url;
  Video? mainVid;

  YoutubeDownloaderController(this._url);

  @override
  void onInit() {
    _initPage();
    super.onInit();
  }

  _initPage() async {
    try {
      mainVid = await ytExplode.videos.get(_url.toString());
    } catch (e) {
      AppToast.showMsg('msg');
    }
    update();
  }
}
