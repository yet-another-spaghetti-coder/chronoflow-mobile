import 'package:equatable/equatable.dart';

class Permission extends Equatable {
  final String id;
  final String name;
  final String key;
  final String? description;

  const Permission({
    required this.id,
    required this.name,
    required this.key,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, key, description];
}
