class ResponseData {
  final int code;
  final String message;
  final Map<String, dynamic>? data;

  ResponseData({required this.code, required this.message, this.data});

  static fromJson(Map data) {
    String msg = "";
    if (data['message'] != null) {
      msg = data['message'].toString();
    } else if (data['msg'] != null) {
      msg = data['msg'].toString();
    }

    Map<String, dynamic>? myData = {};
    if (data['data'] is List) {
      myData = {'list': data['data']};
    }
    if (data['data'] is Map) {
      myData = data['data'];
    }

    return ResponseData(
      code: int.parse(data['code'].toString()),
      message: msg,
      data: myData,
    );
  }

  bool get isSuccess => code == 200;

  @override
  String toString() {
    return '''AppResponseBody { code:$code, message:$message, data: $data }''';
  }
}
