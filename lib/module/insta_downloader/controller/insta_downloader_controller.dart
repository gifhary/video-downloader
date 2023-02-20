import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:video_downloader/common/widget/app_bottom_sheet.dart';
import 'package:video_downloader/core/toast/app_toast.dart';
import 'package:video_downloader/module/insta_downloader/data/constant/insta_downloader_constant.dart';
import 'package:video_downloader/module/insta_downloader/data/enum/insta_media_type.dart';
import 'package:video_downloader/module/insta_downloader/data/model/insta_content_model.dart';
import 'package:video_downloader/module/insta_downloader/data/repo/insta_downloader_repo.dart';
import 'package:video_downloader/module/insta_downloader/screen/insta_login_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InstaDownloaderController extends GetxController
    with InstaDownloaderRepo {
  bool loading = false;
  bool error = false;
  final BuildContext context;

  final showcaseKey = GlobalKey();

  final Uri _url;

  final webCtrl = WebViewController();

  late InstaContentModel content;

  InstaDownloaderController(this._url, this.context);

  @override
  void onInit() {
    initDataFromWebview();
    _initShowcase();
    super.onInit();
  }

  _initShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    final loginShowcaseShowed =
        prefs.getBool(InstaDownloaderConstant.loginShowcaseShowed) ?? false;

    if (!loginShowcaseShowed) {
      Future.delayed(const Duration(seconds: 5),
          () => ShowCaseWidget.of(context).startShowCase([showcaseKey]));
      prefs.setBool(InstaDownloaderConstant.loginShowcaseShowed, true);
    }
  }

  initDataFromWebview() async {
    loading = true;
    error = false;
    update();
    try {
      await webCtrl.setJavaScriptMode(JavaScriptMode.unrestricted);
      await webCtrl
          .loadRequest(Uri.parse('${_url.origin + _url.path}?__a=1&__d=dis'));
      await webCtrl.setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) async {
          final res = await webCtrl.runJavaScriptReturningResult(
              "document.documentElement.innerText");

          final map = json.decode(res.toString());

          //logged in and anon user, insta return different object structure
          if (map['graphql']['shortcode_media'] != null) {
            //for anon user, this will execute
            _parseAnonMedia(map);
          } else if (map['items'] != null) {
            //for logged in user, this will execute
            _parseMedia(map);
          }
        },
      ));
    } catch (e) {
      debugPrint('error: $e');
      loading = false;
      error = true;
      update();
      AppToast.showMsg('Something went wrong, please try again later',
          toastLength: Toast.LENGTH_LONG);
    }
  }

  _parseAnonMedia(dynamic map) {
    try {
      final graphQlData = map['graphql']['shortcode_media'];
      if (graphQlData == null) throw 'Content not found';

      final mediaType = _getMediaType(graphQlData['__typename']);
      if (mediaType == null) throw 'Unsupported media type';

      final author = graphQlData['owner']['username'];

      ContentModel? photoOrVideo;

      if (mediaType == InstaMediaType.photo) {
        photoOrVideo = _parseAnonPhoto(graphQlData);
      } else if (mediaType == InstaMediaType.video) {
        photoOrVideo = _parseAnonVideo(graphQlData);
      }

      List<ContentModel>? carousel;
      if (mediaType == InstaMediaType.carousel) {
        carousel = _parseAnonCarousel(graphQlData);
      }

      content = InstaContentModel(
        author: author,
        mediaType: mediaType,
        photoOrVideo: photoOrVideo,
        carouselContent: carousel,
      );
      log('anon content: $content');
    } catch (e) {
      debugPrint('error anon parsing: $e');
      AppToast.showMsg(e.toString(), toastLength: Toast.LENGTH_LONG);
      error = true;
    }
    loading = false;
    update();
  }

  ContentModel _parseAnonPhoto(dynamic data) {
    final url = data['display_url'] as String?;
    final width = data['dimensions']['width'] as int?;
    final height = data['dimensions']['height'] as int?;

    if (url == null) throw 'Photo not found';

    return ContentModel(
      thumbnail: url,
      url: url,
      hasAudio: false,
      mediaType: InstaMediaType.photo,
      width: width ?? 0,
      height: height ?? 0,
    );
  }

  ContentModel _parseAnonVideo(dynamic data) {
    final thumbnail = data['display_url'] as String?;
    final url = data['video_url'] as String?;
    final width = data['dimensions']['width'] as int?;
    final height = data['dimensions']['height'] as int?;
    final duration = data['video_duration'] as double?;
    final hasAudio = data['has_audio'] ?? false;

    if (url == null) throw 'Video not found';

    return ContentModel(
      thumbnail: thumbnail ?? '',
      url: url,
      hasAudio: hasAudio,
      mediaType: InstaMediaType.video,
      videoDuration: Duration(seconds: duration?.round() ?? 0),
      width: width ?? 0,
      height: height ?? 0,
    );
  }

  List<ContentModel> _parseAnonCarousel(dynamic data) {
    List<ContentModel> carousel = [];
    final dataList = data['edge_sidecar_to_children']['edges'] as List?;

    if (dataList == null || dataList.isEmpty) throw 'Contents not found';

    for (var e in dataList) {
      final node = e['node'];

      debugPrint(node.toString());

      final mediaType = _getMediaType(node['__typename']);

      ContentModel? content;
      if (mediaType == InstaMediaType.photo) {
        content = _parseAnonPhoto(node);
      } else if (mediaType == InstaMediaType.video) {
        content = _parseAnonVideo(node);
      }

      if (content != null) {
        carousel.add(content);
      }
    }

    return carousel;
  }

  _parseMedia(dynamic map) {
    try {
      final items = (map['items'] as List?)?.map((e) => e).toList();
      if (items == null || items.isEmpty) throw 'Content not found';

      final mediaType = _getMediaType(items.first['media_type']);
      if (mediaType == null) throw 'Unsupported media type';
      final author = items.first['user']['username'];

      ContentModel? photoOrVideo;

      if (mediaType == InstaMediaType.photo) {
        photoOrVideo = _parsePhoto(items.first);
      } else if (mediaType == InstaMediaType.video) {
        photoOrVideo = _parseVideo(items.first);
      }

      List<ContentModel>? carousel;
      if (mediaType == InstaMediaType.carousel) {
        carousel = _parseCarousel(items.first);
      }

      content = InstaContentModel(
        author: author,
        mediaType: mediaType,
        photoOrVideo: photoOrVideo,
        carouselContent: carousel,
      );
      log('content: $content');
    } catch (e) {
      debugPrint('error parsing: $e');
      AppToast.showMsg(e.toString(), toastLength: Toast.LENGTH_LONG);
      error = true;
    }
    loading = false;
    update();
  }

  List<ContentModel> _parseCarousel(dynamic data) {
    List<ContentModel> carousel = [];
    final dataList = data['carousel_media'] as List?;

    if (dataList == null || dataList.isEmpty) throw 'Contents not found';

    for (var e in dataList) {
      final mediaType = _getMediaType(e['media_type']);

      ContentModel? content;
      if (mediaType == InstaMediaType.photo) {
        content = _parsePhoto(e);
      } else if (mediaType == InstaMediaType.video) {
        content = _parseVideo(e);
      }

      if (content != null) {
        carousel.add(content);
      }
    }

    return carousel;
  }

  ContentModel _parseVideo(dynamic data) {
    final thumbnailVersions = data['image_versions2']['candidates'] as List?;
    final thumbnail = thumbnailVersions?.first['url'] as String?;

    final videoVersions = data['video_versions'] as List?;
    if (videoVersions == null || videoVersions.isEmpty) {
      throw 'Video not found';
    }
    final url = videoVersions.first['url'] as String?;
    final width = videoVersions.first['width'] as int?;
    final height = videoVersions.first['height'] as int?;
    final duration = data['video_duration'] as double?;
    final hasAudio = data['has_audio'] ?? false;

    if (url == null) throw 'Video not found';

    return ContentModel(
      thumbnail: thumbnail ?? '',
      url: url,
      hasAudio: hasAudio,
      mediaType: InstaMediaType.video,
      videoDuration: Duration(seconds: duration?.round() ?? 0),
      width: width ?? 0,
      height: height ?? 0,
    );
  }

  ContentModel _parsePhoto(dynamic data) {
    final imageVersions = data['image_versions2']['candidates'] as List?;
    if (imageVersions == null || imageVersions.isEmpty) {
      throw 'Photo not found';
    }
    final url = imageVersions.first['url'] as String?;
    final width = imageVersions.first['width'] as int?;
    final height = imageVersions.first['height'] as int?;

    if (url == null) throw 'Photo not found';

    return ContentModel(
      thumbnail: url,
      hasAudio: false,
      url: url,
      mediaType: InstaMediaType.photo,
      width: width ?? 0,
      height: height ?? 0,
    );
  }

  InstaMediaType? _getMediaType(dynamic type) {
    switch (type) {
      case 1:
        return InstaMediaType.photo;
      case 2:
        return InstaMediaType.video;
      case 8:
        return InstaMediaType.carousel;
      case 'GraphImage':
        return InstaMediaType.photo;
      case 'GraphVideo':
        return InstaMediaType.video;
      case 'GraphSidecar':
        return InstaMediaType.carousel;
      default:
        return null;
    }
  }

  loginInsta() async {
    await AppBottomSheet.show(InstaLoginScreen());
    initDataFromWebview();
  }
}
