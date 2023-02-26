import 'package:video_downloader/module/tt_downloader/data/model/tt_content_model.dart';
import 'package:video_downloader/module/tt_downloader/data/network/tt_downloader_network.dart';

class TtDownloaderRepo {
  final _myNetwork = TtDownloaderNetwork();
  Future<TtContentModel> repoGetTiktokData(String url) async {
    try {
      return await _myNetwork.getTiktokData(url);
    } catch (e) {
      rethrow;
    }
  }
}
