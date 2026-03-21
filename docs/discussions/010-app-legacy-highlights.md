# Omnigram App Legacy - 亮点功能记录

> 记录日期：2026-03-21
> 用途：Fork Anx Reader 后，这些设计模式和实现可作为参考移植

---

## 值得保留的设计亮点

### 1. Fish Audio TTS 流式集成
- **文件**: `providers/tts/fishtts.service.dart`, `providers/tts/tts.service.dart`
- **亮点**: REST API + HTTP 流式音频、可配置参数（chunk_length, bitrate, temperature, top_p）、抽象 TTS 基类支持多引擎
- **Anx Reader 没有**: Anx Reader 用的是系统 TTS / flutter_tts，没有服务端 AI TTS

### 2. TTS 预取播放器
- **文件**: `providers/tts.player.provider.dart`
- **亮点**: 播放当前段落时异步预取下一段，毫秒级进度追踪，章节索引同步
- **Anx Reader 没有**: 类似功能但没有服务端预取模式

### 3. Server API 集成 + Token 刷新
- **文件**: `providers/api.provider.dart`
- **亮点**: OpenAPI 代码生成客户端、Dio 401 自动刷新重试、设备头注入、`/sys/ping` 健康检查
- **Anx Reader 完全没有**: 这是 Omnigram 核心差异化能力

### 4. 增量同步算法
- **文件**: `services/sync.service.dart`, `utils/diff.dart`
- **亮点**: O(n) 有序列表比较算法，支持远端删除检测、upsert 工作流
- **Anx Reader 没有**: WebDAV 是全量同步

### 5. EPUB CFI 书签 + 位压缩进度
- **文件**: `models/epub_document.dart`
- **亮点**: 扁平化段落索引 + 章节边界、CFI 生成、进度用位运算编码 (chapter << 32 | paragraph)

### 6. 拖拽笔记树
- **文件**: `screens/note/views/draggable_view_item.dart`
- **亮点**: 桌面/移动端自适应拖拽、三区高亮（上/中/下）、环形嵌套检测

---

## 移植优先级

| 功能 | 优先级 | 说明 |
|------|--------|------|
| Server API 集成 + Token 刷新 | P0 | 核心差异，必须移植 |
| Fish Audio TTS 流式集成 | P1 | 服务端 TTS 的客户端实现 |
| 增量同步算法 | P1 | 替代/增强 WebDAV 全量同步 |
| TTS 预取播放器 | P2 | 可在 Anx Reader TTS 基础上增强 |
| EPUB CFI 书签 | P2 | Anx Reader 已有书签系统 |
| 拖拽笔记树 | P3 | Anx Reader 笔记系统已较完善 |
