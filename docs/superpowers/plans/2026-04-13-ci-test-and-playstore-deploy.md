# CI 质量门禁 + Play Store 自动发布 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** CI 打 tag 自动发布到 Google Play Internal Testing；PR/push 自动跑 analyze + test 作为质量门禁。

**Architecture:** 新增两个 GitHub Actions workflow：`test-app.yaml`（质量门禁，PR 触发）和 `deploy-playstore.yaml`（Play Store 发布，tag 触发，依赖 build-android 产出的签名 APK 后额外构建 AAB 上传）。复用已有的 Fastlane `release_play_store` lane。

**Tech Stack:** GitHub Actions, Fastlane Supply, Flutter Test, Google Play API (Service Account)

---

## File Structure

| Action | File | Responsibility |
|--------|------|----------------|
| Create | `.github/workflows/test-app.yaml` | PR/push 质量门禁：analyze + test |
| Create | `.github/workflows/deploy-playstore.yaml` | 构建 AAB + fastlane supply 上传到 Play Store |
| Modify | `.github/workflows/build-app.yaml` | 接入 deploy-playstore（alpha/beta tag 触发） |
| Modify | `app/android/fastlane/Fastfile` | 修正 track 逻辑，internal 默认 completed 而非 draft |
| Modify | `docs/github-secrets-checklist.md` | `PLAY_STORE_JSON_KEY` 从 optional 移到 required |
| Modify | `docs/superpowers/PROGRESS.md` | 更新测试和 CI 状态 |

---

### Task 1: 质量门禁 workflow（flutter analyze + flutter test）

**Files:**
- Create: `.github/workflows/test-app.yaml`

- [ ] **Step 1: 创建 test-app.yaml**

```yaml
name: Test App

on:
  pull_request:
    paths:
      - 'app/**'
  push:
    branches: [main]
    paths:
      - 'app/**'
  workflow_dispatch:

jobs:
  test:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    defaults:
      run:
        working-directory: app

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: '3.41.5'

      - name: Install dependencies
        run: flutter pub get

      - name: Generate code
        run: |
          flutter gen-l10n
          dart run build_runner build --delete-conflicting-outputs

      - name: Analyze
        run: flutter analyze lib/

      - name: Test
        run: flutter test --no-pub
```

- [ ] **Step 2: 推送并验证 workflow 语法**

```bash
cd /Users/liuyou/Workspace/omnigram
# 验证 yaml 语法
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/test-app.yaml'))" && echo "YAML valid"
```

Expected: `YAML valid`

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/test-app.yaml
git commit -m "ci: add flutter analyze + test quality gate on PR/push"
```

---

### Task 2: Play Store 部署 workflow

**Files:**
- Create: `.github/workflows/deploy-playstore.yaml`

- [ ] **Step 1: 创建 deploy-playstore.yaml**

这个 workflow 被 `build-app.yaml` 调用，在 Android 构建之后运行。它单独构建 AAB（因为 Play Store 要求 AAB 不要 APK），然后用 fastlane supply 上传。

```yaml
name: Deploy to Play Store

on:
  workflow_call:
    inputs:
      version:
        required: true
        type: string
      flutter_version:
        required: true
        type: string
      track:
        required: false
        type: string
        default: 'internal'
    secrets:
      PLAY_STORE_JSON_KEY:
        required: true
      KEYSTORE_BASE64:
        required: true
      KEYSTORE_PASSWORD:
        required: true
      KEY_PASSWORD:
        required: true
      KEY_ALIAS:
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    defaults:
      run:
        working-directory: app

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: ${{ inputs.flutter_version }}

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'
          cache: 'gradle'

      - name: Setup Android signing
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > android/app/keystore.jks
          echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" > android/key.properties
          echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
          echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
          echo "storeFile=keystore.jks" >> android/key.properties

      - name: Setup Play Store credentials
        run: |
          echo '${{ secrets.PLAY_STORE_JSON_KEY }}' > google_service_account.json

      - name: Install dependencies & codegen
        run: |
          flutter pub get
          flutter gen-l10n
          dart run build_runner build --delete-conflicting-outputs

      - name: Build AAB
        run: flutter build appbundle --release --dart-define=isPlayStore=true

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3'
          bundler-cache: true
          working-directory: app/android

      - name: Deploy to Play Store
        run: |
          cd android
          bundle exec fastlane android release_play_store track:${{ inputs.track }}
```

- [ ] **Step 2: 验证 YAML 语法**

```bash
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/deploy-playstore.yaml'))" && echo "YAML valid"
```

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/deploy-playstore.yaml
git commit -m "ci: add Play Store deploy workflow (fastlane supply to internal track)"
```

---

### Task 3: 修正 Fastlane track 逻辑

**Files:**
- Modify: `app/android/fastlane/Fastfile`

- [ ] **Step 1: 修改 release_status 逻辑**

当前 `release_status` 硬编码为 `'draft'`，internal track 应该用 `'completed'` 才能让测试人员直接收到更新。只有 production 才需要 draft（手动确认）。

修改 `app/android/fastlane/Fastfile` 中的 `release_play_store` lane：

