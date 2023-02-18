import 'package:video_downloader/module/insta_downloader/data/network/insta_downloader_network.dart';

class InstaDownloaderRepo {
  final _myNetwork = InstaDownloaderNetwork();

  Future<dynamic> repoGetPostData(Uri url) async {
    try {
      return await _myNetwork.getPostData(url);
    } catch (e) {
      rethrow;
    }
  }
}
