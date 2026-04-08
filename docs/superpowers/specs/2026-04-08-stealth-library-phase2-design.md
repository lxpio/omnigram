# 隐身书房 Phase 2：AI 隔离 + 快速锁定 + 卸载策略

> **日期：** 2026-04-08
> **状态：** Approved
> **关联：** Phase 1 spec `2026-04-07-stealth-library-phase1-design.md`

---

## 1. AI 数据完全隔离

**现状：** Phase 1 已实现 — 隐身书存在独立的 `stealth_database.db`，主空间的 `BookDao`/`BookNoteDao` 完全不会查到隐身数据。AI 服务（`ConceptExtractor`、`AmbientTasks`、`AmbientAiPipeline`）全部通过主库 DAO 获取数据，天然隔离。

**需要做的：** 确保隐身空间内不触发主空间 AI pipeline。隐身阅读器（Phase 2 范围外的完整阅读集成）不调用 `AmbientTasks` 即可。当前 Phase 1 隐身书架只有导入和列表，没有阅读器集成，所以不会触发 AI。

**实际改动：** 无代码改动。标记为已验证即可。

## 2. 快速锁定

### 2.1 触发条件

- App 进入后台（`AppLifecycleState.paused`）
- App 被遮挡（`AppLifecycleState.inactive`，如来电、下拉通知栏）
- 只在当前处于隐身空间时触发

### 2.2 实现

`StealthHome` 添加 `WidgetsBindingObserver` mixin：

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused ||
      state == AppLifecycleState.inactive) {
    Navigator.of(context).pop(); // 退出隐身空间
  }
}
```

效果：用户切后台或锁屏 → 回来看到的是正常设置页。重新进入需再次生物识别。

### 2.3 改动

| 文件 | 改动 |
|------|------|
| 修改 `page/stealth/stealth_home.dart` | 改为 StatefulWidget + WidgetsBindingObserver |

## 3. 卸载策略

### 3.1 默认行为

- Android：卸载自动删除 app data（含 `stealth_database.db`）✅
- iOS：卸载删除 app data，但 **Keychain 条目保留** ⚠️

### 3.2 iOS Keychain 清理

在 `BiometricAuthService.getOrCreateKey()` 中增加一致性检查：

```dart
static Future<String?> getOrCreateKey() async {
  var key = await _storage.read(key: _keyName);
  if (key != null) {
    // Check if stealth DB still exists (handles reinstall case)
    final dbExists = await _stealthDbExists();
    if (!dbExists) {
      // Reinstall detected: old key + no DB → delete stale key, generate new
      await _storage.delete(key: _keyName);
      key = null;
    }
  }
  if (key == null) {
    key = EncryptionService.generateKey();
    await _storage.write(key: _keyName, value: key);
  }
  return key;
}

static Future<bool> _stealthDbExists() async {
  final path = join(await getAnxDataBasesPath(), 'stealth_database.db');
  return File(path).exists();
}
```

### 3.3 改动

| 文件 | 改动 |
|------|------|
| 修改 `service/stealth/biometric_auth_service.dart` | 添加 DB 存在性检查 |

## 4. 不做的

- 失败次数限制（5 次锁 30 分钟）— 生物识别系统本身有此限制
- 用户可配置卸载行为 — YAGNI
- 隐身空间内的 AI 功能 — 需要完整的隔离 AI pipeline，ROI 不高

## 5. 测试要点

- 切后台时在隐身空间 → 回来在设置页
- 切后台时在正常空间 → 无影响
- iOS 重装后 → 旧 key 被清除，新 key 生成，旧 stealth 数据不可恢复（正确行为）
- Android 重装后 → key + DB 都被清除（系统默认）
