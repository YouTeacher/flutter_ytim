import 'package:dio/dio.dart';
import 'package:flutter_ytim/src/utils/yt_log.dart';

class AuthCustomInterceptors extends Interceptor {
  final String _tag = 'XHttp';

  static bool isRefreshing = false;
  static List<Map<String, dynamic>> requestList = [];

  /// TODO: 需要设置
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers
        .putIfAbsent("Accept-Language", () => 'zh');
    options.headers
        .putIfAbsent("Authorization", () => 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJrZXkiOiIzNyIsImRhdGEiOnsidXNlclR5cGUiOjIsInVzZXJJZCI6IjM3In0sImV4dCI6MzYwMCwiZXhwIjoxNzE2Mzc1NjE4LCJpc3MiOiJ6eTI3MDEiLCJpYXQiOjE3MTYzNzIwMTh9.DUJbI8kwH_HUbsMesi5u1DSYGNRdiL_O9RmuKzlgeio');
    super.onRequest(options, handler);
  }

  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    if (response.data["code"] == 412) {
      YTLog.d(_tag, 'accessToken 过期，将请求加入队列');
      requestList.add({
        'handler': handler,
        'options': response.requestOptions,
      });
      if (isRefreshing) {
        YTLog.d(_tag, '正在刷新 token');
      } else {
        isRefreshing = true;
        isRefreshing = false;
        requestList.clear();
      }
    } else {
      handler.next(response);
    }
  }
}
