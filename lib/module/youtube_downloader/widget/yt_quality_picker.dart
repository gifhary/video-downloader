import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_downloader/common/widget/app_bottom_sheet.dart';
import 'package:video_downloader/core/extension/video_quality_extension.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YtQualityPicker extends StatelessWidget {
  final List<VideoQuality> qualities;
  final VideoQuality quality;
  final Function(VideoQuality quality)? onSelected;
  const YtQualityPicker(
      {Key? key,
      required this.quality,
      this.onSelected,
      required this.qualities})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    onQualityTap(VideoQuality e) {
      onSelected != null ? onSelected!(e) : null;
      Future.delayed(const Duration(milliseconds: 300), Get.back);
    }

    showOptions() {
      AppBottomSheet.show(SafeArea(
        child: Column(
          children: qualities.map((e) {
            //TODO
            //hide K video options for now
            //will show later for premium features
            return e.index > VideoQuality.high1080.index
                ? Container()
                : InkWell(
                    onTap: () => onQualityTap(e),
                    child: Ink(
                      color: e == quality ? Colors.green : Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.displayName,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    color: e == quality
                                        ? Colors.white
                                        : Colors.black),
                          ),
                          Text(
                            e.quality,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    color: e == quality
                                        ? Colors.white
                                        : Colors.black),
                          )
                        ],
                      ),
                    ),
                  );
          }).toList(),
        ),
      ));
    }

    return Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                quality.quality,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                width: 25,
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
