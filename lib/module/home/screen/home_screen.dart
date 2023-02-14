import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_downloader/module/home/controller/home_controller.dart';

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
                  TextField(
                    controller: controller.mainTextFieldCtrl,
                    onChanged: (value) => controller.update(),
                    decoration:
                        const InputDecoration(hintText: 'Paste your link here'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: controller.mainTextFieldCtrl.text.isEmpty
                        ? null
                        : controller.download,
                    child: const Text('Download'),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
