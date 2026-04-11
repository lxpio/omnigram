# TTS 设置页重设计

> **日期：** 2026-04-11
> **状态：** Approved
> **审阅：** `2026-04-11-tts-settings-redesign-review.md`（已采纳全部意见）

---

## 1. 设计哲学

用户心智模型："我想选一个声音来读我的书。" 不是"配置 TTS 引擎参数。"

**声音优先，技术隐藏。**

## 2. 页面结构

```
┌─ 朗读设置 ──────────────────────────────┐
│                                         │
│  试听                                   │
│  ┌──────────────────────────┐           │
│  │ 你好，我是你的阅读伴侣。  │  ▶ 试听   │
│  └──────────────────────────┘           │
│                                         │
│  当前声音                                │
│  🔊 小晓 (女·中文) · Kokoro 离线   换 → │
│                                         │
├─ 选择声音 ──────────────────────────────┤
│                                         │
│  📱 本地离线                             │
│  [声音卡片网格 — 已下载模型的声音]        │
│  或 "还没有本地模型 [下载推荐模型]"        │
│                                         │
│  ☁️ 在线声音                             │
│  [声音卡片网格]                          │
│                                         │
│  📱 系统声音                             │
│  [声音卡片网格 — 系统 TTS 声音]          │
│                                         │
├─ 高级设置 ──────────────── 折叠 ▸ ──────┤
│  模型管理（下载/删除）                    │
│  API 配置（Azure/OpenAI/Aliyun/Server） │
│  语速/混音                               │
└─────────────────────────────────────────┘
```

## 3. 声音卡片

每个声音是一个可点击的小卡片：

```
┌──────────┐
│ 小晓   ▶ │  ← 名字 + 试听按钮
│ 女 · 中文 │  ← 性别 + 语言
│ Kokoro   │  ← 来源（灰色小字）
└──────────┘
```

- 点击 ▶ = 用试听文本试听该声音
- 点击卡片 = 选中为当前声音
- 选中的卡片有主题色边框
- 卡片按语言分组排列（当前设备语言排最前）

## 4. 声音来源分区

### 4.1 本地离线

显示所有已下载模型的可用声音：
- Kokoro 模型 → 显示所有 speaker 声音卡片（小晓、云曦、Sarah 等）
- Piper 模型 → 每个模型一个声音卡片

**空状态（无已下载模型）：**
```
还没有本地语音模型
[下载 Kokoro v1.0 推荐] ← 一键下载推荐模型
更多模型请在 高级设置 → 模型管理 中查看
```

下载完成后空状态消失，声音卡片出现。

### 4.2 在线声音

按子来源分组显示：

#### 4.2.1 Omnigram Server
- 需要 server 连接已配置（见"高级设置 → API 配置"）
- 已配置且可达 → 显示服务端返回的声音
- 未配置 → 不显示此子分区

#### 4.2.2 Edge TTS
- 预置一组常用声音（数量以实现为准，当前约 20+ 个）
- 无需配置，直接显示，按语言分组

#### 4.2.3 Azure / OpenAI / Aliyun
- 未配置 → 显示灰态占位卡片："未配置 [去配置]"，点击跳转高级设置
- 配置完整但拉取失败 → 显示"拉取失败 [重试]"
- 配置完整且拉取成功 → 显示声音卡片
- 高级设置中修改配置后自动刷新对应声音列表

### 4.3 系统声音

- 设备系统 TTS 声音

## 5. 试听区域

页面顶部固定：
- 可编辑的试听文本框
- ▶ 按钮用当前选中的声音播放
- 在声音卡片上的 ▶ 也能试听（用该声音 + 试听文本）

## 6. 当前声音

试听区下方显示当前选中的声音：
- 声音名 + 性别 + 语言
- 来源标签（Kokoro 离线 / Edge 在线 / 系统）
- 没有选中时提示"请选择一个声音"

## 7. 高级设置（折叠）

默认折叠，展开后包含：

