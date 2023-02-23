// ignore_for_file: library_prefixes

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';
import 'package:flutter/material.dart';
import 'package:video_downloader/module/insta_downloader/data/network/insta_downloader_network.dart';

class InstaDownloaderRepo {
  final _myNetwork = InstaDownloaderNetwork();

  Future<String> repoGetUserId(String userId) async {
    try {
      return await _myNetwork.getUsername(userId);
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
