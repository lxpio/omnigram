import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnigram/theme/typography.dart';
import 'package:omnigram/theme/omnigram_theme.dart';
import 'package:omnigram/widgets/common/omnigram_card.dart';
import 'package:omnigram/page/settings_page/companion_settings_page.dart';
import 'package:omnigram/page/settings_page/reading.dart';
import 'package:omnigram/page/settings_page/sync.dart';
import 'package:omnigram/page/settings_page/more_settings_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(OmnigramTheme.pageHorizontalPadding),
        children: [
          const SizedBox(height: 16),
          Text('设置', style: OmnigramTypography.displayLarge(context)),
          const SizedBox(height: 24),
          _SettingsSection(
            icon: Icons.person_outline,
            title: '阅读身份',
            subtitle: '阅读目标 · 偏好语言 · 账户',
            onTap: () {
              // TODO Sprint 2
            },
          ),
          const SizedBox(height: 12),
          _SettingsSection(
            icon: Icons.smart_toy_outlined,
            title: '阅读伴侣',
            subtitle: '性格 · 声音 · 行为偏好',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CompanionSettingsPage(),
                )),
          ),
          const SizedBox(height: 12),
          _SettingsSection(
            icon: Icons.text_format,
            title: '阅读体验',
            subtitle: '字体 · 排版 · 翻页 · 主题',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReadingSettings(),
                )),
          ),
          const SizedBox(height: 12),
          _SettingsSection(
            icon: Icons.sync,
            title: '同步与存储',
            subtitle: 'WebDAV · 导入导出 · 缓存',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SyncSetting(),
                )),
          ),
          const SizedBox(height: 12),
          _SettingsSection(
            icon: Icons.build_outlined,
            title: '高级',
            subtitle: 'AI 服务配置 · AI Chat (调试) · 开发者选项',
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SubMoreSettings(),
                )),
          ),
          const SizedBox(height: 12),
          _SettingsSection(
            icon: Icons.info_outline,
            title: '关于 Omnigram',
            subtitle: '版本 · 许可 · 链接',
            onTap: () {
              // TODO: about page
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OmnigramCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: OmnigramTypography.titleMedium(context)),
                const SizedBox(height: 2),
                Text(subtitle, style: OmnigramTypography.caption(context)),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              color: Theme.of(context).colorScheme.outlineVariant),
        ],
      ),
    );
  }
}
