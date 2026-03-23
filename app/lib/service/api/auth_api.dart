import '../../models/server/auth_response.dart';
import '../../models/server/server_system.dart';
import '../../models/server/server_user.dart';
import 'omnigram_api.dart';

/// Authentication & user management API.
class AuthApi {
  AuthApi(this._api);
  final OmnigramApi _api;

  /// Login and obtain access token.
  Future<AuthTokenResponse> login({required String account, required String password, String? deviceId}) async {
    final response = await _api.post(
      '/auth/token',
      data: {'account': account, 'password': password, 'device_id': deviceId ?? '', 'grant_type': 'password'},
      fromJson: (data) => AuthTokenResponse.fromJson(data),
    );

    _api.setAuth(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      account: account,
      deviceId: deviceId,
    );
    return response;
  }

  /// Refresh an expired access token.
  Future<AuthTokenResponse> refreshToken({
    required String account,
    required String refreshToken,
    String? deviceId,
  }) async {
    return _api.post(
      '/auth/token/refresh',
      data: {'account': account, 'device_id': deviceId ?? '', 'refresh_token': refreshToken},
      fromJson: (data) => AuthTokenResponse.fromJson(data),
    );
  }

  /// Logout and clear session.
  Future<void> logout() async {
    await _api.postVoid('/auth/logout');
    _api.clearAuth();
  }

  /// Get current user info.
  Future<ServerUser> getUserInfo() async {
    return _api.get('/user/userinfo', fromJson: (data) => ServerUser.fromJson(data));
  }

  // ── API Key Management ──────────────────────────────────────────

  /// List API keys for a user.
  Future<List<ServerApiToken>> listApiKeys(int userId) async {
    return _api.getList('/auth/accounts/$userId/apikeys', fromJson: ServerApiToken.fromJson);
  }

  /// Create a new API key.
  Future<ServerApiToken> createApiKey(int userId) async {
    return _api.post('/auth/accounts/$userId/apikeys', fromJson: (data) => ServerApiToken.fromJson(data));
  }

  /// Delete an API key.
  Future<void> deleteApiKey(int userId, int keyId) async {
    await _api.delete('/auth/accounts/$userId/apikeys/$keyId');
  }

  // ── Health Check ────────────────────────────────────────────────

  /// Check if the server is an Omnigram server.
  Future<HealthResponse> healthCheck() async {
    return _api.get('/healthz', fromJson: (data) => HealthResponse.fromJson(data));
  }

  /// Ping system.
  Future<ServerSystemInfo> ping() async {
    return _api.get('/sys/ping', fromJson: (data) => ServerSystemInfo.fromJson(data));
  }
}
