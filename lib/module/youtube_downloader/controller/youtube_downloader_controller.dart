import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:video_downloader/core/toast/app_toast.dart';
import 'package:video_downloader/module/youtube_downloader/data/repo/youtube_downloader_repo.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeDownloaderController extends GetxController
    with YoutubeDownloaderRepo {
  bool loading = false;
  final ytExplode = YoutubeExplode();

  final Uri _url;
  Video? mainVid;
  List<Video> playList = [];

  YoutubeDownloaderController(this._url);

  @override
  void onInit() {
    _initPage();
    super.onInit();
  }

  _initPage() async {
    loading = true;
    update();
    try {
      if (_url.queryParameters['v'] != null) {
        mainVid = await ytExplode.videos.get(_url.queryParameters['v']);
      }

      if (_url.queryParameters['list'] != null) {
        await for (var vid
            in ytExplode.playlists.getVideos(_url.queryParameters['list'])) {
          playList.add(vid);
          update();
        }
      }
      debugPrint(playList.length.toString());
    } catch (e) {
      debugPrint('init error: $e');
      AppToast.showMsg(e.toString(), toastLength: Toast.LENGTH_LONG);
    }
    loading = false;
    update();
  }
}
