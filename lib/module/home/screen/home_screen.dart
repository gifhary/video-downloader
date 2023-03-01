import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:video_downloader/core/style/app_shadow.dart';
import 'package:video_downloader/module/home/controller/home_controller.dart';
import 'dart:math' as math;

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (HomeController controller) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        boxShadow: AppShadow.primary,
                        borderRadius: BorderRadius.circular(30)),
                    child: TextField(
                      controller: controller.mainTextFieldCtrl,
                      onChanged: (value) => controller.update(),
                      decoration: InputDecoration(
                        prefixIcon: Transform.rotate(
                          angle: -math.pi / 4,
                          child: const Icon(
                            Icons.link,
                            color: Colors.grey,
                          ),
                        ),
                        suffixIcon: GestureDetector(
                          onTap:
                              controller.loading ? null : controller.download,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: EdgeInsets.all(controller.loading ? 5 : 0),
                            decoration: BoxDecoration(
                                color: controller.mainTextFieldCtrl.text.isEmpty
                                    ? Colors.grey.shade400
                                    : Colors.green,
                                shape: BoxShape.circle),
                            child: AnimatedSwitcher(
                              switchOutCurve: Curves.easeOutExpo,
                              switchInCurve: Curves.easeInExpo,
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return ScaleTransition(
                                    scale: animation, child: child);
                              },
                              child: controller.loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2)
                                  : Icon(Icons.arrow_forward,
                                      color: controller
                                              .mainTextFieldCtrl.text.isEmpty
                                          ? Colors.grey.shade600
                                          : Colors.white),
                            ),
                          ),
                        ),
                        suffixIconConstraints: const BoxConstraints(
                            minWidth: 60,
                            maxHeight: 60,
                            maxWidth: 60,
                            minHeight: 60),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        hintText: 'Paste your link here',
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: controller.supports
                        .map(
                          (e) => Container(
                            decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.6),
                                shape: BoxShape.circle),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: SvgPicture.asset(e),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
