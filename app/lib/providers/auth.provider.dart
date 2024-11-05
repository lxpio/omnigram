import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:flutter/material.dart';
import 'package:omnigram/entities/isar_store.entity.dart';
import 'package:omnigram/entities/user.entity.dart';
import 'package:omnigram/providers/api.provider.dart';
import 'package:logging/logging.dart';
import 'package:omnigram/utils/hash.dart';
import 'package:omnigram/utils/url_helper.dart';
import 'package:openapi/openapi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth.provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  final log = Logger("AuthNotifier");

  @override
  AuthState build() {
    debugPrint("create Auth");

    return AuthState(
      deviceId: "",
      userId: 0,
      userEmail: "",
      name: '',
      profileImagePath: '',
      isAdmin: false,
      shouldChangePassword: false,
      isAuthenticated: false,
    );
  }

  Future<bool> login(
    String account,
    String password,
  ) async {
    try {
      // final deviceID = await FlutterUdid.consistentUdid;
      final api = ref.watch(apiServiceProvider);

      // Get the deviceid from the store if it exists, otherwise generate a new one
      String deviceId = IsarStore.tryGet(StoreKey.deviceId) ?? await FlutterUdid.consistentUdid;

      await IsarStore.put(StoreKey.deviceId, deviceId);
      await IsarStore.put(StoreKey.deviceIdHash, fastHash(deviceId));

      LoginCredentialDto loginCredentialDto = LoginCredentialDto((b) => b
        ..account = account
        ..password = password
        ..deviceId = deviceId);

      var loginResponse = await api.authTokenPost(loginCredentialDto: loginCredentialDto);

      if (loginResponse.statusCode != 200) {
        debugPrint('Login Response is null');
        return false;
      }

      debugPrint('set access token: ${loginResponse.data!.accessToken}');

      IsarStore.put(StoreKey.accessToken, loginResponse.data!.accessToken);
      IsarStore.put(StoreKey.refreshToken, loginResponse.data!.refreshToken);

      // ref.watch(apiServiceProvider.notifier).setEndpoint();

      return true;
    } catch (e) {
      debugPrint("Error logging in $e");
      return false;
    }
  }

  Future<void> logout() async {
    try {
      String? userEmail = IsarStore.tryGet(StoreKey.currentUser)?.email;

      await ref
          .watch(apiServiceProvider)
          .authLogoutPost()
          .then((_) => log.info("Logout was successful for $userEmail"))
          .onError(
            (error, stackTrace) => log.severe("Logout failed for $userEmail", error, stackTrace),
          );

      await Future.wait([
        // clearAssetsAndAlbums(_db),
        IsarStore.delete(StoreKey.currentUser),
        IsarStore.delete(StoreKey.accessToken),
        IsarStore.delete(StoreKey.refreshToken),
      ]);
      // _ref.invalidate(albumProvider);
      // _ref.invalidate(sharedAlbumProvider);

      state = state.copyWith(
        deviceId: "",
        userId: 0,
        userEmail: "",
        name: '',
        profileImagePath: '',
        isAdmin: false,
        shouldChangePassword: false,
        isAuthenticated: false,
      );
    } catch (e, stack) {
      log.severe('Logout failed', e, stack);
    }
  }

  updateUserProfileImagePath(String path) {
    state = state.copyWith(profileImagePath: path);
  }

  // Future<bool> changePassword(String newPassword) async {
  //   try {
  //     await _apiService.usersApi.updateMyUser(
  //       UserUpdateMeDto(
  //         password: newPassword,
  //       ),
  //     );

  //     state = state.copyWith(shouldChangePassword: false);

  //     return true;
  //   } catch (e) {
  //     debugPrint("Error changing password $e");
  //     return false;
  //   }
  // }

  Future<bool> setSuccessLoginInfo() async {
    bool shouldChangePassword = false;
    User? user = IsarStore.tryGet(StoreKey.currentUser);

    UserDto? userResponse;
    // UserPreferencesResponseDto? userPreferences;
    try {
      final userResp = await ref.watch(apiServiceProvider).userUserinfoGet();
      if (userResp.statusCode == 200) {
        userResponse = userResp.data;
      }
    } on DioException catch (err) {
      if (err.response?.statusCode == 401) {
        log.severe("Unauthorized access, token likely expired. Logging out.");
        return false;
      }

      log.severe("Error getting user information from the server [API EXCEPTION]", err);
    } catch (error, stackTrace) {
      log.severe(
        "Error getting user information from the server [CATCH ALL]",
        error,
        stackTrace,
      );
    }

    // If the user information is successfully retrieved, update the store
    // Due to the flow of the code, this will always happen on first login
    if (userResponse != null) {
      user = User.fromUserDto(userResponse); //userPreferences
      final deviceId = IsarStore.get(StoreKey.deviceId);
      // await IsarStore.put(StoreKey.deviceIdHash, fastHash(deviceId));
      await IsarStore.put(StoreKey.currentUser, user);

      state = state.copyWith(
        isAuthenticated: true,
        userId: user.id,
        userEmail: user.email,
        name: user.name,
        profileImagePath: user.profileImagePath,
        isAdmin: user.roleId <= 100,
        shouldChangePassword: shouldChangePassword,
        deviceId: deviceId,
      );

      return true;
    } else {
      // If the user is null, the login was not successful
      // and we don't have a local copy of the user from a prior successful login
      log.severe("Unable to get user information from the server.");
      state = state.copyWith(
        deviceId: "",
        userId: 0,
        userEmail: "",
        name: '',
        profileImagePath: '',
        isAdmin: false,
        shouldChangePassword: false,
        isAuthenticated: false,
      );

      await Future.wait([
        // clearAssetsAndAlbums(_db),
        IsarStore.delete(StoreKey.currentUser),
        IsarStore.delete(StoreKey.accessToken),
      ]);
      return false;
    }
  }
}

