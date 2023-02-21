import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_downloader/common/widget/app_bottom_sheet.dart';

class InstaVidQualityPicker extends StatelessWidget {
  final List<Size> qualities;
  final Size quality;
  final Function(Size quality)? onSelected;
  const InstaVidQualityPicker(
      {Key? key,
      required this.quality,
      this.onSelected,
      required this.qualities})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    onQualityTap(Size e) {
      onSelected != null ? onSelected!(e) : null;
      Future.delayed(const Duration(milliseconds: 300), Get.back);
    }

    showOptions() {
      if (qualities.isEmpty) return;
      AppBottomSheet.show(SafeArea(
        child: Column(
          children: qualities.map((e) {
            return InkWell(
              onTap: () => onQualityTap(e),
              child: Ink(
                color: e == quality ? Colors.green : Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${e.width.round()}×${e.height.round()}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: e == quality ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ));
    }

    return Opacity(
      opacity: qualities.isEmpty ? 0.4 : 1,
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Center(
                  child: Text(
                    '${quality.width.round()}×${quality.height.round()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 12),
                  ),
                ),
              ),
            ),
            Container(
              height: 38,
              width: 2,
              color: Colors.green,
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: showOptions,
                child: const SizedBox(
                  height: 38,
                  width: 20,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: Colors.green,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
