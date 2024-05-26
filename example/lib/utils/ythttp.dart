import 'package:dio/dio.dart';
import 'package:flutter_ytim_example/utils/response_body.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'auth_cuestom_interceptors.dart';
import 'package:flutter_ytim/src/utils/im_utils.dart';

class YTHttp {
  YTHttp._internal();

  /// 网络请求实例
  static final Dio instance = Dio(BaseOptions(baseUrl: 'https://pre.rentalbike.shop'));
  static final Dio authInstance =
  Dio(BaseOptions(baseUrl: 'https://pre.rentalbike.shop'));

  /// 初始化dio
  static init() {
    //添加拦截器
    instance.interceptors.add(AuthCustomInterceptors());
  }

  static Future<ResponseData> get(
      String api, {
        Map<String, dynamic>? data,
      }) async {
    Response response = await instance.get(
      api,
      data: data?..putIfAbsent('timestamp', () => IMUtils.getTimestamp()),
    );
    return ResponseData.fromJson(response.data);
  }

  static Future getList(
      String api, {
        Map<String, dynamic>? data,
      }) async {
    Response response = await instance.get(
      api,
      data: data?..putIfAbsent('timestamp', () => IMUtils.getTimestamp()),
    );
    return response.data;
  }

  static Future<ResponseData> post(String api, {Map? data}) async {
    Response response = await instance.post(
      api,
      data: data?..putIfAbsent('timestamp', () => IMUtils.getTimestamp()),
    );
    ResponseData result = ResponseData.fromJson(response.data);
    return result;
  }

  static Future<ResponseData> uploadImage(
      String api,
      String imagePath,
      ) async {
    String filename = YTUtils.extractFileName(imagePath);

    MultipartFile file =
    await MultipartFile.fromFile(imagePath, filename: filename);
    var data = FormData.fromMap({
      'file': file,
    });

    Response response = await instance.post(
      api,
      data: data,
    );
    ResponseData result = ResponseData.fromJson(response.data);

    return result;
  }

  static Future<ResponseData> uploadImages(
      String api,
      List<String> imagePaths,
      ) async {
    List<MultipartFile> files = [];
    for (var path in imagePaths) {
      String filename = YTUtils.extractFileName(path);

      MultipartFile file =
      await MultipartFile.fromFile(path, filename: filename);
      files.add(file);
    }

    var data = FormData.fromMap({
      'file[]': files,
    });

    Response response = await instance.post(
      api,
      data: data,
    );
    ResponseData result = ResponseData.fromJson(response.data);

    return result;
  }
}
