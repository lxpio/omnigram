import 'dart:io';

import 'package:flutter_udid/flutter_udid.dart';
import 'package:flutter/material.dart';
import 'package:omnigram/entities/isar_store.entity.dart';
import 'package:omnigram/entities/user.entity.dart';
import 'package:omnigram/providers/api.provider.dart';
import 'package:logging/logging.dart';
import 'package:omnigram/utils/hash.dart';
import 'package:openapi/api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


part 'auth.provider.g.dart';


@riverpod
class Auth extends _$Auth {


  final log = Logger("AuthNotifier");

  @override
  AuthState build() {

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
    String serverUrl,
  ) async {

//这里应该是加载界面时执行，不应该放在登陆接口
    try {
      // Resolve API server endpoint from user provided serverUrl
      await ref.read(apiServiceProvider.notifier).resolveAndSetEndpoint(serverUrl);
      // await _apiService.serverInfoApi.pingServer();
    } catch (e) {
      debugPrint('Invalid Server Endpoint Url $e');
      return false;
    }

   

    try {

      final api = ref.watch(apiServiceProvider);

      var loginResponse = await api.authTokenPost(loginCredentialDto:
        LoginCredentialDto(
          account: account,
          password: password,
        ),
      );

      if (loginResponse == null) {
        debugPrint('Login Response is null');
        return false;
      }

      return setSuccessLoginInfo(
        accessToken: loginResponse.accessToken,
        serverUrl: serverUrl,
      );
    } catch (e) {
      debugPrint("Error logging in $e");
      return false;
    }
  }

  Future<void> logout() async {
    var log = Logger('AuthenticationNotifier');
    try {
      String? userEmail = IsarStore.tryGet(StoreKey.currentUser)?.email;

      await ref.watch(apiServiceProvider).authLogoutPost()
          .then((_) => log.info("Logout was successful for $userEmail"))
          .onError(
            (error, stackTrace) =>
                log.severe("Logout failed for $userEmail", error, stackTrace),
          );

      await Future.wait([
        // clearAssetsAndAlbums(_db),
        IsarStore.delete(StoreKey.currentUser),
        IsarStore.delete(StoreKey.accessToken),
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

  Future<bool> setSuccessLoginInfo({
    required String accessToken,
    required String serverUrl,
  }) async {

    // Get the deviceid from the store if it exists, otherwise generate a new one
    String deviceId =
        IsarStore.tryGet(StoreKey.deviceId) ?? await FlutterUdid.consistentUdid;

    bool shouldChangePassword = false;
    User? user = IsarStore.tryGet(StoreKey.currentUser);

    UserDto? userResponse;
    // UserPreferencesResponseDto? userPreferences;
    try {

      userResponse = await ref.watch(apiServiceProvider).userUserinfoGet();

      
    } on ApiException catch (error, stackTrace) {
      if (error.code == 401) {
        log.severe("Unauthorized access, token likely expired. Logging out.");
        return false;
      }
      log.severe(
        "Error getting user information from the server [API EXCEPTION]",
        stackTrace,
      );
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

      // shouldChangePassword = userResponse.shouldChangePassword;
      user = User.fromUserDto(userResponse);//userPreferences
      IsarStore.put(StoreKey.deviceId, deviceId);
      IsarStore.put(StoreKey.deviceIdHash, fastHash(deviceId));
      IsarStore.put(StoreKey.currentUser,user);
      IsarStore.put(StoreKey.serverUrl, serverUrl);
      IsarStore.put(StoreKey.accessToken, accessToken);

      
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
      return false;
    }

    // If the user is null, the login was not successful
    // and we don't have a local copy of the user from a prior successful login
    if (user == null) {
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
      return false;
        return false;
    }

    
  
    state = state.copyWith(
      isAuthenticated: true,
      userId: user.id,
      userEmail: user.email,
      name: user.name,
      profileImagePath: user.profileImagePath,
      isAdmin: user.roleId < 100,
      shouldChangePassword: shouldChangePassword,
      deviceId: deviceId,
    );

    return true;
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
    return AuthState(
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      name: name ?? this.name,
      isAdmin: isAdmin ?? this.isAdmin,
      shouldChangePassword: shouldChangePassword ?? this.shouldChangePassword,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
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
