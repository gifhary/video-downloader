class CommonUtils {
  static String durationFormat(Duration d) =>
      d.toString().split('.').first.padLeft(8, '0');
}
