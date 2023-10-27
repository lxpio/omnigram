import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:omnigram/flavors/app_store.dart';
import 'package:omnigram/providers/service/provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    @Default(0) int id,
    @Default('') String email,
    @Default('') String username,
    @Default('') String nickname,
    @Default(10) @JsonKey(name: 'role_id') int roleId,
    @Default(false) bool locked,
    @Default(false) bool logined,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

final userProvider = NotifierProvider<User, UserModel>(User.new);

class User extends Notifier<UserModel> {
  @override
  UserModel build() {
    try {
      final config = json.decode(AppStore.instance.hive().get('user_auth'));

      if (config != null) {
        return UserModel.fromJson(config);
      }
    } catch (e) {
      print("user model init error: $e");
    }

    return const UserModel();
  }

  // Future<void> update(UserModel user) async {
  //   final updated = user.copyWith(logined: true);

  //   await AppStore.instance
  //       .hive()
  //       .put('user_auth', json.encode(updated.toJson()));

  //   state = user.copyWith(logined: true);

  //   if (kDebugMode) {
  //     print("user_auth: changed");
  //   }
  // }

  Future<void> update() async {
    final service = ref.read(apiServiceProvider);

    final userResp = await service.request('GET', '/user/info',
        fromJsonT: UserModel.fromJson);

    if (userResp.code == 200) {
      final updated = userResp.data!.copyWith(logined: true);

      await AppStore.instance
          .hive()
          .put('user_auth', json.encode(updated.toJson()));

      state = updated;

      if (kDebugMode) {
        print("user_auth: changed");
      }
    }
  }

  void logout() {
    state = state.copyWith(logined: false);
  }
}
