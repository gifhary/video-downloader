import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_downloader/common/utils/common_utils.dart';
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
  void onInit() async {
    initDataFromWebview();
    _initShowcase();
    super.onInit();
  }

  launchInstaProfile(String username) async {
    debugPrint(
        'launching: ${InstaDownloaderConstant.instaProfileUrl(username)}');
    if (!await launchUrl(
        Uri.parse(InstaDownloaderConstant.instaProfileUrl(username)))) {
      debugPrint(
          'cannot launch url: ${InstaDownloaderConstant.instaProfileUrl(username)}');
    }
  }

  downloadMedia(ContentModel content, {bool? audioOnly}) async {
    try {
      if (content.mediaType == InstaMediaType.carousel) throw 'Invalid media';
      if ((audioOnly ?? false) && content.mediaType != InstaMediaType.video) {
        throw 'No audio found';
      }
      //save video to temp dir if its audio only, then extract the audio to phone dir
      final dir = (audioOnly ?? false)
          ? await getTemporaryDirectory()
          : await CommonUtils.getSavingDirectory();

      final filePath =
          '${dir.path}/${this.content.author ?? ''}-${DateTime.now().millisecondsSinceEpoch}${content.mediaType == InstaMediaType.photo ? '.jpg' : '.mp4'}';

      final res = await repoDownload(
        Uri.parse(content.url),
        filePath,
        onReceiveProgress: (received, total) {
          debugPrint('rec: $received, total: $total');
        },
      );
      if (audioOnly ?? false) {
        debugPrint('downloading audio');
        await _extractAudio(filePath,
            '${this.content.author ?? ''}-${DateTime.now().millisecondsSinceEpoch}');
      }

      final contentTypeStr = content.mediaType == InstaMediaType.photo
          ? 'Image'
          : content.mediaType == InstaMediaType.video && (audioOnly ?? false)
              ? 'Audio'
              : 'Video';
      AppToast.showMsg('$contentTypeStr downloaded');
    } catch (e) {
      debugPrint('error download: $e');
      AppToast.showMsg(e.toString());
    }
  }

  _extractAudio(String filePath, String finalFileName) async {
    try {
      final dir = await CommonUtils.getSavingDirectory();
      // ignore: unused_local_variable
      final finalFile =
          await repoExtreactAudio(filePath, '${dir.path}/$finalFileName.mp3');
    } catch (e) {
      rethrow;
    }
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

  _getLoggedInUserId(Object cookie) {
    final cookies = cookie.toString().split(' ');
    final userId = cookies
        .firstWhereOrNull((element) => element.contains('ds_user_id'))
        ?.replaceAll(';', '')
        .split('=')
        .last;
    debugPrint('user id: $userId');
  }

  initDataFromWebview() async {
    loading = true;
    error = false;
    update();
    try {
      await webCtrl.setJavaScriptMode(JavaScriptMode.unrestricted);
      await webCtrl.setUserAgent(
          'Mozilla/5.0 (iPhone; CPU iPhone OS 12_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 Instagram 105.0.0.11.118 (iPhone11,8; iOS 12_3_1; en_US; en-US; scale=2.00; 828x1792; 165586599)');
      await webCtrl
          .loadRequest(Uri.parse('${_url.origin + _url.path}?__a=1&__d=dis'));
      await webCtrl.setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) async {
          final res = await webCtrl.runJavaScriptReturningResult(
              "document.documentElement.innerText");

          //secret :D
          _getLoggedInUserId(
              await webCtrl.runJavaScriptReturningResult("document.cookie"));

          Map<String, dynamic> map = {};
          try {
            map = Platform.isAndroid
                ? json.decode(json.decode(res.toString()))
                : json.decode(res.toString());
          } catch (e) {
            loading = false;
            error = true;
            update();
            debugPrint(res.toString());
            debugPrint('decode error: $e');
            AppToast.showMsg('Something went wrong, please try again later',
                toastLength: Toast.LENGTH_LONG);
            return;
          }

          //logged in and anon user, insta return different object structure
          if (map['graphql']?['shortcode_media'] != null) {
            //for anon user, this will execute
            _parseAnonMedia(map);
          } else if (map['items'] != null) {
            //for logged in user, this will execute
            _parseMedia(map);
          } else {
            loading = false;
            error = true;
            update();
            if (map['require_login'] ?? false) {
              AppToast.showMsg(
                  'Instagram has restricted your requests, please login to continue',
                  toastLength: Toast.LENGTH_LONG);
              return;
            }
            debugPrint('error here: $map');
            AppToast.showMsg('No content found',
                toastLength: Toast.LENGTH_LONG);
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

      final authorPofilePic =
          graphQlData['owner']['profile_pic_url'] as String?;
      final author = graphQlData['owner']['username'] as String?;
      final authorId = graphQlData['owner']['id'] as String?;
      final postId = graphQlData['shortcode'] as String?;

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
        authorProfilePic: authorPofilePic,
        authorId: authorId,
        author: author,
        id: postId,
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

  onSingleVidQualitySelected(Size quality) {
    content.photoOrVideo?.selectedResolution = quality;
    update();
  }

  onCarouselVidQualitySelected(int index, Size quality) {
    content.carouselContent?[index].selectedResolution = quality;
    update();
  }

  ContentModel _parseAnonPhoto(dynamic data) {
    final url = data['display_url'] as String?;
    final width = data['dimensions']['width'] as int?;
    final height = data['dimensions']['height'] as int?;

    if (url == null) throw 'Photo not found';

    return ContentModel(
      selectedResolution: null,
      thumbnail: url,
      sizeOptions: [],
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
    final hasAudio = data['has_audio'] ?? true;

    if (url == null) throw 'Video not found';

    List<Size> splitSizes = [
      Size((width ?? 0).toDouble(), (height ?? 0).toDouble())
    ];

    for (double i = 1.5;
        (height ?? 0) / i > 144 && (width ?? 0) / i > 144;
        i + 1.5) {
      splitSizes.add(Size((width ?? 0) / i, (height ?? 0) / i));
    }

    return ContentModel(
      selectedResolution: splitSizes.length > 1
          ? splitSizes[splitSizes.length - 2]
          : splitSizes.first,
      sizeOptions: splitSizes,
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
      final authorProfilePic =
          items.first['user']['profile_pic_url'] as String?;
      final author = items.first['user']['username'] as String?;
      final authorId = items.first['user']['pk_id'] as String?;
      final postId = items.first['code'] as String?;

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
        authorProfilePic: authorProfilePic,
        id: postId,
        authorId: authorId,
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
    final hasAudio = data['has_audio'] ?? true;

    if (url == null) throw 'Video not found';

    List<Size> splitSizes = [
      Size((width ?? 0).toDouble(), (height ?? 0).toDouble())
    ];

    for (double i = 1.5;
        (height ?? 0) / i >= 240 && (width ?? 0) / i >= 240;
        i += 1.5) {
      splitSizes.add(Size(((width ?? 0) / i), (height ?? 0) / i));
    }
    splitSizes.sort((a, b) => a.width.compareTo(b.width));

    return ContentModel(
      selectedResolution: splitSizes.length > 1
          ? splitSizes[splitSizes.length - 2]
          : splitSizes.first,
      sizeOptions: splitSizes,
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
      selectedResolution: null,
      sizeOptions: [],
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
