import 'package:chronoflow/features/auth/domain/entities/permission.dart';
import 'package:equatable/equatable.dart';

class Role extends Equatable {
  final String id;
  final String name;
  final String key;
  final bool isDefault;
  final List<Permission> permissions;

  const Role({
    required this.id,
    required this.name,
    required this.key,
    required this.isDefault,
    required this.permissions,
  });

  @override
  List<Object?> get props => [id, name, key, isDefault, permissions];
}
