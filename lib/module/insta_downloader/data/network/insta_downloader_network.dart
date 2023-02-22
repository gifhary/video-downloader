import 'package:video_downloader/core/network/app_network.dart';
import 'package:video_downloader/module/insta_downloader/data/constant/insta_downloader_constant.dart';

class InstaDownloaderNetwork {
  Future<String> getUsername(String userId) async {
    try {
      final res = await AppNetworkClient.get(
          'https://i.instagram.com/api/v1/users/$userId/info',
          customHeader: {
            'User-Agent': InstaDownloaderConstant.customUserAgent,
          });
      return res.data['user']['username'];
    } catch (e) {
      rethrow;
    }
  }
}
