import 'package:flutter/material.dart';
import 'package:video_downloader/common/widget/app_image.dart';
import 'package:video_downloader/core/style/app_shadow.dart';

class MediaTypePhotoDisplay extends StatelessWidget {
  final String url;
  final String author;
  final int height;
  final int width;
  final VoidCallback? onDownload;
  const MediaTypePhotoDisplay(
      {Key? key,
      required this.url,
      required this.author,
      required this.height,
      required this.width,
      this.onDownload})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.65),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green, width: 2),
            borderRadius: BorderRadius.circular(8),
            boxShadow: AppShadow.primary,
          ),
          child: AspectRatio(
            aspectRatio: width / height,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(6), child: AppImage(url)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                author,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '$width × $height',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: onDownload,
          child: const Text('Download JPEG'),
        )
      ],
    );
  }
}
