import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/server_connection_provider.dart';
import '../../service/sync/sync_manager.dart';
import '../../theme/omnigram_theme.dart';
import '../../theme/typography.dart';

/// Server connection setup and management page.
class ServerConnectionPage extends ConsumerStatefulWidget {
  const ServerConnectionPage({super.key});

  @override
  ConsumerState<ServerConnectionPage> createState() => _ServerConnectionPageState();
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
    final connectionState = ref.watch(serverConnectionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Omnigram 服务器')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(OmnigramTheme.pageHorizontalPadding),
          children: [if (connectionState.isConnected) _buildConnectedView(connectionState) else _buildLoginForm()],
        ),
      ),
    );
  }

  Widget _buildConnectedView(ServerConnectionState connectionState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Server status card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.cloud_done, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text('已连接', style: OmnigramTypography.titleLarge(context)),
              const SizedBox(height: 4),
              Text(connectionState.serverUrl ?? '', style: OmnigramTypography.caption(context)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // User info
        if (connectionState.user != null) ...[
          _InfoTile(icon: Icons.person, label: '用户', value: connectionState.user!.name),
          if (connectionState.user!.email.isNotEmpty)
            _InfoTile(icon: Icons.email, label: '邮箱', value: connectionState.user!.email),
          _InfoTile(icon: Icons.badge, label: '角色', value: connectionState.user!.roleId == 1 ? '管理员' : '用户'),
        ],

        const SizedBox(height: 32),

        // Disconnect button
        SizedBox(
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
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.dns_outlined, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text('连接到 Omnigram 服务器', style: OmnigramTypography.titleLarge(context)),
              const SizedBox(height: 4),
              Text('连接后，书籍、笔记和阅读进度将自动同步', style: OmnigramTypography.caption(context), textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Server URL
        TextField(
          controller: _urlController,
          decoration: InputDecoration(
            labelText: '服务器地址',
            hintText: 'http://192.168.1.100:8080',
            prefixIcon: const Icon(Icons.link),
            suffixIcon: _serverVersion != null
                ? Tooltip(
                    message: 'Omnigram v$_serverVersion',
                    child: Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                  )
                : IconButton(icon: const Icon(Icons.search), onPressed: _testConnection, tooltip: '测试连接'),
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
          onChanged: (_) => setState(() => _serverVersion = null),
        ),
        const SizedBox(height: 16),

        // Account
        TextField(
          controller: _accountController,
          decoration: const InputDecoration(
            labelText: '账号',
            hintText: '用户名或邮箱',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        // Password
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: '密码',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            border: const OutlineInputBorder(),
          ),
          obscureText: _obscurePassword,
        ),
        const SizedBox(height: 8),

        // Error message
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13)),
          ),
        const SizedBox(height: 24),

        // Connect button
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isConnecting ? null : _connect,
            icon: _isConnecting
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary),
                  )
                : const Icon(Icons.login),
            label: Text(_isConnecting ? '连接中...' : '连接'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ),

        const SizedBox(height: 24),
        // Help text
        Text(
          '提示：确保你的 Omnigram 服务器已启动。'
          '通常地址格式为 http://IP:端口',
          style: OmnigramTypography.caption(context),
        ),
      ],
    );
  }

  Future<void> _testConnection() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _errorMessage = null;
      _serverVersion = null;
    });

    final health = await ref.read(serverConnectionProvider.notifier).testConnection(url);

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
        _errorMessage = ref.read(serverConnectionProvider).errorMessage ?? '连接失败，请检查账号密码';
      }
    });

    // Trigger sync after successful login
    if (success) {
      ref.read(syncManagerProvider.notifier).sync();
      ref.read(syncManagerProvider.notifier).startAutoSync();
    }
  }

  Future<void> _disconnect() async {
    await ref.read(serverConnectionProvider.notifier).disconnect();
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 12),
          Text(label, style: OmnigramTypography.caption(context)),
          const Spacer(),
          Text(value, style: OmnigramTypography.bodyMedium(context)),
        ],
      ),
    );
  }
}
