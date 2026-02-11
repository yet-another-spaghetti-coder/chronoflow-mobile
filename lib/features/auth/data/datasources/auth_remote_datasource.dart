import 'package:chronoflow/core/errors/exceptions.dart';
import 'package:chronoflow/features/auth/data/models/login_request_model.dart';
import 'package:chronoflow/features/auth/data/models/login_response_model.dart';
import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/users/auth/login',
        data: request.toJson(),
      );

      if (response.data == null) {
        throw const ServerException(message: 'Empty response from server');
      }

      final loginResponse = LoginResponseModel.fromJson(response.data!);

      if (loginResponse.code != 0) {
        throw ServerException(
          message: loginResponse.msg.isEmpty ? 'Login failed' : loginResponse.msg,
        );
      }

      return loginResponse;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException(message: 'Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      } else if (e.response?.statusCode == 401) {
        throw const ServerException(message: 'Invalid credentials');
      } else if (e.response?.statusCode == 500) {
        throw const ServerException(message: 'Server error');
      } else {
        throw const ServerException(
          message: 'Unknown error occurred',
        );
      }
    } on FormatException catch (e) {
      throw ServerException(message: 'Invalid JSON: $e');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post<void>('/users/auth/logout');
    } on DioException {
      throw const ServerException(
        message: 'Logout failed',
      );
    }
  }
}
