import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/server/auth_response.dart';
import '../models/server/server_user.dart';
import '../service/api/annotation_api.dart';
import '../service/api/auth_api.dart';
import '../service/api/book_api.dart';
import '../service/api/omnigram_api.dart';
import '../service/api/progress_api.dart';
import '../service/api/shelf_api.dart';
import '../service/api/sync_api.dart';
import '../service/api/system_api.dart';
import '../service/api/tts_api.dart';

part 'server_connection_provider.g.dart';

/// Persistent key constants for SharedPreferences.
class _Keys {
  static const serverUrl = 'omnigram_server_url';
  static const accessToken = 'omnigram_access_token';
  static const refreshToken = 'omnigram_refresh_token';
  static const account = 'omnigram_account';
  static const deviceId = 'omnigram_device_id';
  static const userId = 'omnigram_user_id';
  static const userName = 'omnigram_user_name';
  static const isConnected = 'omnigram_is_connected';
}

/// Server connection state.
enum ServerConnectionStatus { disconnected, connecting, connected, error }

/// State of the Omnigram Server connection.
class ServerConnectionState {
  const ServerConnectionState({
    this.status = ServerConnectionStatus.disconnected,
    this.serverUrl,
    this.user,
    this.errorMessage,
  });

  final ServerConnectionStatus status;
  final String? serverUrl;
  final ServerUser? user;
  final String? errorMessage;

  bool get isConnected => status == ServerConnectionStatus.connected;
  bool get isDisconnected => status == ServerConnectionStatus.disconnected;