### 7.1 模型管理（sherpa-onnx 本地模型）
- 列出所有内置模型 + 下载状态
- 已下载：显示 ✅ + 删除按钮
- 未下载：显示大小 + 下载按钮（带进度条）
- 下载中：进度条

### 7.2 API 配置
- Omnigram Server：url + token
- Azure：key + region
- OpenAI：url + key + model + instructions
- Aliyun：appkey + accessKeyId + secret + endpoint
- 配置变更后对应声音区域自动刷新

### 7.3 朗读参数
- 语速滑条
- 混音模式开关

## 8. 数据流与配置持久化

### 8.1 声音唯一标识

引入 `source:voiceId` 格式：
```
edge:zh-CN-XiaoxiaoNeural
sherpa:kokoro-multi-lang-v1_0:47      ← source:modelId:speakerId
azure:en-US-JennyNeural
openai:nova
aliyun:xiaoyun
server:voice-1
system:com.apple.ttsbundle.Tingting
```

新增 `Prefs().selectedVoiceFullId` 存储完整标识。

### 8.2 自动切引擎

```
用户选择声音卡片
  → 解析 source（edge/sherpa/azure/...）
  → 自动切换 TtsService
  → 保存 selectedVoiceFullId
  → 更新"当前声音"显示
```

### 8.3 迁移兼容

旧配置（`ttsService` + `voice`）升级到新结构：
- 读取旧 `Prefs().ttsService` + `getSelectedVoice()`
- 拼接为 `source:voiceId` 格式
- 写入 `selectedVoiceFullId`
- 旧字段保留不删（向后兼容）
- 如果迁移后找不到对应声音 → 降级到 Edge 首个中文声音

## 9. 文件改动

| 文件 | 改动 |
|------|------|
| 重写 `page/settings_page/narrate.dart` | 完全重写 UI 布局 |
| 修改 `service/tts/sherpa_onnx_tts.dart` | getVoices 返回 speaker 声音 |
| 修改 `service/tts/tts_service_provider.dart` | 支持 selectedVoiceFullId |
| 修改 `service/tts/tts_factory.dart` | 支持按声音来源自动切换引擎 |
| 修改 `config/shared_preference_provider.dart` | 新增 selectedVoiceFullId |
| 新建 `widgets/settings/voice_card.dart` | 声音卡片组件 |
| 新建 `widgets/settings/voice_grid.dart` | 声音网格组件 |
| 修改 L10n ARB | 新增相关 key |

## 10. 改动范围说明

### 不做的事
- 不改变各 TTS Provider 的实现协议（Azure SSML、OpenAI JSON 等）
- 不增加新的 TTS 引擎
- 不做声音收藏/自定义排序
- 不做语音克隆

### 允许的改动
- **命令层**：调整 TtsFactory、TtsService、Provider 的选择与路由逻辑，实现"按声音来源自动切换引擎"
- **配置层**：引入 `selectedVoiceFullId` 结构，简化跨服务选择的持久化
- **UI 层**：聚合所有服务的 voices，统一呈现为声音卡片网格

## 11. 测试要点

### 正向场景
- 首次进入：Edge 声音可见可选，本地区域显示下载引导
- 下载 Kokoro 后：本地声音卡片出现
- 选声音自动切换引擎（不需要手动选引擎）
- 试听按钮正常播放
- 高级设置折叠/展开正常
- Azure/OpenAI/Aliyun 配置 key 后声音出现在在线区域
- Server 已连接时声音出现在在线区域

### 兼容与迁移
- 升级前用户（已保存的服务+voice）打开设置页后正常显示当前声音
- 旧配置无对应声音时自动降级到 Edge 首个中文声音并提示

### 失败与容错
- API 配置不完整时在线声音区显示"待配置"灰态
- 拉取 voices 超时/失败时显示"拉取失败 [重试]"
- 高级设置修改 API 配置后在线声音列表自动刷新
- 试听中切换声音/服务时正常中断前一个播放

### 边界与性能
- 100+ 声音卡片时列表不卡顿
- 快速在服务间切换（Edge → Kokoro → Edge）时正常
