import 'package:flutter/material.dart';
import 'package:video_downloader/common/widget/app_image.dart';
import 'package:video_downloader/common/widget/duration_tag.dart';
import 'package:video_downloader/core/style/app_shadow.dart';
import 'package:video_downloader/module/insta_downloader/data/enum/insta_media_type.dart';
import 'package:video_downloader/module/insta_downloader/widget/insta_vid_quality_picker.dart';

class MediaTypePhotoDisplay extends StatelessWidget {
  final String url;
  final Size? selectedQuality;
  final int height;
  final int width;
  final List<Size> qualities;
  final VoidCallback? onDownload;
  final VoidCallback? onDownloadAudio;
  final bool? hasAudio;
  final Duration? duration;
  final InstaMediaType type;
  final Function(Size quality)? onQualitySelected;
  const MediaTypePhotoDisplay({
    Key? key,
    required this.url,
    required this.height,
    required this.width,
    this.onDownload,
    required this.type,
    required this.hasAudio,
    required this.qualities,
    this.onDownloadAudio,
    required this.selectedQuality,
    this.onQualitySelected,
    required this.duration,
  }) : super(key: key);

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
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Visibility(
                    visible: type == InstaMediaType.video,
                    child: DurationTag(duration ?? const Duration()),
                  ),
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
        const SizedBox(height: 12),
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
                        quality: selectedQuality,
                        qualities: qualities,
                        onSelected: onQualitySelected,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: ElevatedButton(
                        onPressed: hasAudio ?? false ? onDownloadAudio : null,
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
