import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  final String src;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final double? placeholderSize;
  const AppImage(this.src,
      {Key? key, this.height, this.width, this.fit, this.placeholderSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      src,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height ?? double.infinity,
        width: width ?? double.infinity,
        color: Colors.grey[400],
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.white,
          size: placeholderSize ?? 50,
        ),
      ),
    );
  }
}
