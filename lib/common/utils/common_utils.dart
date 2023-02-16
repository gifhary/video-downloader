class CommonUtils {
  static String durationFormat(Duration d) {
    final durStr = d.toString().split('.').first;
    return d.inHours < 1 ? durStr.substring(2) : durStr.padLeft(8, '0');
  }
}
