import 'package:get/get.dart';
import 'package:video_downloader/core/network/app_network.dart';

class GlobalController {
  static init() {
    Get.put(AppNetworkClient(), permanent: true);
  }
}
