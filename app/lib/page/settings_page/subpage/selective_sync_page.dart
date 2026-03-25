import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys for selective sync preferences (B-3).
class SyncFilterKeys {
  static const enabledShelves = 'sync_filter_shelves';
  static const enabledTags = 'sync_filter_tags';
  static const syncAll = 'sync_filter_all';
}

/// Selective sync settings page (B-3).
///
/// Allows users to choose which shelves/tags to sync,
/// reducing bandwidth and storage on secondary devices.
class SelectiveSyncPage extends ConsumerStatefulWidget {
  const SelectiveSyncPage({super.key});

  @override
  ConsumerState<SelectiveSyncPage> createState() => _SelectiveSyncPageState();
}

class _SelectiveSyncPageState extends ConsumerState<SelectiveSyncPage> {
  bool _syncAll = true;
  List<String> _enabledShelves = [];
  List<String> _enabledTags = [];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _syncAll = prefs.getBool(SyncFilterKeys.syncAll) ?? true;
      _enabledShelves = prefs.getStringList(SyncFilterKeys.enabledShelves) ?? [];
      _enabledTags = prefs.getStringList(SyncFilterKeys.enabledTags) ?? [];
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SyncFilterKeys.syncAll, _syncAll);
    await prefs.setStringList(SyncFilterKeys.enabledShelves, _enabledShelves);
    await prefs.setStringList(SyncFilterKeys.enabledTags, _enabledTags);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('选择性同步')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('同步全部书籍'),
              subtitle: const Text('关闭后可按书架/标签筛选同步内容'),
              value: _syncAll,
              onChanged: (v) {
                setState(() => _syncAll = v);
                _savePrefs();
              },
            ),
          ),
          if (!_syncAll) ...[
            const SizedBox(height: 16),
            Text('同步书架', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _enabledShelves.isEmpty
                    ? const Text('暂无书架筛选，同步时将包含所有书架', style: TextStyle(color: Colors.grey))
                    : Wrap(
                        spacing: 8,
                        children: _enabledShelves
                            .map(
                              (s) => Chip(
                                label: Text(s),
                                onDeleted: () {
                                  setState(() => _enabledShelves.remove(s));
                                  _savePrefs();
                                },
                              ),
                            )
                            .toList(),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text('同步标签', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _enabledTags.isEmpty
                    ? const Text('暂无标签筛选，同步时将包含所有标签', style: TextStyle(color: Colors.grey))
                    : Wrap(
                        spacing: 8,
                        children: _enabledTags
                            .map(
                              (t) => Chip(
                                label: Text(t),
                                onDeleted: () {
                                  setState(() => _enabledTags.remove(t));
                                  _savePrefs();
                                },
                              ),
                            )
                            .toList(),
                      ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('说明', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('选择性同步仅影响从服务端拉取的数据范围。\n本地所有书籍仍会推送到服务端。', style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
