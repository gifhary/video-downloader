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
  late Rx<VideoQuality> selectedMainVidQuality;
  List<VideoQuality> mainVidQualities = [];

  String? playListTitle;
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
        if (mainVid?.isLive ?? true) {
          Get.back();
          await Future.delayed(const Duration(milliseconds: 200));
          throw 'Live video is not downloadable';
        }
        mainVidQualities = await _getVideoQualities(mainVid!);

        final higestMuxedQuality = await _getHighestMuxedQuality(mainVid!);

        if (mainVidQualities.indexOf(higestMuxedQuality) > 0) {
          selectedMainVidQuality =
              mainVidQualities[mainVidQualities.indexOf(higestMuxedQuality) - 1]
                  .obs;
        } else {
          selectedMainVidQuality = higestMuxedQuality.obs;
        }
      }

      if (_url.queryParameters['list'] != null) {
        final ytplaylist =
            await ytExplode.playlists.get(_url.queryParameters['list']);
        playListTitle = ytplaylist.title;
        await for (var vid
            in ytExplode.playlists.getVideos(_url.queryParameters['list'])) {
          if (vid.id != mainVid?.id && !vid.isLive) {
            playList.add(vid);
            update();
          }
        }
      }
    } catch (e) {
      debugPrint('init error: $e');
      AppToast.showMsg('Something went wrong, please try again later',
          toastLength: Toast.LENGTH_LONG);
    }
    loading = false;
    update();
  }

  Future<VideoQuality> _getHighestMuxedQuality(Video video) async {
    final manifest = await ytExplode.videos.streamsClient.getManifest(video.id);
    return manifest.muxed.withHighestBitrate().videoQuality;
  }

  Future<List<VideoQuality>> _getVideoQualities(Video video) async {
    final manifest = await ytExplode.videos.streamsClient.getManifest(video.id);

    final qualities = manifest.video.getAllVideoQualities().toList();
    qualities.sort((a, b) => a.index.compareTo(b.index));

    return qualities;
  }

  @override
  onClose() {
    ytExplode.close();
    super.onClose();
  }

  downloadMainVid() async {
    if (mainVid == null) return;
  }

  downloadMainVidMp3() async {
    if (mainVid == null) return;
  }
}
