class ApiResponse {
  int code;
  dynamic data;
  String msg;

  ApiResponse({
    required this.code,
    required this.data,
    required this.msg,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      code: json['code'] as int,
      data: json['data'],
      msg: json['msg'].toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'data': data,
    'msg': msg,
  };
}
