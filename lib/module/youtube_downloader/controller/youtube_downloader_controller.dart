import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_downloader/core/extension/video_quality_extension.dart';
import 'package:video_downloader/core/toast/app_toast.dart';
import 'package:video_downloader/module/youtube_downloader/data/repo/youtube_downloader_repo.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeDownloaderController extends GetxController
    with YoutubeDownloaderRepo {
  bool loading = false;
  bool error = false;
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
    initPage();
    super.onInit();
  }

  initPage() async {
    error = false;
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
      error = true;
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

  Future<File> _downloadAndWriteToFile(
      String filePath, StreamInfo streamInfo) async {
    //TODO make it background process
    try {
      final stream = ytExplode.videos.streamsClient.get(streamInfo);
      final file = File(filePath);
      final fileStream = file.openWrite();

      int progress = 0;
      await stream.map((event) {
        progress += event.length;
        debugPrint(
            '${((progress / streamInfo.size.totalBytes) * 100).toStringAsFixed(2)}%');
        return event;
      }).pipe(fileStream);

      await fileStream.flush();
      await fileStream.close();

      return file;
    } catch (e) {
      rethrow;
    }
  }

  downloadMainVid() async {
    try {
      if (mainVid == null) throw 'Missing video to download';
      AppToast.showMsg(
          'Downloading video in ${selectedMainVidQuality.value.quality}');

      final manifest =
          await ytExplode.videos.streamsClient.getManifest(mainVid!.id);

      final muxed = manifest.muxed.firstWhereOrNull(
          (element) => element.videoQuality == selectedMainVidQuality.value);

      final videoOnly = manifest.videoOnly.firstWhereOrNull(
          (element) => element.videoQuality == selectedMainVidQuality.value);
      final audioOnly = manifest.audioOnly.withHighestBitrate();

      late final File videoFile;

      muxed != null
          ? videoFile = await _downloadMuxedVideo(muxed)
          : videoOnly != null
              ? videoFile =
                  await _downloadSeparatedVideoAudio(videoOnly, audioOnly)
              : throw 'Failed getting the video';

      debugPrint('video: ${videoFile.path}');

      AppToast.showMsg('Video downloaded');
    } catch (e) {
      debugPrint('save mp4 error: $e');
      AppToast.showMsg(e.toString());
    }
  }

  Future<File> _downloadMuxedVideo(MuxedStreamInfo streamInfo) async {
    try {
      debugPrint('downloading muxed video');
      final downloadDir = await repGetContentSavingDirectory();

      return await _downloadAndWriteToFile(
          '${downloadDir.path}/${mainVid!.title} - ${mainVid!.author}.mp4',
          streamInfo);
    } catch (e) {
      rethrow;
    }
  }

  Future<File> _downloadSeparatedVideoAudio(
      VideoOnlyStreamInfo videoOnly, AudioOnlyStreamInfo? audioOnly) async {
    try {
      debugPrint('downloading separated video audio');
      if (audioOnly == null) {
        AppToast.showMsg(
            'Missing audio, video will be downloaded without the audio');
      }

      //put in temp dir if audio not null
      final dir = audioOnly != null
          ? await getTemporaryDirectory()
          : await repGetContentSavingDirectory();
      final path = audioOnly != null
          ? '${dir.path}/${mainVid!.id}'
          : '${dir.path}/${mainVid!.title} - ${mainVid!.author}';

      final video = await _downloadAndWriteToFile('$path.mp4', videoOnly);

      //return video in download dir if audio null
      if (audioOnly == null) return video;

      final audio = await _downloadAndWriteToFile('$path.mp3', audioOnly);

      final finalDir = await repGetContentSavingDirectory();
      return await repoMergeVideoAudio(video, audio,
          '${finalDir.path}/${mainVid!.title} - ${mainVid!.author}.mp4');
    } catch (e) {
      rethrow;
    }
  }

  downloadMainVidMp3() async {
    try {
      if (mainVid == null) throw 'Missing video to download';
      AppToast.showMsg('Downloading MP3');

      final manifest =
          await ytExplode.videos.streamsClient.getManifest(mainVid!.id);
      final streamInfo = manifest.audioOnly.withHighestBitrate();

      final downloadDir = await repGetContentSavingDirectory();

      final file = await _downloadAndWriteToFile(
          '${downloadDir.path}/${mainVid!.title} - ${mainVid!.author}.mp3',
          streamInfo);

      if (Platform.isAndroid &&
          downloadDir.path
              .contains((await PackageInfo.fromPlatform()).packageName)) {
        //if directory contains package name, it means android download dir does not exists
        Share.shareXFiles([XFile(file.path)]);
      }

      AppToast.showMsg('Audio downloaded');
    } catch (e) {
      debugPrint('save mp3 error: $e');
      AppToast.showMsg(e.toString());
    }
  }
}
