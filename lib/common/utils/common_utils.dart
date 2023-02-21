import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

class CommonUtils {
  static String durationFormat(Duration d) {
    final durStr = d.toString().split('.').first;
    return d.inHours < 1 ? durStr.substring(2) : durStr.padLeft(8, '0');
  }

  static String getFileSizeString({required int bytes, int decimals = 0}) {
    const suffixes = ["b", "kb", "mb", "gb", "tb"];
    if (bytes == 0) return '0${suffixes[0]}';
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
  }

  static Future<Directory> getSavingDirectory() async {
    try {
      late Directory downloadDir;
      if (Platform.isAndroid) {
        downloadDir = Directory('/storage/emulated/0/Download');
        if (!await downloadDir.exists()) {
          final extDir = (await getExternalStorageDirectories())?.first;
          if (extDir == null) throw 'Failed getting app directory';
          downloadDir = extDir;
        }
      } else if (Platform.isIOS) {
        downloadDir = await getApplicationDocumentsDirectory();
      }
      return downloadDir;
    } catch (e) {
      rethrow;
    }
  }
}
