import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:video_downloader/core/network/app_network.dart';
import 'package:video_downloader/module/insta_downloader/data/enum/insta_media_type.dart';
import 'package:video_downloader/module/insta_downloader/data/model/insta_content_model.dart';
import 'package:video_downloader/module/insta_downloader/data/repo/insta_downloader_repo.dart';

class InstaDownloaderNetwork {
  final _networkClient = Get.find<AppNetworkClient>();

  Future<InstaContentModel> getUserStories(String userId) async {
    try {
      final repo = InstaDownloaderRepo();
      final res = await _networkClient.get(
          'https://www.instagram.com/api/v1/feed/reels_media/?reel_ids=$userId');

      final map = res.data as Map<String, dynamic>;

      final content = InstaContentModel(
          authorProfilePic:
              map['reels'][userId]['user']['profile_pic_url'] as String?,
          authorId: userId,
          author: map['reels'][userId]['user']['username'] as String?,
          mediaType: InstaMediaType.stories,
          carouselContent: (map['reels'][userId]['items'] as List?)?.map((e) {
            final mediaType = repo.repoGetMediaType(e['media_type']);

            if (mediaType == InstaMediaType.photo) {
              return repo.repoParsePhoto(e);
            } else if (mediaType == InstaMediaType.video) {
              return repo.repoParseVideo(e);
            } else {
              throw 'Invalid media type';
            }
          }).toList());

      return content;
    } catch (e) {
      rethrow;
    }
  }

  Future<InstaContentModel> getUserHighlightStories(String highlightId) async {
    try {
      final repo = InstaDownloaderRepo();
      final reelsId = 'highlight:$highlightId';

      final res = await _networkClient.get(
          'https://www.instagram.com/api/v1/feed/reels_media/?reel_ids=$reelsId');

      final map = res.data as Map<String, dynamic>;

      final content = InstaContentModel(
          authorProfilePic:
              map['reels'][reelsId]['user']['profile_pic_url'] as String?,
          authorId: map['reels'][reelsId]['user']['pk_id'] as String?,
          author: map['reels'][reelsId]['user']['username'] as String?,
          mediaType: InstaMediaType.stories,
          carouselContent: (map['reels'][reelsId]['items'] as List?)?.map((e) {
            final mediaType = repo.repoGetMediaType(e['media_type']);

            if (mediaType == InstaMediaType.photo) {
              return repo.repoParsePhoto(e);
            } else if (mediaType == InstaMediaType.video) {
              return repo.repoParseVideo(e);
            } else {
              throw 'Invalid media type';
            }
          }).toList());

      return content;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getUsername(String userId) async {
    try {
      final res = await _networkClient.get(
        'https://i.instagram.com/api/v1/users/$userId/info',
      );

      return res.data['user']['username'];
    } catch (e) {
      rethrow;
    }
  }

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