class AuthState {
  final String deviceId;
  final int userId;
  final String userEmail;
  final bool isAuthenticated;
  final String name;
  final bool isAdmin;
  final bool shouldChangePassword;
  final String profileImagePath;
  AuthState({
    required this.deviceId,
    required this.userId,
    required this.userEmail,
    required this.isAuthenticated,
    required this.name,
    required this.isAdmin,
    required this.shouldChangePassword,
    required this.profileImagePath,
  });

  AuthState copyWith({
    String? deviceId,
    int? userId,
    String? userEmail,
    bool? isAuthenticated,
    String? name,
    bool? isAdmin,
    bool? shouldChangePassword,
    String? profileImagePath,
  }) {
    final ret = AuthState(
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      name: name ?? this.name,
      isAdmin: isAdmin ?? this.isAdmin,
      shouldChangePassword: shouldChangePassword ?? this.shouldChangePassword,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );

    return ret;
  }

  @override
  String toString() {
    return 'AuthState(deviceId: $deviceId, userId: $userId, userEmail: $userEmail, isAuthenticated: $isAuthenticated, name: $name, isAdmin: $isAdmin, shouldChangePassword: $shouldChangePassword, profileImagePath: $profileImagePath)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthState &&
        other.deviceId == deviceId &&
        other.userId == userId &&
        other.userEmail == userEmail &&
        other.isAuthenticated == isAuthenticated &&
        other.name == name &&
        other.isAdmin == isAdmin &&
        other.shouldChangePassword == shouldChangePassword &&
        other.profileImagePath == profileImagePath;
  }

  @override
  int get hashCode {
    return deviceId.hashCode ^
        userId.hashCode ^
        userEmail.hashCode ^
        isAuthenticated.hashCode ^
        name.hashCode ^
        isAdmin.hashCode ^
        shouldChangePassword.hashCode ^
        profileImagePath.hashCode;
  }
}
