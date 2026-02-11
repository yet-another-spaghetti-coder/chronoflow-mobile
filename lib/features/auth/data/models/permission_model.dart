import 'package:chronoflow/features/auth/domain/entities/permission.dart';

class PermissionModel extends Permission {
  const PermissionModel({
    required super.id,
    required super.name,
    required super.key,
    super.description,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      key: json['key'] as String,
      description: json['description'] as String?,
    );
  }
}
