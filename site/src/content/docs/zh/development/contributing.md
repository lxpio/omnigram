---
title: 参与贡献
description: 如何为 Omnigram 项目做贡献
---

欢迎为 Omnigram 做出贡献！项目包含两个主要组件：Go 后端服务器和 Flutter 客户端应用。

## 仓库结构

```
omnigram/
├── server/     # Go 后端（Gin + GORM）
├── app/        # Flutter 客户端（基于 Anx Reader 分支，MIT 许可）
├── site/       # 网站和文档（Astro + Starlight）
├── docs/       # 设计文档和 API 规范
└── Makefile    # 顶层构建编排
```

## 开发环境搭建

### 服务器（Go）

要求：Go 1.23+

```bash
cd server
make          # 构建服务器二进制文件
make docker   # 构建 Docker 镜像
```

服务器使用 Gin 进行 HTTP 路由、GORM 进行数据库访问、BadgerDB 进行键值存储。入口点位于 `server/cmd/omni-server/`。

### 应用（Flutter）

要求：Flutter 3.41+、Dart 3.11+

```bash
cd app
flutter pub get                          # 安装依赖
flutter gen-l10n                         # 生成本地化文件
dart run build_runner build --delete-conflicting-outputs  # 代码生成
flutter analyze lib/                     # 静态分析
flutter build apk --split-per-abi       # 构建 Android APK
```

或使用根目录 Makefile 快捷命令：

```bash
make app-deps       # flutter pub get
make app-codegen    # 本地化 + build_runner
make app-analyze    # flutter analyze
make app-build-apk  # 构建 APK
```

应用使用 Riverpod v2 进行状态管理（带代码生成）。模型使用 freezed 和 json_serializable。

### 网站

要求：Node.js 18+

```bash
cd site
npm install
npm run dev     # 本地开发服务器
npm run build   # 生产构建
```

## 编码规范

- **语言：** 代码使用英文；注释和文档可以使用中文
- **代码生成：** 修改 providers、models 或本地化文件后需运行代码生成
- **格式化：** 使用标准格式化工具（Go 使用 `gofmt`，Dart 使用 `dart format`）
- **代码检查：** 提交应用更改前运行 `flutter analyze lib/`

## Pull Request 流程

1. Fork 仓库并创建功能分支
2. 提交清晰、描述性的 commit
3. 确保项目可以构建并通过分析：
   - 服务器：`cd server && make`
   - 应用：`make app-analyze`
4. 向 `main` 分支提交 Pull Request
5. 描述您的 PR 做了什么以及为什么

## 版本管理

Git 标签（`v*.*.*`）会触发 CI 发布流水线：
- **服务器：** 为 `arm64` 和 `amd64` 构建 Docker 镜像
- **应用：** 自动构建并签名 Android APK

## 许可证

- 服务器：MIT
- 应用：MIT（基于 [Anx Reader](https://github.com/Anxcye/anx-reader) 分支）
