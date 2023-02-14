import 'package:flutter/material.dart';
import 'package:video_downloader/common/utils/common_utils.dart';

class DurationTag extends StatelessWidget {
  final Duration duration;
  const DurationTag(this.duration, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(3)),
      child: Text(
        CommonUtils.durationFormat(duration),
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.white),
      ),
    );
  }
}
