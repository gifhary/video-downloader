import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum YtQuality { low, medium, high }

class YtQualityPicker extends StatelessWidget {
  final YtQuality quality;
  const YtQualityPicker({Key? key, this.quality = YtQuality.medium})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _showOptions() {
      Get.bottomSheet(Container());
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(quality.name.capitalizeFirst ?? ''),
          ),
          Container(
            height: 42,
            width: 2,
            color: Colors.green,
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showOptions,
              child: const SizedBox(
                height: 42,
                width: 28,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.green,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
