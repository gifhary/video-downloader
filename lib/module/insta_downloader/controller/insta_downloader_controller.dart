import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_downloader/common/utils/common_utils.dart';
import 'package:video_downloader/common/widget/app_bottom_sheet.dart';
import 'package:video_downloader/core/network/app_network.dart';
import 'package:video_downloader/core/toast/app_toast.dart';
import 'package:video_downloader/module/insta_downloader/data/constant/insta_downloader_constant.dart';
import 'package:video_downloader/module/insta_downloader/data/enum/insta_media_type.dart';
import 'package:video_downloader/module/insta_downloader/data/model/insta_content_model.dart';
import 'package:video_downloader/module/insta_downloader/data/model/user_id_data_model.dart';
import 'package:video_downloader/module/insta_downloader/data/network/insta_downloader_network.dart';
import 'package:video_downloader/module/insta_downloader/data/repo/insta_downloader_repo.dart';
import 'package:video_downloader/module/insta_downloader/screen/insta_login_screen.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InstaDownloaderController extends GetxController
    with InstaDownloaderRepo {
  bool loading = false;
  bool error = false;
  final BuildContext context;

  String loginShowCaseText =
      'Consider log in if you\'re having trouble getting the content or its from a private account';

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

  @override
  void onClose() async {
    Get.find<AppNetworkClient>().removeHeader();
    super.onClose();
  }

  initDataFromWebview() async {
    loading = true;
    error = false;
    update();
    try {
      await webCtrl.setJavaScriptMode(JavaScriptMode.unrestricted);
      // await webCtrl.setUserAgent(
      //     'Mozilla/5.0 (iPhone; CPU iPhone OS 12_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 Instagram 105.0.0.11.118 (iPhone11,8; iOS 12_3_1; en_US; en-US; scale=2.00; 828x1792; 165586599)');
      await webCtrl
          .loadRequest(Uri.parse('${_url.origin + _url.path}?__a=1&__d=dis'));
      await webCtrl.setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) async {
          await _setCookiesToNetworkClient();
          final currentUrl = Uri.parse(
              await webCtrl.currentUrl() ?? 'https://www.instagram.com/');
          if (currentUrl.path.split('/')[1] == 'stories' &&
              currentUrl.path.split('/')[2] == 'highlights') {
            //this is for stories highlight url
            _parseHighlightStories(currentUrl.path.split('/')[3]);
            return;
          }

          final res = await webCtrl.runJavaScriptReturningResult(
              "document.documentElement.innerText");
          debugPrint('res: $res');

          Map<String, dynamic> map = {};
          try {
            map = repoParseWebViewRes(res);
          } catch (e) {
            loading = false;
            error = true;
            update();
            debugPrint('decode error: $e');
            AppToast.showMsg('Something went wrong, please try again later',
                toastLength: Toast.LENGTH_LONG);
            return;
          }

          if (currentUrl.path.split('/')[1] == 'stories' &&
              currentUrl.path.split('/')[2] != 'highlights') {
            //this is for stories url
            _parseUserStories(map);
          } else {
            _sortParsingRoute(map);
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

  _parseUserStories(Map<String, dynamic> usrData) async {
    try {
      final instaUser = UserIdDataModel.fromMap(usrData);

      //not putting this function in repo, it causes stack overflow
      content =
          await InstaDownloaderNetwork().getUserStories(instaUser.user.id);
    } on DioError catch (e) {
      debugPrint('error parsing: ${e.response}');
      AppToast.showMsg(e.toString(), toastLength: Toast.LENGTH_LONG);
      error = true;
    }
    loading = false;
    update();
  }

  _parseHighlightStories(String highlightId) async {
    try {
      //not putting this function in repo, it causes stack overflow
      content =
          await InstaDownloaderNetwork().getUserHighlightStories(highlightId);
    } on DioError catch (e) {
      debugPrint('error parsing highlight dio: ${e.response}');
      AppToast.showMsg(e.message ?? '', toastLength: Toast.LENGTH_LONG);
      error = true;
    } catch (e) {
      debugPrint('error parsing highlight: $e');
      AppToast.showMsg('Something went wrong, please try again later',
          toastLength: Toast.LENGTH_LONG);
      error = true;
    }
    loading = false;
    update();
  }

  _sortParsingRoute(Map<String, dynamic> map) {
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
      debugPrint('error sorting: $map');
      AppToast.showMsg('No content found', toastLength: Toast.LENGTH_LONG);
    }
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
      //TODO make background service
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

      await repoDownload(
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

  Future<void> _setCookiesToNetworkClient() async {
    final gotCookies =
        await WebviewCookieManager().getCookies('https://www.instagram.com');
    String neededCookies = '';
    for (var item in gotCookies) {
      if (item.name == 'ds_user_id' || item.name == 'sessionid') {
        neededCookies += '${item.name}=${item.value};';
      }
    }
    Get.find<AppNetworkClient>().setHeader({
      'User-Agent': InstaDownloaderConstant.customUserAgent,
      'Cookie': neededCookies,
    });
    if (Uri.parse(await webCtrl.currentUrl() ?? 'https://www.instagram.com/')
                .path
                .split('/')[1] ==
            'stories' &&
        !neededCookies.contains('sessionid')) {
      loginShowCaseText = 'You need to login for downloading stories';
      update();
      if (context.mounted) {
        ShowCaseWidget.of(context).startShowCase([showcaseKey]);
      }
    }
  }

  _parseAnonMedia(dynamic map) {
    try {
      final graphQlData = map['graphql']['shortcode_media'];
      if (graphQlData == null) throw 'Content not found';

      final mediaType = repoGetMediaType(graphQlData['__typename']);
      if (mediaType == null) throw 'Unsupported media type';

      final authorPofilePic =
          graphQlData['owner']['profile_pic_url'] as String?;
      final author = graphQlData['owner']['username'] as String?;
      final authorId = graphQlData['owner']['id'] as String?;

      ContentModel? photoOrVideo;

      if (mediaType == InstaMediaType.photo) {
        photoOrVideo = repoParseAnonPhoto(graphQlData);
      } else if (mediaType == InstaMediaType.video) {
        photoOrVideo = repoParseAnonVideo(graphQlData);
      }

      List<ContentModel>? carousel;
      if (mediaType == InstaMediaType.carousel) {
        carousel = _parseAnonCarousel(graphQlData);
      }

      content = InstaContentModel(
        authorProfilePic: authorPofilePic,
        authorId: authorId,
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

  onSingleVidQualitySelected(Size quality) {
    content.photoOrVideo?.selectedResolution = quality;
    update();
  }

  onCarouselVidQualitySelected(int index, Size quality) {
    content.carouselContent?[index].selectedResolution = quality;
    update();
  }

  List<ContentModel> _parseAnonCarousel(dynamic data) {
    List<ContentModel> carousel = [];
    final dataList = data['edge_sidecar_to_children']['edges'] as List?;

    if (dataList == null || dataList.isEmpty) throw 'Contents not found';

    for (var e in dataList) {
      final node = e['node'];

      debugPrint(node.toString());

      final mediaType = repoGetMediaType(node['__typename']);

      ContentModel? content;
      if (mediaType == InstaMediaType.photo) {
        content = repoParseAnonPhoto(node);
      } else if (mediaType == InstaMediaType.video) {
        content = repoParseAnonVideo(node);
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

      final mediaType = repoGetMediaType(items.first['media_type']);
      if (mediaType == null) throw 'Unsupported media type';
      final authorProfilePic =
          items.first['user']['profile_pic_url'] as String?;
      final author = items.first['user']['username'] as String?;
      final authorId = items.first['user']['pk_id'] as String?;

      ContentModel? photoOrVideo;

      if (mediaType == InstaMediaType.photo) {
        photoOrVideo = repoParsePhoto(items.first);
      } else if (mediaType == InstaMediaType.video) {
        photoOrVideo = repoParseVideo(items.first);
      }

      List<ContentModel>? carousel;
      if (mediaType == InstaMediaType.carousel) {
        carousel = _parseCarousel(items.first);
      }

      content = InstaContentModel(
        authorProfilePic: authorProfilePic,
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
      final mediaType = repoGetMediaType(e['media_type']);

      ContentModel? content;
      if (mediaType == InstaMediaType.photo) {
        content = repoParsePhoto(e);
      } else if (mediaType == InstaMediaType.video) {
        content = repoParseVideo(e);
      }

      if (content != null) {
        carousel.add(content);
      }
    }

    return carousel;
  }

  loginInsta() async {
    await AppBottomSheet.show(InstaLoginScreen());
    initDataFromWebview();
  }
}
