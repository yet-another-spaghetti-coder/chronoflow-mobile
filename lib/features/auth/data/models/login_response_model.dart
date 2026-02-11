import 'package:chronoflow/features/auth/data/models/role_model.dart';
import 'package:chronoflow/features/auth/data/models/user_model.dart';
import 'package:chronoflow/features/auth/domain/entities/auth_result.dart';

class LoginResponseModel {
  final int code;
  final LoginDataModel data;
  final String msg;

  LoginResponseModel({
    required this.code,
    required this.data,
    required this.msg,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      code: json['code'] as int,
      data: LoginDataModel.fromJson(json['data'] as Map<String, dynamic>),
      msg: json['msg'] as String,
    );
  }

  AuthResult toEntity() => data.toEntity();
}

class LoginDataModel {
  final UserModel user;
  final List<RoleModel> roles;

  LoginDataModel({
    required this.user,
    required this.roles,
  });

  factory LoginDataModel.fromJson(Map<String, dynamic> json) {
    return LoginDataModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      roles: (json['roles'] as List).map((r) => RoleModel.fromJson(r as Map<String, dynamic>)).toList(),
    );
  }

  AuthResult toEntity() {
    return AuthResult(
      user: user,
      roles: roles,
    );
  }
}
