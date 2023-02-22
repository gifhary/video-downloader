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
}
