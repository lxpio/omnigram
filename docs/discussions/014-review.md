# 014-tts-multi-engine-architecture 审计意见（第三轮）

> 审计日期：2026-03-21（第三轮，基于二轮审计修订后文档）
> 审计角色：音频技术架构师 + 全栈工程师

## 总评

综合评分：4.6 / 5（首轮 3.8 → 二轮 4.3 → 三轮 4.6）

一句话评价：经过两轮修订，014 已经是一份高质量的架构决策文档——从 TTSProvider 接口到章节级生成流程、从 fallback 链到风险合规，关键决策和技术方案完整且自洽，可以进入实施阶段。

## 二轮问题修复确认

| # | 二轮问题 | 修复状态 | 评价 |
|---|---------|---------|------|
| 1 | App 端缺少 TTSManager | ✅ Dart TTSManager + fallback to SystemTTS + 模型删除保护 | 设计清晰 |
| 2 | SidecarProvider 缺重试 | ✅ `isRetryable(err)` 单次重试，不重试 4xx/5xx | 正确 |
| 3 | Kokoro q8 质量需实测 | ✅ Phase 2 计划"q8 vs fp16 质量对比实测" | 正确 |
| 4 | POC 缺评估标准 | ✅ 5 维评估：MOS/耗时/镜像大小/API 兼容/许可证 | 正确 |
| 5 | Piper 模型需精选 | ✅ "按语言筛选后推荐精选模型，每种语言 1-2 个最佳" | 正确 |
| 6 | 章节文本提取是 P0 依赖 | ✅ "前置依赖"单独标出，Phase 1 只支持 EPUB | 务实 |
| 7 | API 缺 book_id/chapter 参数 | ✅ `/tts/audiobook/:book_id/chapter/:idx` | 正确 |
| 8 | 长文本分片合成缺失 | ✅ 按句/段分割 → 逐片合成 → 拼接，不在句中切断 | 正确 |
| 9 | SSML 接口预留 | ✅ `SynthesisOptions.SSML string` 可选字段 | 正确 |
| 10 | 多语言混合文本 | ✅ 预留扩展点，Phase 1 先用 Kokoro 8 语言覆盖 | 务实 |
| 11 | App 播放器 UX / 智能预生成规则 | ⏳ 留给 015 文档 | 合理 |
| 12 | Audiobookshelf 联动 + ID3 标签 | ✅ 音频后处理章节新增 | 加分项 |
| 13 | healthcheck start_period | ✅ `start_period: 60s` | 正确 |
| 14 | 镜像大小标注 | ✅ docker-compose 注释 + 风险章节说明 | 正确 |
| 15 | 数据持久化提醒 | ✅ 风险章节"升级/迁移时此目录不可丢失" | 正确 |
| 16 | 模型删除回退逻辑 | ✅ "正在使用时先切换到 fallback 再删除" | 正确 |

**16 条二轮问题中 15 条已修复，1 条合理留给 015。**

## 剩余问题（轻微）

以下均为锦上添花的小问题，不阻塞实施：

### 1. 架构图文案小不一致

第 28 行架构图仍写"后台生成整本有声书"，但正文已改为章节级生成。建议改为"按章节生成有声书"以保持一致。

### 2. TTSManager 重试共享同一个 ctx

```go
result, err := m.primary.Synthesize(ctx, text, opts)
if err != nil && isRetryable(err) {
    result, err = m.primary.Synthesize(ctx, text, opts)  // 同一个 ctx
}
```

如果第一次尝试耗时 100s（timeout 120s），重试时 ctx 只剩 20s，大概率再次超时。建议重试时用独立的 `context.WithTimeout`，或者在 `isRetryable` 中排除 `context.DeadlineExceeded`。实现时注意即可，不需要改文档。

### 3. POC 评估的 MOS 评分可简化

"中英文各 10 段 MOS 评分"——标准 MOS 需要 20+ 人类评估者，对独立开发者不现实。建议改为"开发者自评 + 3-5 位内测用户盲听打分"，或使用 UTMOS 等自动 MOS 评估工具。

### 4. App TTSManager 的 catch 粒度

```dart
try {
    await _active.speak(text, ...);
} catch (e) {  // catch 所有异常
    await _fallback.speak(text, ...);
}
```

`catch (e)` 会把"用户主动 stop()"也当成异常触发 fallback。实现时应区分：用户取消 → 不 fallback，引擎故障 → fallback。文档不需要改，实现时注意。

### 5. 015 文档的建议目录

014 正文提到"详细设计将在 015 文档中展开"，建议 015 覆盖以下内容（可作为 014 的附录提前列出）：
1. EPUB 章节文本提取实现（Go HTML 解析库选型）
2. 长文本分片算法（句子边界检测，中/英/日不同分句规则）
3. 任务状态机：pending → extracting → synthesizing → done / failed
4. 数据模型：`tts_task`（书级）+ `tts_chapter_task`（章节级）
5. 智能预生成规则（当前章 + 后续 3 章，跳章重算）
6. App 端有声书播放器 UX 状态机
7. 音频存储规范（目录结构、文件命名、ID3 标签字段）
8. 容量估算与清理策略

## 结论

**014 文档已达到可实施标准，无需再次修订。** 剩余的 5 个小问题在编码实现时注意即可。

下一步行动建议：
1. 启动 Phase 1 第一个 PR：删除 fishtts/、m4t/、更新 README
2. 启动 015 文档：有声书章节级生成详细设计
3. 开始实现 TTSProvider 接口 + SidecarProvider + EdgeTTSProvider
