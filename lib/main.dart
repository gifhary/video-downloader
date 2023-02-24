import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_downloader/core/global/global_controller.dart';
import 'package:video_downloader/core/route/app_route.dart';
import 'package:video_downloader/core/route/route_const.dart';
import 'package:video_downloader/core/style/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalController.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: AppTheme.main,
      getPages: AppRoute.all,
      initialRoute: RouteConst.home,
      defaultTransition: Transition.cupertino,
    );
  }
}
