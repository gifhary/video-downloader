import 'dart:io';

import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';
import 'package:flutter/material.dart';

class YoutubeDownloaderRepo {
  Future<File> repoMergeVideoAudio(
      File video, File audio, String finalPath) async {
    try {
      final command =
          '-y -i "${video.path}" -i "${audio.path}" -map 0:v -map 1:a -c:v copy -shortest "$finalPath"';
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      final a = await session.getAllLogsAsString();
      debugPrint('log: $a');

      if (ReturnCode.isSuccess(returnCode)) {
        return File(finalPath);
      } else if (ReturnCode.isCancel(returnCode)) {
        throw 'Encoding cancelled';
      } else {
        throw 'Encoding video failed';
      }
    } catch (e) {
      rethrow;
    }
  }
}
