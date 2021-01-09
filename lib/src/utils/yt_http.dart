import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_ytim/src/utils/yt_log.dart';
import 'package:flutter_ytim/src/ytim.dart';

class YTHttp {
  static Dio _dio = Dio();

  static const String TAG = 'YTHttp';

  /// post form-data
  static Future postFormData(String url, [Map<String, dynamic> data]) async {
    _dio.interceptors.add(HTTPInterceptors());
    try {
      Response response = await _dio.post(url, data: FormData.fromMap(data));
      return response.data;
    } on DioError catch (e) {
      if (e.response.statusCode.toString().startsWith('5') ||
          e.response.statusCode.toString().startsWith('4')) {
        return null;
      }
      return e.response?.data;
    } catch (e) {
      YTLog.d(TAG, e);
      return null;
    }
  }

  /// 对请求参数进行签名。
  static Map<String, dynamic> getSignedParams(List<String> params) {
    params.sort();
    var temp = params.join('&') + '&appSecret=${YTIM().appSecret}';
    var sign = md5.convert(utf8.encode(temp)).toString().toUpperCase();
    params.add('sign=$sign');
    var result = Map<String, dynamic>();
    for (var item in params) {
      var t = item.split('=');
      result['${t[0]}'] = t[1];
    }
    return result;
  }
}

/// 网络请求拦截器
class HTTPInterceptors extends InterceptorsWrapper {
  String tag = 'YTHttp';

  @override
  Future onRequest(RequestOptions options) {
    String data = "";
    if (options.data != null) {
      if (options.data is FormData) {
        Map m = {};
        options.data.fields.forEach((element) {
          m[element.key] = element.value;
        });
        data = "\nbody:${json.encode(m)}";
      } else {
        data = "\nbody:${json.encode(options.data)}";
      }
    }
    YTLog.d(tag,
        "--> ${options.method} ${options.path}\nheaders:${json.encode(options.headers)}$data");
    return super.onRequest(options);
  }

  @override
  Future onResponse(Response response) {
    YTLog.d(tag,
        "<-- ${response?.statusCode} ${response?.request?.path} \nbody:${json.encode(response?.data ?? '')}");
    return super.onResponse(response);
  }

  @override
  Future onError(DioError err) {
    YTLog.d(tag,
        "<-- ${err?.response?.statusCode} ${err?.request?.path}\nbody:${json.encode(err?.response?.data ?? "")}");
    return super.onError(err);
  }
}
