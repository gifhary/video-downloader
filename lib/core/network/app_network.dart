import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AppNetworkClient {
  static final Dio _dio = Dio()
    ..options.connectTimeout = const Duration(seconds: 10);

  static void setHeader(Map<String, dynamic> header) {
    _dio.options.headers = header;
  }

  static void removeHeader() {
    _dio.options.headers = {};
  }

  static Future<Response> get(String url,
      {Map<String, dynamic>? data, Map<String, dynamic>? customHeader}) async {
    try {
      final res = await _dio.get(url,
          queryParameters: data, options: Options(headers: customHeader));

      debugPrint('CALLING GET ${res.requestOptions.path}');
      debugPrint('Query GET ${res.requestOptions.queryParameters}');

      return res;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response<dynamic>> download(
    Uri uri,
    String savePath, {
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.downloadUri(uri, savePath,
          onReceiveProgress: onReceiveProgress);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response> head(
    String url,
  ) async {
    try {
      final res = await _dio.head(url);
      debugPrint('CALLING HEAD ${res.requestOptions.path}');
      return res;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response> post(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? customHeader,
    required String path,
    FormData? form,
    // jsonMap for sending raw json to server
    Map<String, dynamic>? jsonMap,
  }) async {
    try {
      final res = await _dio.post(url,
          data: form ?? jsonMap ?? FormData.fromMap(data!));

      debugPrint('CALLING POST ${res.requestOptions.path}');
      // debugPrint("Response Data " + res.data.toString());

      return res;
    } catch (e) {
      rethrow;
    }
  }
}
