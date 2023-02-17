import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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
      mainVid = await ytExplode.videos.get(_url);
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
    try {
      if (mainVid == null) throw 'MP3 cannot be downloaded';
      AppToast.showMsg('Downloading MP3');

      bool androidDownloadDirExists = true;

      final manifest =
          await ytExplode.videos.streamsClient.getManifest(mainVid!.id);
      final streamInfo = manifest.audioOnly.withHighestBitrate();
      final stream = ytExplode.videos.streamsClient.get(streamInfo);

      late Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = Directory('/storage/emulated/0/Download');
        if (!await downloadDir.exists()) {
          androidDownloadDirExists = false;
          downloadDir = (await getExternalStorageDirectories())?.first;
        }
      } else if (Platform.isIOS) {
        downloadDir = await getApplicationDocumentsDirectory();
      }
      if (downloadDir == null) throw 'Failed accessing phone directory';

      final file = File(
          '${downloadDir.path}/${mainVid!.title} - ${mainVid!.author}.mp3');
      final fileStream = file.openWrite();

      int progress = 0;
      await stream.map((event) {
        progress += event.length;
        debugPrint('${(progress / streamInfo.size.totalBytes) * 100}%');
        return event;
      }).pipe(fileStream);

      await fileStream.flush();
      await fileStream.close();

      if (!androidDownloadDirExists) Share.shareXFiles([XFile(file.path)]);

      AppToast.showMsg('MP3 downloaded');
    } catch (e) {
      debugPrint('save mp3 error: $e');
      AppToast.showMsg(e.toString());
    }
  }
}
