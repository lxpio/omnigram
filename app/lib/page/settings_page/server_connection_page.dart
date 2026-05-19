import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/providers/server_connection_provider.dart';
import 'package:omnigram/service/sync/sync_manager.dart';
import 'package:omnigram/theme/liquid_glass/app_glass_app_bar.dart';
import 'package:omnigram/theme/liquid_glass/glass_surface.dart';
import 'package:omnigram/theme/liquid_glass/glass_tokens.dart';
import 'package:omnigram/theme/liquid_glass/performance_mode.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/widgets/settings/settings_section.dart';
import 'package:omnigram/widgets/settings/settings_tile.dart';

/// Server connection setup and management. Liquid Glass layout per
/// docs/superpowers/specs/2026-05-19-settings-visual-contract.md
/// Phase 4 — rich form page wrapped in glass section cards.
class ServerConnectionPage extends ConsumerStatefulWidget {
  const ServerConnectionPage({super.key});

  @override
  ConsumerState<ServerConnectionPage> createState() =>
      _ServerConnectionPageState();
}

class _ServerConnectionPageState extends ConsumerState<ServerConnectionPage> {
  final _urlController = TextEditingController();
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isConnecting = false;
  String? _errorMessage;
  String? _serverVersion;

  @override
  void dispose() {
    _urlController.dispose();
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serverConnectionProvider);

    return Scaffold(
      appBar: const AppGlassAppBar(title: Text('Omnigram 服务器')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: state.isConnected
              ? _connectedSlivers(state)
              : _loginSlivers(),
        ),
      ),
    );
  }

  // -------- connected view --------

  List<Widget> _connectedSlivers(ServerConnectionState state) {
    return [
      _StatusHero(
        icon: Icons.cloud_done,
        title: '已连接',
        subtitle: state.serverUrl ?? '',
      ),
      const SizedBox(height: 16),
      if (state.user != null)
        SettingsSection(
          title: const Text('账户信息'),
          tiles: [
            SettingsTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('用户'),
              value: Text(state.user!.name),
            ),
            if (state.user!.email.isNotEmpty)
              SettingsTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('邮箱'),
                value: Text(state.user!.email),
              ),
            SettingsTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('角色'),
              value:
                  Text(state.user!.roleId == 1 ? '管理员' : '用户'),
            ),
          ],
        ),
      const SizedBox(height: 24),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _disconnect,
            icon: const Icon(Icons.logout),
            label: const Text('断开连接'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    ];
  }

  // -------- login form --------

  List<Widget> _loginSlivers() {
    return [
      const _StatusHero(
        icon: Icons.dns_outlined,
        title: '连接到 Omnigram 服务器',
        subtitle: '连接后，书籍、笔记和阅读进度将自动同步',
      ),
      const SizedBox(height: 16),
      SettingsSection(
        title: const Text('服务器'),
        tiles: [
          CustomSettingsTile(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: '服务器地址',
                  hintText: 'http://192.168.1.100:8080',
                  prefixIcon: const Icon(Icons.link),
                  suffixIcon: _serverVersion != null
                      ? Tooltip(
                          message: 'Omnigram v$_serverVersion',
                          child: Icon(Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary),
                        )
                      : IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _testConnection,
                          tooltip: '测试连接',
                        ),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.url,
                onChanged: (_) => setState(() => _serverVersion = null),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      SettingsSection(
        title: const Text('账户'),
        tiles: [
          CustomSettingsTile(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: _accountController,
                decoration: const InputDecoration(
                  labelText: '账号',
                  hintText: '用户名或邮箱',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ),
          CustomSettingsTile(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '密码',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                obscureText: _obscurePassword,
              ),
            ),
          ),
        ],
      ),
      if (_errorMessage != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Text(
            _errorMessage!,
            style:
                TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
          ),
        ),
      const SizedBox(height: 24),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isConnecting ? null : _connect,
            icon: _isConnecting
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.login),
            label: Text(_isConnecting ? '连接中...' : '连接'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
      const SizedBox(height: 24),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          '提示：确保你的 Omnigram 服务器已启动。'
          '通常地址格式为 http://IP:端口',
          style: OmnigramTypography.caption(context),
        ),
      ),
    ];
  }

  Future<void> _testConnection() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _errorMessage = null;
      _serverVersion = null;
    });

    final health = await ref
        .read(serverConnectionProvider.notifier)
        .testConnection(url);

    if (health != null && health.status == 'ok') {
      setState(() => _serverVersion = health.version ?? 'unknown');
    } else {
      setState(() => _errorMessage = '无法连接到服务器，请检查地址');
    }
  }

  Future<void> _connect() async {
    final url = _urlController.text.trim();
    final account = _accountController.text.trim();
    final password = _passwordController.text;

    if (url.isEmpty || account.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = '请填写所有字段');
      return;
    }

    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    final success = await ref
        .read(serverConnectionProvider.notifier)
        .connect(serverUrl: url, account: account, password: password);

    setState(() {
      _isConnecting = false;
      if (!success) {
        _errorMessage =
            ref.read(serverConnectionProvider).errorMessage ?? '连接失败，请检查账号密码';
      }
    });

    if (success) {
      ref.read(syncManagerProvider.notifier).sync();
      ref.read(syncManagerProvider.notifier).startAutoSync();
    }
  }

  Future<void> _disconnect() async {
    await ref.read(serverConnectionProvider.notifier).disconnect();
  }
}

/// Hero card at the top of the page — large icon + title + subtitle on
/// a glass surface.
class _StatusHero extends ConsumerWidget {
  const _StatusHero({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final q = ref.watch(glassQualityControllerProvider).valueOrNull ??
        GlassQuality.medium;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassSurface(
        quality: q,
        borderRadius: GlassTokens.radiusBar,
        blurSigma: GlassTokens.blurSigmaThin,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            Icon(icon, size: 44, color: scheme.primary),
            const SizedBox(height: 12),
            Text(title,
                style: OmnigramTypography.titleLarge(context)
                    .copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: OmnigramTypography.caption(context)
                  .copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
