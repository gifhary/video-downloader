import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';
import 'package:flutter/material.dart';
import 'package:video_downloader/module/tt_downloader/data/model/tt_content_model.dart';
import 'package:video_downloader/module/tt_downloader/data/network/tt_downloader_network.dart';

class TtDownloaderRepo {
  final _myNetwork = TtDownloaderNetwork();

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

  Future<TtContentModel> repoGetTiktokData(String url) async {
    try {
      return await _myNetwork.getTiktokData(url);
    } catch (e) {
      rethrow;
    }
  }
}
