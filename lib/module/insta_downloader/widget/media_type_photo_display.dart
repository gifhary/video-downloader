import 'package:flutter/material.dart';
import 'package:video_downloader/common/widget/app_image.dart';
import 'package:video_downloader/core/style/app_shadow.dart';
import 'package:video_downloader/module/insta_downloader/data/enum/insta_media_type.dart';
import 'package:video_downloader/module/insta_downloader/widget/insta_vid_quality_picker.dart';

class MediaTypePhotoDisplay extends StatelessWidget {
  final String url;
  final String author;
  final int height;
  final int width;
  final List<Size> qualities;
  final VoidCallback? onDownload;
  final bool? hasAudio;
  final InstaMediaType type;
  const MediaTypePhotoDisplay(
      {Key? key,
      required this.url,
      required this.author,
      required this.height,
      required this.width,
      this.onDownload,
      required this.type,
      required this.hasAudio,
      required this.qualities})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green, width: 2),
            borderRadius: BorderRadius.circular(8),
            boxShadow: AppShadow.primary,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AppImage(
                  url,
                  width: double.maxFinite,
                  fit: BoxFit.cover,
                ),
                Visibility(
                  visible: type == InstaMediaType.video,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle),
                    child: const Icon(
                      Icons.videocam,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: type == InstaMediaType.photo,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '$width × $height',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Visibility(
              visible: type == InstaMediaType.video,
              child: Flexible(
                flex: 2,
                child: Row(
                  children: [
                    Flexible(
                      child: InstaVidQualityPicker(
                        quality: Size(width.toDouble(), height.toDouble()),
                        qualities: qualities,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: ElevatedButton(
                        onPressed: hasAudio ?? false ? onDownload : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.file_download_outlined),
                            SizedBox(width: 5),
                            Flexible(
                                child: Text(
                              'MP3',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(
                    left: type == InstaMediaType.video ? 16 : 0),
                child: ElevatedButton(
                  onPressed: onDownload,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.file_download_outlined),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          type == InstaMediaType.photo ? 'JPEG' : 'MP4',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
