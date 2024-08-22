// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: (json['id'] as num?)?.toInt() ?? 0,
      email: json['email'] as String? ?? '',
      username: json['user_name'] as String? ?? '',
      nickname: json['nick_name'] as String? ?? '',
      roleId: (json['role_id'] as num?)?.toInt() ?? 10,
      locked: json['locked'] as bool? ?? false,
      logined: json['logined'] as bool? ?? false,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'user_name': instance.username,
      'nick_name': instance.nickname,
      'role_id': instance.roleId,
      'locked': instance.locked,
      'logined': instance.logined,
    };

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userHash() => r'9388b16abb57a2fef26daa8f19b5a38663b765d2';

/// See also [User].
@ProviderFor(User)
final userProvider = NotifierProvider<User, UserModel>.internal(
  User.new,
  name: r'userProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$User = Notifier<UserModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
