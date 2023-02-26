import 'dart:convert';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:video_downloader/core/network/app_network.dart';
import 'package:video_downloader/module/tt_downloader/data/model/tt_content_model.dart';

class TtDownloaderNetwork {
  final _networkClient = Get.find<AppNetworkClient>();

  Future<TtContentModel> getTiktokData(String url) async {
    try {
      final res = await _networkClient.get(url);

      final document = parse(res.data);
      final data = document.getElementById('SIGI_STATE')?.innerHtml;

      if (data == null) throw 'Failed getting content detail';

      final map = json.decode(data) as Map<String, dynamic>;

      final user = (map['UserModule']?['users'] as Map<String, dynamic>?)
          ?.values
          .first as Map<String, dynamic>?;
      final username = user?['uniqueId'] as String?;
      final profilePic = user?['avatarThumb'] as String?;

      final item = (map['ItemModule'] as Map<String, dynamic>?)?.values.first
          as Map<String, dynamic>?;
      final description = item?['desc'] as String?;
      final thumbnail = item?['video']?['cover'] as String?;
      final duration = item?['video']?['duration'] as int?;

      return TtContentModel(
        username: username ?? 'Unknown',
        profilePicUrl: profilePic ?? '',
        thumbnail: thumbnail ?? '',
        description: description ?? '',
        duration: Duration(seconds: duration ?? 0),
      );
    } catch (e) {
      rethrow;
    }
  }
}
