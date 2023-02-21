import 'package:flutter/material.dart';
import 'package:video_downloader/module/insta_downloader/data/enum/insta_media_type.dart';

class InstaContentModel {
  final String? authorId;
  final String? id;
  final String? author;
  final String? authorProfilePic;
  //accept all, photo, video, carousel
  final InstaMediaType mediaType;
  final ContentModel? photoOrVideo;
  final List<ContentModel>? carouselContent;
  InstaContentModel({
    required this.authorProfilePic,
    required this.authorId,
    required this.id,
    required this.author,
    required this.mediaType,
    this.photoOrVideo,
    this.carouselContent,
  });

  @override
  String toString() {
    return 'InstaContentModel(authorProfilePic: $authorProfilePic id: $id, author: $author, mediaType: $mediaType, photoOrVideo: $photoOrVideo, carouselContent: $carouselContent)';
  }
}

class ContentModel {
  final String thumbnail;
  final String url;
  //carousel should not be here
  final InstaMediaType mediaType;
  final Duration? videoDuration;
  final bool hasAudio;
  final num width;
  final num height;
  final List<Size> sizeOptions;
  ContentModel({
    required this.thumbnail,
    required this.sizeOptions,
    required this.url,
    required this.hasAudio,
    required this.mediaType,
    this.videoDuration,
    required this.width,
    required this.height,
  });

  @override
  String toString() {
    return 'ContentModel(thumbnail: $thumbnail, hasAudio: $hasAudio, url: $url, mediaType: $mediaType, videoDuration: $videoDuration, width: $width, height: $height)';
  }
}
