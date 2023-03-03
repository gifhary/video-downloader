import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:video_downloader/core/network/app_network.dart';

class TwitterDownloaderNetwork {
  final _networkClient = Get.find<AppNetworkClient>();

  Future<dio.Response<dynamic>> download(
    Uri uri,
    String savePath, {
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _networkClient.download(uri, savePath,
          onReceiveProgress: onReceiveProgress);
    } catch (e) {
      rethrow;
    }
  }
}
