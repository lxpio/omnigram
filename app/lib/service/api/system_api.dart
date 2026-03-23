import '../../models/server/server_system.dart';
import '../../models/server/server_user.dart';
import 'omnigram_api.dart';

/// System configuration API (admin functions).
class SystemApi {
  SystemApi(this._api);
  final OmnigramApi _api;

  /// Get system info.
  Future<ServerSystemInfo> getSystemInfo() async {
    return _api.get('/sys/info', fromJson: (data) => ServerSystemInfo.fromJson(data));
  }

  /// Update system config (admin only).
  Future<void> updateSystemConfig(Map<String, dynamic> config) async {
    await _api.putVoid('/sys/info', data: config);
  }

  // ── AI Config ───────────────────────────────────────────────────

  /// Get AI service status.
  Future<ServerAiConfig> getAiStatus() async {
    return _api.get('/sys/ai/status', fromJson: (data) => ServerAiConfig.fromJson(data));
  }

  /// Update AI config (admin only).
  Future<ServerAiConfig> updateAiConfig(ServerAiConfig config) async {
    return _api.put('/sys/ai/config', data: config.toJson(), fromJson: (data) => ServerAiConfig.fromJson(data));
  }

  // ── Library Scan ────────────────────────────────────────────────

  /// Get library scan status.
  Future<ServerScanStatus> getScanStatus() async {
    return _api.get('/sys/scan/status', fromJson: (data) => ServerScanStatus.fromJson(data));
  }

  /// Start library scan.
  Future<void> startScan() async {
    await _api.postVoid('/sys/scan/run');
  }

  /// Stop library scan.
  Future<void> stopScan() async {
    await _api.postVoid('/sys/scan/stop');
  }

  /// Import from Calibre library.
  Future<void> importCalibre(String calibrePath) async {
    await _api.postVoid('/sys/import/calibre', data: {'calibre_path': calibrePath});
  }
}

/// Admin account management API.
class AdminApi {
  AdminApi(this._api);
  final OmnigramApi _api;

  /// Create a user account.
  Future<ServerUser> createAccount({required String userName, required String email, required String password}) async {
    return _api.post(
      '/admin/accounts',
      data: {'user_name': userName, 'email': email, 'password': password},
      fromJson: (data) => ServerUser.fromJson(data),
    );
  }

  /// List all accounts.
  Future<List<ServerUser>> listAccounts() async {
    final response = await _api.dio.get('/admin/accounts');
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('items')) {
      return (data['items'] as List).map((e) => ServerUser.fromJson(e)).toList();
    }
    return [];
  }

  /// Get account details.
  Future<ServerUser> getAccount(int userId) async {
    return _api.get('/admin/accounts/$userId', fromJson: (data) => ServerUser.fromJson(data));
  }

  /// Delete an account.
  Future<void> deleteAccount(int userId) async {
    await _api.delete('/admin/accounts/$userId');
  }
}
