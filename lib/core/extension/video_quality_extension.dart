import 'package:youtube_explode_dart/youtube_explode_dart.dart';

extension VideoQualityExtension on VideoQuality {
  String get quality => _getQuality();
  String get displayName => _getDisplayName();

  String _getQuality() {
    switch (this) {
      case VideoQuality.low144:
        return '144p';
      case VideoQuality.low240:
        return '240p';
      case VideoQuality.medium360:
        return '360p';
      case VideoQuality.medium480:
        return '480p';
      case VideoQuality.high720:
        return '720p';
      case VideoQuality.high1080:
        return '1080p';
      case VideoQuality.high1440:
        return '1440p';
      case VideoQuality.high2160:
        return '2160p';
      case VideoQuality.high2880:
        return '2880p';
      case VideoQuality.high3072:
        return '3072p';
      case VideoQuality.high4320:
        return '4320p';
      default:
        return 'unknown';
    }
  }

  String _getDisplayName() {
    switch (this) {
      case VideoQuality.low144:
        return 'Low';
      case VideoQuality.low240:
        return 'Low';
      case VideoQuality.medium360:
        return 'Medium';
      case VideoQuality.medium480:
        return 'Medium';
      case VideoQuality.high720:
        return 'HD';
      case VideoQuality.high1080:
        return 'Full HD';
      case VideoQuality.high1440:
        return '2K';
      case VideoQuality.high2160:
        return '4K';
      case VideoQuality.high2880:
        return '5K';
      case VideoQuality.high3072:
        return '6k';
      case VideoQuality.high4320:
        return '8K';
      default:
        return 'unknown';
    }
  }
}
