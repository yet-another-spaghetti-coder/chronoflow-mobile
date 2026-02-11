import 'package:chronoflow/core/shared/contants.dart';
import 'package:dio/dio.dart';

class NetworkClient {
  NetworkClient(this._dio, {required this.constant}) {
    _dio.options = BaseOptions(baseUrl: constant.apiBaseUrl);
  }

  final Dio _dio;
  final Constants constant;

  Dio get dio => _dio;
}
