import 'package:chronoflow/features/auth/data/models/permission_model.dart';
import 'package:chronoflow/features/auth/domain/entities/role.dart';

class RoleModel extends Role {
  const RoleModel({
    required super.id,
    required super.name,
    required super.key,
    required super.isDefault,
    required super.permissions,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      key: json['key'] as String,
      isDefault: json['isDefault'] as bool,
      permissions: (json['permissions'] as List)
          .map((p) => PermissionModel.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}
