# TTS 设置页重设计 · 设计评审报告

> **日期：** 2026-04-11  
> **评审人：** 代码审查  
> **规格文档：** `docs/superpowers/specs/2026-04-11-tts-settings-redesign.md`  
> **现状基线：** 代码库现存 7 个 TTS 服务 (System, Edge, Sherpa, Azure, OpenAI, Aliyun, Server)

---

## 总体评价

✅ 产品方向清晰，用户心智正确（"选声音"而非"配置引擎"）  
❌ 架构落地说明不足，兼容迁移方案缺失  
⚠️ 若按现状直接开工，极可能出现实现偏差和验收争议

**建议进度：** 补齐本评审中的 6 项风险后再锁定开工时间

---

## 带外问题清单

### 🔴 P1 — 高严重：规格与现有"服务模型"冲突，未定义迁移路径

**问题定位：**
- 规格 §8 "数据流" 描述用户"选声音 → 自动切引擎"
- 现有代码 `tts_service.dart` 定义 7 个独立服务 enum
- 现有 `narrate.dart` 是"先选服务，再取该服务 voices"的单服务视角
- 现有 providers 中 `ttsVoicesProvider` 监听 `ttsServiceProvider` 变化

**当前代码引用：**
- [tts_service.dart](app/lib/service/tts/tts_service.dart#L13) — 服务 enum 定义 (7 个)
- [narrate.dart](app/lib/page/settings_page/narrate.dart#L404) — ServiceSelection DropDown (先选服务)
- [narrate.dart](app/lib/page/settings_page/narrate.dart#L422) — onChanged 里 switchTtsType
- [tts_providers.dart](app/lib/providers/tts_providers.dart#L23) — ttsVoicesProvider 依赖 ttsServiceProvider

**风险描述：**
若仅改 UI 拉平声音网格，但配置数据模型未改，则会出现：
- 底层仍然按 `ttsService` (单选) 存储，声音选择无法持久化到独立字段
- 可能出现"UI 看起来统一，实际切换时还是按原服务走"的混淆状态
- 跨服务切换时丢失之前服务的 API 配置

**建议修复：**

1. **引入"声音唯一标识"概念**
   ```
   格式：source:voiceShortName (例如 "edge:zh-CN-XiaoxiaoNeural", "sherpa:0", "azure:en-US-JennyNeural")
   存储：Prefs 新增 selectedVoiceFullId (保持向后兼容 ttsService + voice 旧字段)
   ```

2. **在规格补一节"配置持久化与迁移"**
   - 如何从仅存 `ttsService` 字符串迁移到 `{source, shortName}` 结构
   - 如果发现不到该声音，降级到什么默认值（建议：该来源的首个声音 → 系统 → 静默失败）
   - 向后兼容：旧配置打开应自动迁移并提示

3. **调整 TtsFactory 的自动切换逻辑**
   - `createTts()` 需识别声音来源，而非硬读 `Prefs().ttsService`
   - 实现 `switchToVoiceSource(source)` 方法（而非 switchTtsType）

---

### 🔴 P1 — 高严重：Server TTS 服务在规格中被隐性移除

**问题定位：**
- 规格 §4 "声音来源分区" 只列了三类：本地离线、在线声音(Edge/Azure/OpenAI/Aliyun)、系统声音
- 现网代码 `tts_service.dart` 定义有 `TtsService.server`
- 当前 narrate.dart 第 416 行可选 `'Omnigram Server'`
- 但规格完全没提 server 的位置与支持状态

**当前代码引用：**
- [tts_service.dart](app/lib/service/tts/tts_service.dart#L19) — enum 包含 server
- [narrate.dart](app/lib/page/settings_page/narrate.dart#L416) — dropdown 选项
- [server_tts_backend.dart](app/lib/service/tts/server_tts_backend.dart#L93) — getVoices() 实现

**风险描述：**
重设计时容易忽视 server 的支持范围：
- 如果视为"在线声音的一部分"，需要 server_id 和 serviceId 的映射
- 如果视为"暂不支持"，需要有迁移通知和 fallback 机制
- 如果默认行为是隐藏它，可能导致已配置 server 的老用户无法使用

**建议修复：**

补充规格 §4.2 或新增 §4.4 "服务端声音"：
```markdown
### 4.2 在线声音

包含以下子来源（按优先级）：

#### 4.2.1 Omnigram Server
- 需要 server 连接已配置（见"高级设置"）
- 调用 GET /tts/voices 获取可用声音
- 调用 POST /tts/speak 生成音频

#### 4.2.2 Edge TTS
- 预置 24 个常用声音，无需配置

#### 4.2.3 Azure/OpenAI/Aliyun
- 仅在"高级设置"中配置了 API key 后出现
```

或显式在 §10 "不做" 中声明：
```markdown
- 暂不在新 UI 中支持 Omnigram Server TTS
  （原 dropdown 中的"Omnigram Server"选项将在高级设置中保留，用户仍可手动切换）
```

---

### 🟠 P2 — 中严重：声音来源触发条件不准确，容易空列表与误判

**问题定位：**
- 规格 §4.2 和 §7.2 都写"配置完成后声音自动出现"
- 但实际需要：配置校验通过 **且** 拉取成功
- 各服务的失败情形不同：
  - Azure：需要 key 且 region（region 有默认值"global"，但可能无权限）
  - OpenAI：需要 key 和有效的 url（可定制成私有 endpoint）
  - Aliyun：需要 appkey + accessKeyId + accessKeySecret 三个都不为空

**当前代码引用：**
- [azure_tts_backend.dart](app/lib/service/tts/azure_tts_backend.dart#L77) — getVoices() 返回 [] 若 key/region 缺
- [azure_tts_backend.dart](app/lib/service/tts/azure_tts_backend.dart#L140) — 拉取失败时 throw 异常
- [openai_tts_backend.dart](app/lib/service/tts/openai_tts_backend.dart#L116) — key 必须非空
- [aliyun/aliyun_tts_backend.dart](app/lib/service/tts/aliyun/aliyun_tts_backend.dart#L138) — 三个字段都要检查

**风险描述：**
实现时需决定：
- API 配置不完整时：在线声音区是否显示 "待配置" 占位符 vs 空、灰、加载中？
- 拉取失败（网络/API 错误）而非配置缺少时：如何区分 vs 显示相同错误文案？
- 用户改了配置后，声音列表是实时刷新 vs 用户主动点"刷新"？

**建议修复：**

在规格补充 §4.2："在线声音触发与失败处理"：

```markdown
### 4.2 在线声音

显示条件：
- **Edge TTS**：始终显示（无需配置）
- **Azure/OpenAI/Aliyun**：
  - 若配置空或不完整 → 显示"未配置 [配置]"灰态卡片加载
  - 若配置完整但拉取失败 → 显示"拉取失败 [重试]"提示
  - 若配置完整且拉取成功 → 显示声音卡片网格

拉取失败时用户操作：
- 高级设置中修改配置 → 自动刷新当前页面的在线声音列表
- 或显式"刷新"按钮

```

---

### 🟠 P2 — 中严重：固定"Edge 19 个声音"会导致文档快速过时

**问题定位：**
- 规格 §4.2 写"Edge TTS 声音列表（19 个，无需配置，直接可用）"
- 实际代码 [edge_tts_backend.dart](app/lib/service/tts/edge_tts_backend.dart#L125) 定义 24 个静态声音
- 数值是硬编码在代码中的常量，可能因 Edge API 更新而变化

**风险描述：**
- 规格写"19 个"，开发/测试可能据此验收，代码实际 24 个，验收失败
- 将来 Edge 如果增声音，需同时改规格 + 代码，容易遗漏

**建议修复：**

改规格措辞为：
```markdown
- **Edge TTS**：预置一组常用边缘声音（数量以实现为准，当前约 20+ 个）
  无需配置，直接在"在线声音"区显示，分组按语言排列
```

---

### 🟠 P2 — 中严重："不改变底层逻辑"宣称与改动清单冲突

**问题定位：**
- 规格 §10 "不做" 列"不改变 TTS 引擎底层逻辑"
- 规格 §9 "文件改动" 涉及
  - 重写 narrate.dart UI 层 ✓（只是 UI，无底层改动）
  - 修改 sherpa_onnx_tts.dart getVoices (⚠️ 涉及底层 speaker 提取逻辑)
  - 新建 voice_card.dart, voice_grid.dart ✓（纯 UI 组件）
- 若要实现"按声音自动切引擎"，则需修改：
  - `TtsFactory` 的 `createTts()` 逻辑（底层切换策略）
  - `Prefs` 的配置存储结构（底层数据模型）
  - Provider 的聚合逻辑（多服务声音收集）

**风险描述：**
当前宣称"不改底层"容易与实现冲突，导致范围蠕变或隐性改动无人Review。

**建议修复：**

改规格 §10 为：
```markdown
## 10. 改动范围说明

### 不做的事
- 不改变各 TTS Provider 的实现协议（Azure SSML、OpenAI JSON 等）
- 不增加新的 TTS 引擎
- 不做声音收藏/自定义排序
- 不做语音克隆

### 允许的改动
- **命令层改动**：调整 TtsFactory、TtsService、Provider 的选择与路由逻辑
  以实现"按声音来源自动切换引擎"
- **配置层改动**：引入"声音唯一标识"结构，简化跨服务选择的持久化
- **UI 层改动**：聚合所有服务的 voices，统一呈现为声音卡片网格

```

---

### 🟡 P3 — 低严重：测试点偏 happy path，缺少回归保护

**问题定位：**
- 规格 §11 "测试要点" 只有 7 条，全是正向场景
- 缺少边界条件、失败态、多设备、兼容性场景

**当前代码引用：**
[docs/superpowers/specs/2026-04-11-tts-settings-redesign.md](docs/superpowers/specs/2026-04-11-tts-settings-redesign.md#L153)

**风险描述：**
上线后容易遇到隐藏的回归：
- 旧配置用户升级后朗读失败（迁移 bug）
- A/B 测试场景的语音中断（异常切换）
- 某个云厂商 API 超时导致整个页面卡死（容错缺失）

**建议补充测试点：**

```markdown
## 11. 测试要点

### 正向场景
- 首次进入：Edge 声音可见可选，本地区域显示下载引导
- 下载 Kokoro 后：本地声音卡片出现
- 选声音自动切换引擎（不需要手动选引擎）
- 试听按钮正常播放
- 高级设置折叠/展开正常
- Azure/OpenAI/Aliyun 配置 key 后声音出现在在线区域

### 兼容与迁移
- 升级前用户（已保存的服务+voice）打开设置页后正常显示当前使用的声音
- 旧配置无对应声音时自动降级到该来源首个声音并提示

### 失败与容错
- API 配置不完整时在线声音区显示"待配置"状态
- 拉取 voices 超时(网络失败) 时显示"拉取失败，点击重试"
- 高级设置修改 API 配置后在线声音列表自动刷新或手动刷新
- 试听中切换声音、切换服务、回到阅读器的并发行为正常

### 平台特异性
- iOS/Android 系统声音列表非空（不同设备差异大，至少验证不崩溃）
- 旧版本升级时旧 TtsService 字段能正确迁移到新声音 ID 结构

### 边界与性能
- 显示 100+ 声音卡片时列表不卡顿、不 OOM
- 快速在服务间切换（例如 Edge → Kokoro → Edge）时缓冲区清空正确
```

---

## 实施建议优先级

| 级别 | 项目 | 工作量估算 | 关键链路 |
|------|------|----------|--------|
| P0⚠️必做 | P1 迁移路径方案 | 方案设计 2h | 开工前需锁定 |
| P0⚠️必做 | P1 Server 支持说明 | 方案设计 1h | 开工前需锁定 |
| P1 | P2 触发条件补充 | 规格修订 1h | 开工时读清 |
| P1 | P2 Edge 声音数量改述 | 规格修订 0.5h | 开工时修 |
| P1 | P2 底层逻辑声明 | 规格修订 1h | 开工时读清 |
| P2 | P3 测试补充 | 测试设计 2h | 开工时加入 checklist |

**预估总工作量：** 规格修订 + 方案补充 ~8h；不阻塞编码开工（可并行），但强烈建议锁定 P0 后再合并代码

---

## 后续行动

1. **立即**：确认规格作者是否同意上述 6 项改动方向
2. **本周**：选一项 P0 启动设计评审（建议先做"迁移路径方案"）
3. **下周**：融合反馈后重新发布修订版规格，作为开工 baseline
4. **同步开工**：可先从 UI 层（voice_card, voice_grid 组件）轻重启动，等待 P0 方案后再上主逻辑改动

---

## 附录 A：快速对标表

| 维度 | 规格说法 | 代码现状 | 是否一致 | 风险等级 |
|------|---------|---------|--------|--------|
| 声音来源分区 | 3 类（本地、在线、系统） | 7 个独立服务 enum | ❌ | P1 |
| Server 支持 | 未提及 | 实现了 | ❌ | P1 |
| 自动切引擎 | 按声音来源 | 按 ttsService 字符串 | ❌ | P1 |
| 配置持久化 | 隐含（规格未讲） | serviceId + voice | ⚠️ | P1 |
| Edge 声音量 | 19 个 | 24 个 | ❌ | P2 |
| 底层改动范围 | "不改" | 实际会改 | ❌ | P2 |
| 失败态处理 | 隐含 | 分 provider 差异大 | ⚠️ | P2 |

---

**审查完成日期：** 2026-04-11  
**建议重新评审日期：** 2026-04-18（预留补充说明时间）