  ServerConnectionState copyWith({
    ServerConnectionStatus? status,
    String? serverUrl,
    ServerUser? user,
    String? errorMessage,
  }) {
    return ServerConnectionState(
      status: status ?? this.status,
      serverUrl: serverUrl ?? this.serverUrl,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

/// Manages the Omnigram Server connection lifecycle.
///
/// Provides typed API clients for all server endpoints.
@Riverpod(keepAlive: true)
class ServerConnection extends _$ServerConnection {
  OmnigramApi? _api;
  static const _secureStorage = FlutterSecureStorage();

  @override
  ServerConnectionState build() {
    _tryRestoreConnection();
    return const ServerConnectionState();
  }

  // ── Public API ──────────────────────────────────────────────────

  /// Connect to an Omnigram Server.
  Future<bool> connect({
    required String serverUrl,
    required String account,
    required String password,
    String? deviceId,
  }) async {
    state = state.copyWith(status: ServerConnectionStatus.connecting);

    final normalizedUrl = _normalizeUrl(serverUrl);
    _api = OmnigramApi(baseUrl: normalizedUrl);

    try {
      // 1. Health check — verify it's an Omnigram Server
      final authApi = AuthApi(_api!);
      final health = await authApi.healthCheck();
      if (health.status != 'healthy') {
        state = state.copyWith(
          status: ServerConnectionStatus.error,
          errorMessage: 'Not an Omnigram server: ${health.error ?? "unknown"}',
        );
        return false;
      }

      // 2. Login
      final token = await authApi.login(account: account, password: password, deviceId: deviceId);

      // 3. Get user info
      final user = await authApi.getUserInfo();

      // 4. Persist credentials
      await _persistCredentials(
        serverUrl: normalizedUrl,
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        account: account,
        deviceId: deviceId,
        userId: user.id,
        userName: user.name,
      );

      state = ServerConnectionState(status: ServerConnectionStatus.connected, serverUrl: normalizedUrl, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(status: ServerConnectionStatus.error, errorMessage: e.toString());
      _api = null;
      return false;
    }
  }

  /// Disconnect from the server.
  Future<void> disconnect() async {
    try {
      if (_api != null) {
        await AuthApi(_api!).logout();
      }
    } catch (_) {
      // Ignore logout failures
    }
    _api?.clearAuth();
    _api = null;
    await _clearCredentials();
    state = const ServerConnectionState();
  }

  /// Test connection to a server URL without logging in.
  Future<HealthResponse?> testConnection(String serverUrl) async {
    final testApi = OmnigramApi(baseUrl: _normalizeUrl(serverUrl));
    try {
      return await AuthApi(testApi).healthCheck();
    } catch (_) {
      return null;
    }
  }

  // ── API Client Accessors ────────────────────────────────────────

  OmnigramApi? get api => _api;
  AuthApi? get auth => _api != null ? AuthApi(_api!) : null;
  BookApi? get books => _api != null ? BookApi(_api!) : null;
  AnnotationApi? get annotations => _api != null ? AnnotationApi(_api!) : null;
  ProgressApi? get progress => _api != null ? ProgressApi(_api!) : null;
  ShelfApi? get shelves => _api != null ? ShelfApi(_api!) : null;
  TagApi? get tags => _api != null ? TagApi(_api!) : null;
  SyncApi? get sync => _api != null ? SyncApi(_api!) : null;
  StatsApi? get stats => _api != null ? StatsApi(_api!) : null;
  SystemApi? get system => _api != null ? SystemApi(_api!) : null;
  AdminApi? get admin => _api != null ? AdminApi(_api!) : null;
  TtsApi? get tts => _api != null ? TtsApi(_api!) : null;

  // ── Private ─────────────────────────────────────────────────────

  String _normalizeUrl(String url) {
    url = url.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    return url;
  }

  Future<void> _tryRestoreConnection() async {
    final prefs = await SharedPreferences.getInstance();
    final isConnected = prefs.getBool(_Keys.isConnected) ?? false;
    if (!isConnected) return;

    final serverUrl = prefs.getString(_Keys.serverUrl);
    final accessToken = await _secureStorage.read(key: _Keys.accessToken);
    final refreshToken = await _secureStorage.read(key: _Keys.refreshToken);
    final account = prefs.getString(_Keys.account);
    final deviceId = prefs.getString(_Keys.deviceId);

    if (serverUrl == null || accessToken == null) return;

    _api = OmnigramApi(baseUrl: serverUrl);
    _api!.setAuth(accessToken: accessToken, refreshToken: refreshToken ?? '', account: account, deviceId: deviceId);

    // Verify token is still valid
    try {
      final user = await AuthApi(_api!).getUserInfo();
      state = ServerConnectionState(status: ServerConnectionStatus.connected, serverUrl: serverUrl, user: user);
    } catch (_) {
      // Token expired or server unreachable — stay disconnected
      _api = null;
      state = const ServerConnectionState();
    }
  }

  Future<void> _persistCredentials({
    required String serverUrl,
    required String accessToken,
    required String refreshToken,
    required String account,
    String? deviceId,
    required int userId,
    required String userName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_Keys.serverUrl, serverUrl);
    await _secureStorage.write(key: _Keys.accessToken, value: accessToken);
    await _secureStorage.write(key: _Keys.refreshToken, value: refreshToken);
    await prefs.setString(_Keys.account, account);
    if (deviceId != null) await prefs.setString(_Keys.deviceId, deviceId);
    await prefs.setInt(_Keys.userId, userId);
    await prefs.setString(_Keys.userName, userName);
    await prefs.setBool(_Keys.isConnected, true);
  }

  Future<void> _clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    // Clear tokens from secure storage
    await _secureStorage.delete(key: _Keys.accessToken);
    await _secureStorage.delete(key: _Keys.refreshToken);
    // Clear non-sensitive data from SharedPreferences
    for (final key in [
      _Keys.serverUrl,
      _Keys.account,
      _Keys.deviceId,
      _Keys.userId,
      _Keys.userName,
      _Keys.isConnected,
    ]) {
      await prefs.remove(key);
    }
  }
}

/// Convenience provider: is the server connected?
@riverpod
bool isServerConnected(IsServerConnectedRef ref) {
  return ref.watch(serverConnectionProvider).isConnected;
}