```ruby
  desc "Release to Play Store"
  lane :release_play_store do |options|
    build_android

    track = options[:track] || 'internal'
    # internal/alpha/beta: completed (auto-publish to testers)
    # production: draft (requires manual review in Play Console)
    release_status = (track == 'production') ? 'draft' : 'completed'

    supply(
      track: track,
      release_status: release_status,
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      json_key: google_service_account_json_path,
      skip_upload_apk: true,
      skip_upload_metadata: true,
      skip_upload_changelogs: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )
  end
```

- [ ] **Step 2: Commit**

```bash
git add app/android/fastlane/Fastfile
git commit -m "fix: fastlane use completed status for internal track, draft for production"
```

---

### Task 4: 接入 build-app.yaml 主流程

**Files:**
- Modify: `.github/workflows/build-app.yaml`

- [ ] **Step 1: 在 build-app.yaml 中添加 deploy-playstore job**

在 `robo-test` job 之后、`release` job 之前添加。仅 alpha 和 beta tag 自动发布到 internal track，正式 tag 不自动发（避免误操作）。

在 `build-app.yaml` 的 `robo-test:` block 之后、`# build-playstore:` 注释块的位置，替换为：

```yaml
  deploy-playstore:
    needs: [setup, build-android]
    if: needs.setup.outputs.is_alpha == 'true' || needs.setup.outputs.is_beta == 'true'
    uses: ./.github/workflows/deploy-playstore.yaml
    with:
      version: ${{ needs.setup.outputs.version }}
      flutter_version: ${{ needs.setup.outputs.flutter_version }}
      track: internal
    secrets:
      PLAY_STORE_JSON_KEY: ${{ secrets.PLAY_STORE_JSON_KEY }}
      KEYSTORE_BASE64: ${{ secrets.KEYSTORE_BASE64 }}
      KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
      KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
      KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
```

同时删除旧的 `# build-playstore:` 注释块（第 84-97 行）。

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/build-app.yaml
git commit -m "ci: wire Play Store deploy into release pipeline (alpha/beta → internal track)"
```

---

### Task 5: 添加 Gemfile 确保 CI 能 bundle install

**Files:**
- Check: `app/android/Gemfile`

- [ ] **Step 1: 检查 Gemfile 是否存在**

```bash
ls -la /Users/liuyou/Workspace/omnigram/app/android/Gemfile
```

如果不存在，创建 `app/android/Gemfile`：

```ruby
source "https://rubygems.org"

gem "fastlane"
```

然后生成 lock 文件：

```bash
cd /Users/liuyou/Workspace/omnigram/app/android && bundle install
```

如果已存在且有 `Gemfile.lock`，跳过此步。

- [ ] **Step 2: Commit（如果有变更）**

```bash
git add app/android/Gemfile app/android/Gemfile.lock
git commit -m "chore: add Gemfile for fastlane CI dependency management"
```

---

### Task 6: 更新文档

**Files:**
- Modify: `docs/github-secrets-checklist.md`
- Modify: `docs/superpowers/PROGRESS.md`

- [ ] **Step 1: 更新 github-secrets-checklist.md**

将 `PLAY_STORE_JSON_KEY` 从 "Optional (Archived)" 移到 "Required" 区域的 Android 部分。添加说明：

```markdown
| `PLAY_STORE_JSON_KEY` | Google Play Service Account JSON key for fastlane supply. [Setup guide](https://docs.fastlane.tools/actions/supply/#setup) |
```

- [ ] **Step 2: 更新 PROGRESS.md 测试状态**

在测试状态的 App 端测试表中更新：

```markdown
| L1 静态分析 | `flutter analyze` | P0 | ✅ CI 门禁 | PR/push 自动运行，test-app.yaml |
```

在 CI Workflows 表中添加：

```markdown
| `.github/workflows/test-app.yaml` | App 质量门禁 | ✅ 已创建 | PR/push 触发 analyze + test |
| `.github/workflows/deploy-playstore.yaml` | Play Store 发布 | ✅ 已创建 | alpha/beta tag → internal track |
```

在更新记录中添加：

```markdown
| 2026-04-13 | **CI 质量门禁 + Play Store 自动发布**：test-app.yaml（analyze+test PR 门禁）、deploy-playstore.yaml（fastlane supply → internal track）、build-app.yaml 接入自动发布 |
```

- [ ] **Step 3: Commit**

```bash
git add docs/github-secrets-checklist.md docs/superpowers/PROGRESS.md
git commit -m "docs: update CI status and Play Store secret requirements"
```

---

## 发布前 Checklist

完成上述 Tasks 后，还需要你手动操作一次：

1. **配置 GitHub Secret `PLAY_STORE_JSON_KEY`：**
   - 在 Google Cloud Console 创建 Service Account（如果还没有）
   - 在 Google Play Console → Setup → API access 中关联该 Service Account
   - 授予 "Release manager" 或 "Release to production, exclude devices, and use Play App Signing" 权限
   - 下载 JSON key，粘贴到 GitHub repo → Settings → Secrets → `PLAY_STORE_JSON_KEY`

2. **验证：** 打一个 alpha tag 测试整个流程
   ```bash
   git tag v1.14.0-alpha.1
   git push origin v1.14.0-alpha.1
   ```

3. **确认** CI 构建成功 + Play Store Internal Testing 收到新版本
