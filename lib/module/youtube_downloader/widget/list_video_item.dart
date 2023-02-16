import 'package:flutter/material.dart';
import 'package:video_downloader/common/widget/app_image.dart';
import 'package:video_downloader/common/widget/duration_tag.dart';

class ListVideoItem extends StatelessWidget {
  final String thumbnail;
  final String title;
  final Duration duration;
  final double? downloadProgress;
  const ListVideoItem({
    Key? key,
    required this.thumbnail,
    required this.title,
    required this.duration,
    this.downloadProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AspectRatio(
            aspectRatio: 12 / 9,
            child: AppImage(
              thumbnail,
              height: double.maxFinite,
              width: double.maxFinite,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                DurationTag(duration),
              ],
            ),
          ),
          downloadProgress != null
              ? SizedBox(
                  height: 48,
                  width: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.file_download_outlined, size: 30),
                      CircularProgressIndicator(
                          value: 1, color: Colors.green[200]),
                      CircularProgressIndicator(value: downloadProgress ?? 0),
                    ],
                  ),
                )
              : IconButton(
                  onPressed: () {},
                  splashRadius: 24,
                  icon: const Icon(
                    Icons.file_download_outlined,
                    size: 30,
                  ),
                ),
        ],
      ),
    );
  }
}
