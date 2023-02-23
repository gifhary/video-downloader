// ignore_for_file: library_prefixes

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';
import 'package:flutter/material.dart';
import 'package:video_downloader/module/insta_downloader/data/enum/insta_media_type.dart';
import 'package:video_downloader/module/insta_downloader/data/model/insta_content_model.dart';
import 'package:video_downloader/module/insta_downloader/data/network/insta_downloader_network.dart';

class InstaDownloaderRepo {
  final _myNetwork = InstaDownloaderNetwork();

  Future<String> repoGetUsername(String userId) async {
    try {
      return await _myNetwork.getUsername(userId);
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> repoParseWebViewRes(Object obj) {
    try {
      return Platform.isAndroid
          ? json.decode(json.decode(obj.toString()))
          : json.decode(obj.toString());
    } catch (e) {
      rethrow;
    }
  }

  InstaMediaType? repoGetMediaType(dynamic type) {
    switch (type) {
      case 1:
        return InstaMediaType.photo;
      case 2:
        return InstaMediaType.video;
      case 8:
        return InstaMediaType.carousel;
      case 'GraphImage':
        return InstaMediaType.photo;
      case 'GraphVideo':
        return InstaMediaType.video;
      case 'GraphSidecar':
        return InstaMediaType.carousel;
      case 'stories':
        return InstaMediaType.stories;
      default:
        return null;
    }
  }

  Future<File> repoExtreactAudio(String videoPath, String finalPath) async {
    try {
      final command = '-y -i "$videoPath" -q:a 0 -map a "$finalPath"';
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      final a = await session.getAllLogsAsString();
      debugPrint('log: $a');

      if (ReturnCode.isSuccess(returnCode)) {
        return File(finalPath);
      } else if (ReturnCode.isCancel(returnCode)) {
        throw 'Encoding cancelled';
      } else {
        throw 'Encoding audio failed';
      }
    } catch (e) {
      rethrow;
    }
  }

  ContentModel repoParseAnonPhoto(dynamic data) {
    final url = data['display_url'] as String?;
    final width = data['dimensions']['width'] as int?;
    final height = data['dimensions']['height'] as int?;

    if (url == null) throw 'Photo not found';

    return ContentModel(
      selectedResolution: null,
      thumbnail: url,
      sizeOptions: [],
      url: url,
      hasAudio: false,
      mediaType: InstaMediaType.photo,
      width: width ?? 0,
      height: height ?? 0,
    );
  }

  ContentModel repoParseAnonVideo(dynamic data) {
    final thumbnail = data['display_url'] as String?;
    final url = data['video_url'] as String?;
    final width = data['dimensions']['width'] as int?;
    final height = data['dimensions']['height'] as int?;
    final duration = data['video_duration'] as double?;
    final hasAudio = data['has_audio'] ?? true;

    if (url == null) throw 'Video not found';

    List<Size> splitSizes = [
      Size((width ?? 0).toDouble(), (height ?? 0).toDouble())
    ];

    for (double i = 1.5;
        (height ?? 0) / i > 144 && (width ?? 0) / i > 144;
        i + 1.5) {
      splitSizes.add(Size((width ?? 0) / i, (height ?? 0) / i));
    }

    return ContentModel(
      selectedResolution: splitSizes.length > 1
          ? splitSizes[splitSizes.length - 2]
          : splitSizes.first,
      sizeOptions: splitSizes,
      thumbnail: thumbnail ?? '',
      url: url,
      hasAudio: hasAudio,
      mediaType: InstaMediaType.video,
      videoDuration: Duration(seconds: duration?.round() ?? 0),
      width: width ?? 0,
      height: height ?? 0,
    );
  }

  ContentModel repoParseVideo(dynamic data) {
    final thumbnailVersions = data['image_versions2']['candidates'] as List?;
    final thumbnail = thumbnailVersions?.first['url'] as String?;

    final videoVersions = data['video_versions'] as List?;
    if (videoVersions == null || videoVersions.isEmpty) {
      throw 'Video not found';
    }
    final url = videoVersions.first['url'] as String?;
    final width = videoVersions.first['width'] as int?;
    final height = videoVersions.first['height'] as int?;
    final duration = data['video_duration'] as double?;
    final hasAudio = data['has_audio'] ?? true;

    if (url == null) throw 'Video not found';

    List<Size> splitSizes = [
      Size((width ?? 0).toDouble(), (height ?? 0).toDouble())
    ];

    for (double i = 1.5;
        (height ?? 0) / i >= 240 && (width ?? 0) / i >= 240;
        i += 1.5) {
      splitSizes.add(Size(((width ?? 0) / i), (height ?? 0) / i));
    }
    splitSizes.sort((a, b) => a.width.compareTo(b.width));

    return ContentModel(
      selectedResolution: splitSizes.length > 1
          ? splitSizes[splitSizes.length - 2]
          : splitSizes.first,
      sizeOptions: splitSizes,
      thumbnail: thumbnail ?? '',
      url: url,
      hasAudio: hasAudio,
      mediaType: InstaMediaType.video,
      videoDuration: Duration(seconds: duration?.round() ?? 0),
      width: width ?? 0,
      height: height ?? 0,
    );
  }

  ContentModel repoParsePhoto(dynamic data) {
    final imageVersions = data['image_versions2']['candidates'] as List?;
    if (imageVersions == null || imageVersions.isEmpty) {
      throw 'Photo not found';
    }
    final url = imageVersions.first['url'] as String?;
    final width = imageVersions.first['width'] as int?;
    final height = imageVersions.first['height'] as int?;

    if (url == null) throw 'Photo not found';

    return ContentModel(
      selectedResolution: null,
      sizeOptions: [],
      thumbnail: url,
      hasAudio: false,
      url: url,
      mediaType: InstaMediaType.photo,
      width: width ?? 0,
      height: height ?? 0,
    );
  }

  String repoGetPostId(String postUrl) {
    final exp =
        RegExp(r'(?:https?:\/\/www\.)?instagram\.com\S*?\/p\/(\w{11})\/?');
    return exp.allMatches(postUrl).first.group(1) ?? '';
  }

  Future<Response<dynamic>> repoDownload(
    Uri uri,
    String savePath, {
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _myNetwork.download(uri, savePath,
          onReceiveProgress: onReceiveProgress);
    } catch (e) {
      rethrow;
    }
  }
}
