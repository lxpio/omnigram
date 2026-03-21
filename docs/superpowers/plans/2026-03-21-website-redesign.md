# Omnigram Website Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Omnigram's promotional website with Astro — Landing Page, Features page, Docs (Starlight), Blog, fully bilingual EN/ZH, dark tech aesthetic, deployed to GitHub Pages.

**Architecture:** Astro project in `site/` directory at project root. Starlight plugin handles `/docs/**` only; all other pages (landing, features, blog, 404) use custom `BaseLayout.astro`. Shared `Nav.astro` component bridges both via Starlight `components` override. i18n via Astro native routing with `/zh/` prefix for Chinese.

**Tech Stack:** Astro 5, @astrojs/starlight, @astrojs/sitemap, @astrojs/rss, Tailwind CSS 3, TypeScript

**Spec:** `docs/superpowers/specs/2026-03-21-website-redesign-design.md`

---

## File Structure

```
site/
├── package.json
├── astro.config.mjs              # Astro + Starlight + Tailwind config
├── tailwind.config.js            # Dark theme color palette
├── tsconfig.json
├── public/
│   ├── favicon.svg
│   ├── favicon.ico
│   ├── og-image.png
│   ├── logo/
│   │   ├── logo_white.svg
│   │   ├── logo_with_letter_dark.svg
│   │   └── logo_with_letter_white.svg
│   └── icons/
│       ├── icon-192x192.png
│       ├── icon-512x512.png
│       └── apple-touch-icon.png
├── src/
│   ├── styles/global.css         # Tailwind directives + base dark styles
│   ├── i18n/
│   │   ├── ui.ts                 # i18n helper functions
│   │   ├── en.json               # English UI strings
│   │   └── zh.json               # Chinese UI strings
│   ├── layouts/
│   │   ├── BaseLayout.astro      # Shared layout: head + nav + footer
│   │   └── BlogPost.astro        # Blog post layout
│   ├── components/
│   │   ├── Nav.astro             # Sticky nav bar
│   │   ├── LanguageSwitch.astro  # EN/ZH toggle
│   │   ├── Hero.astro            # Hero section
│   │   ├── FeatureCard.astro     # Single feature card
│   │   ├── FeatureGrid.astro     # 5-card feature grid
│   │   ├── QuadrantChart.astro   # Competitive positioning SVG
│   │   ├── QuickStart.astro      # Docker code block with copy
│   │   ├── CTA.astro             # Call-to-action section
│   │   └── Footer.astro          # Footer with links
│   ├── pages/
│   │   ├── index.astro           # Landing page EN
│   │   ├── features.astro        # Features page EN
│   │   ├── 404.astro             # Custom 404
│   │   ├── blog/
│   │   │   ├── index.astro       # Blog list EN
│   │   │   └── [...slug].astro   # Blog post EN
│   │   ├── zh/
│   │   │   ├── index.astro       # Landing page ZH
│   │   │   ├── features.astro    # Features page ZH
│   │   │   └── blog/
│   │   │       ├── index.astro   # Blog list ZH
│   │   │       └── [...slug].astro
│   │   └── rss.xml.ts            # RSS feed
│   └── content/
│       ├── config.ts             # Content collection schemas
│       ├── docs/                  # EN docs (root locale for Starlight)
│       │   ├── index.mdx         # Docs landing
│       │   ├── getting-started/
│       │   │   ├── quick-start.md
│       │   │   └── installation.md
│       │   └── development/
│       │       └── contributing.md
│       ├── docs/zh/              # ZH docs (Starlight zh locale)
│       └── blog/
│           └── welcome.md        # First blog post
```

---

### Task 1: Project Scaffold + Astro Config

**Files:**
- Create: `site/package.json`
- Create: `site/astro.config.mjs`
- Create: `site/tailwind.config.js`
- Create: `site/tsconfig.json`
- Create: `site/src/styles/global.css`

- [ ] **Step 1: Create the Astro project**

```bash
cd /Users/liuyou/Workspace/omnigram
mkdir site && cd site
npm init -y
npm install astro @astrojs/starlight @astrojs/tailwind @astrojs/sitemap @astrojs/rss tailwindcss
npm install -D typescript
```

- [ ] **Step 2: Write `astro.config.mjs`**

```js
// site/astro.config.mjs
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import tailwind from '@astrojs/tailwind';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://omnigram.lxpio.com',
  integrations: [
    starlight({
      title: 'Omnigram',
      locales: {
        // EN as root locale — docs served at /docs/ (not /en/docs/)
        root: { label: 'English', lang: 'en' },
        zh: { label: '中文', lang: 'zh' },
      },
      sidebar: [
        {
          label: 'Getting Started',
          items: [
            { label: 'Quick Start', slug: 'getting-started/quick-start' },
            { label: 'Installation', slug: 'getting-started/installation' },
          ],
        },
        {
          label: 'Development',
          items: [
            { label: 'Contributing', slug: 'development/contributing' },
          ],
        },
      ],
      customCss: ['./src/styles/global.css'],
      components: {
        // Override full Starlight header to inject our Nav
        Header: './src/components/StarlightHeader.astro',
      },
    }),
    tailwind(),
    sitemap(),
  ],
});
```

> **Note on Starlight Header override:** We override `Header` (not `SiteTitle`) to replace the entire Starlight header with our shared `Nav.astro`. Create a thin wrapper `StarlightHeader.astro` that renders `<Nav />` and is compatible with Starlight's slot expectations.

- [ ] **Step 3: Write `tailwind.config.js`**

```js
// site/tailwind.config.js
/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  theme: {
    extend: {
      colors: {
        brand: {
          bg: '#0f172a',
          'bg-light': '#1e293b',
          border: '#334155',
          accent: '#6366f1',
          'accent-light': '#8b5cf6',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
        mono: ['JetBrains Mono', 'ui-monospace', 'monospace'],
      },
    },
  },
  plugins: [],
};
```

- [ ] **Step 4: Write `tsconfig.json`**

```json
{
  "extends": "astro/tsconfigs/strict",
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  }
}
```

- [ ] **Step 5: Write `src/styles/global.css`**

```css
/* site/src/styles/global.css */
@import "tailwindcss";

@layer base {
  body {
    @apply bg-brand-bg text-slate-100 antialiased;
  }
}
```

- [ ] **Step 6: Verify project builds**

```bash
cd site
npx astro build
```

Expected: Build succeeds with no errors.

- [ ] **Step 7: Commit**

```bash
git add site/
git commit -m "feat(site): scaffold Astro project with Starlight + Tailwind"
```

---

### Task 2: Copy Brand Assets + Static Files

**Files:**
- Create: `site/public/favicon.svg`
- Create: `site/public/favicon.ico`
- Create: `site/public/logo/` (3 files)
- Create: `site/public/icons/` (3 files)

- [ ] **Step 1: Copy assets from project root**

```bash
cd /Users/liuyou/Workspace/omnigram
mkdir -p site/public/logo site/public/icons

cp assets/img/logo_white.svg site/public/favicon.svg
cp assets/img/favicon.ico site/public/favicon.ico
cp assets/img/logo_white.svg site/public/logo/
cp assets/img/logo_with_letter_dark.svg site/public/logo/
cp assets/img/logo_with_letter_white.svg site/public/logo/
cp assets/img/icon-192x192.png site/public/icons/
cp assets/img/icon-512x512.png site/public/icons/
cp assets/img/apple-touch-icon.png site/public/icons/
```

- [ ] **Step 2: Verify files exist**

```bash
ls -la site/public/logo/ site/public/icons/ site/public/favicon.*
```

Expected: 8 files total.

- [ ] **Step 3: Commit**

```bash
git add site/public/
git commit -m "feat(site): add brand assets (logo, favicon, icons)"
```

---

### Task 3: i18n Setup

**Files:**
- Create: `site/src/i18n/en.json`
- Create: `site/src/i18n/zh.json`
- Create: `site/src/i18n/ui.ts`

- [ ] **Step 1: Write EN strings**

```json
// site/src/i18n/en.json
{
  "nav": {
    "features": "Features",
    "docs": "Docs",
    "blog": "Blog",
    "github": "GitHub"
  },
  "hero": {
    "tagline": "Your Library, Alive.",
    "subtitle": "Jellyfin for videos. Immich for photos.",
    "subtitleHighlight": "Omnigram for books.",
    "description": "AI-native, self-hosted book library. Deploy on your NAS in seconds.",
    "cta": "Deploy Now →",
    "github": "⭐ Star on GitHub",
    "docker": "docker compose up -d"
  },
  "features": {
    "sectionLabel": "Core Features",
    "sectionTitle": "What makes Omnigram different",
    "ai": { "title": "AI-Enhanced Reading", "desc": "Summarize, Q&A, semantic search across your entire library" },
    "tts": { "title": "TTS Audiobooks", "desc": "Turn any ebook into high-quality audiobook with AI voices" },
    "library": { "title": "Library Management", "desc": "Scan, organize, tag, search — better than Calibre-Web" },
    "reader": { "title": "Multi-Platform Reader", "desc": "iOS, Android, macOS, Windows — read anywhere, sync everywhere" },
    "deploy": { "title": "One-Click Deploy", "desc": "Docker Compose on any NAS. Open source, self-hosted, yours forever" }
  },
  "quadrant": {
    "sectionLabel": "Why Omnigram",
    "sectionTitle": "The only AI-native self-hosted book library"
  },
  "quickstart": {
    "sectionTitle": "Deploy in 30 seconds"
  },
  "cta": {
    "title": "Ready to bring your library alive?",
    "subtitle": "Open source. Self-hosted. AI-native.",
    "primary": "Get Started →",
    "secondary": "Documentation"
  },
  "footer": {
    "license": "MIT License",
    "copyright": "© 2026 Omnigram"
  }
}
```

- [ ] **Step 2: Write ZH strings**

```json
// site/src/i18n/zh.json
{
  "nav": {
    "features": "功能",
    "docs": "文档",
    "blog": "博客",
    "github": "GitHub"
  },
  "hero": {
    "tagline": "让书架活过来",
    "subtitle": "Jellyfin 管视频，Immich 管照片，",
    "subtitleHighlight": "Omnigram 管书。",
    "description": "AI 原生、自托管书库服务。Docker 一键部署到你的 NAS。",
    "cta": "立即部署 →",
    "github": "⭐ GitHub Star",
    "docker": "docker compose up -d"
  },
  "features": {
    "sectionLabel": "核心功能",
    "sectionTitle": "Omnigram 的差异化",
    "ai": { "title": "AI 增强阅读", "desc": "自动摘要、智能问答、全书库语义搜索" },
    "tts": { "title": "TTS 有声书", "desc": "任意电子书一键生成高质量有声书" },
    "library": { "title": "书库管理", "desc": "扫描、整理、标签、搜索 —— 比 Calibre-Web 更好用" },
    "reader": { "title": "多端阅读器", "desc": "iOS、Android、macOS、Windows —— 随处阅读，全端同步" },
    "deploy": { "title": "一键部署", "desc": "Docker Compose 部署到任何 NAS，开源、自托管、数据永远属于你" }
  },
  "quadrant": {
    "sectionLabel": "为什么选 Omnigram",
    "sectionTitle": "唯一的 AI 原生自托管书库"
  },
  "quickstart": {
    "sectionTitle": "30 秒完成部署"
  },
  "cta": {
    "title": "准备好让书架活过来了吗？",
    "subtitle": "开源 · 自托管 · AI 原生",
    "primary": "立即开始 →",
    "secondary": "查看文档"
  },
  "footer": {
    "license": "MIT 许可证",
    "copyright": "© 2026 Omnigram"
  }
}
```

- [ ] **Step 3: Write i18n helper**

```ts
// site/src/i18n/ui.ts
import en from './en.json';
import zh from './zh.json';

const translations = { en, zh } as const;

export type Lang = keyof typeof translations;

export function getLangFromUrl(url: URL): Lang {
  const [, lang] = url.pathname.split('/');
  if (lang === 'zh') return 'zh';
  return 'en';
}

export function t(lang: Lang): typeof en {
  return translations[lang];
}

export function getLocalePath(lang: Lang, path: string): string {
  if (lang === 'en') return path;
  return `/zh${path}`;
}
```

- [ ] **Step 4: Commit**

```bash
git add site/src/i18n/
git commit -m "feat(site): add i18n strings (EN/ZH) and helper"
```

---

### Task 4: Base Layout + Nav + Footer Components

**Files:**
- Create: `site/src/components/Nav.astro`
- Create: `site/src/components/LanguageSwitch.astro`
- Create: `site/src/components/Footer.astro`
- Create: `site/src/layouts/BaseLayout.astro`

- [ ] **Step 1: Write `Nav.astro`**

Sticky navigation bar with logo, links, and language switch. Dark background with backdrop blur.

```astro
---
// site/src/components/Nav.astro
import LanguageSwitch from './LanguageSwitch.astro';
import { getLangFromUrl, t } from '@/i18n/ui';

const lang = getLangFromUrl(Astro.url);
const ui = t(lang);
const prefix = lang === 'zh' ? '/zh' : '';
---
<nav class="fixed top-0 left-0 right-0 z-50 bg-brand-bg/80 backdrop-blur-lg border-b border-brand-border">
  <div class="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
    <a href={`${prefix}/`} class="flex items-center gap-2">
      <img src="/logo/logo_white.svg" alt="Omnigram" class="w-8 h-8" />
      <span class="text-slate-100 font-semibold text-lg">Omnigram</span>
    </a>
    <div class="flex items-center gap-6">
      <a href={`${prefix}/features`} class="text-slate-400 hover:text-slate-100 text-sm transition">{ui.nav.features}</a>
      <a href={`${prefix}/docs`} class="text-slate-400 hover:text-slate-100 text-sm transition">{ui.nav.docs}</a>
      <a href={`${prefix}/blog`} class="text-slate-400 hover:text-slate-100 text-sm transition">{ui.nav.blog}</a>
      <a href="https://github.com/lxpio/omnigram" target="_blank" class="text-slate-400 hover:text-slate-100 text-sm transition">{ui.nav.github}</a>
      <LanguageSwitch lang={lang} />
    </div>
  </div>
</nav>
```

- [ ] **Step 2: Write `LanguageSwitch.astro`**

```astro
---
// site/src/components/LanguageSwitch.astro
import type { Lang } from '@/i18n/ui';

interface Props {
  lang: Lang;
}

const { lang } = Astro.props;
const currentPath = Astro.url.pathname;
const targetPath = lang === 'en'
  ? `/zh${currentPath}`
  : currentPath.replace(/^\/zh/, '') || '/';
const targetLabel = lang === 'en' ? '中文' : 'EN';
---
<a
  href={targetPath}
  class="text-sm bg-brand-bg-light border border-brand-border px-3 py-1 rounded text-slate-400 hover:text-slate-100 transition"
>
  {targetLabel}
</a>
```

- [ ] **Step 3: Write `Footer.astro`**

```astro
---
// site/src/components/Footer.astro
import { getLangFromUrl, t } from '@/i18n/ui';

const lang = getLangFromUrl(Astro.url);
const ui = t(lang);
---
<footer class="border-t border-brand-border py-8">
  <div class="max-w-6xl mx-auto px-6 flex flex-col items-center gap-4">
    <div class="flex gap-6">
      <a href="https://github.com/lxpio/omnigram" target="_blank" class="text-slate-500 hover:text-slate-300 text-sm transition">GitHub</a>
      <a href="https://github.com/lxpio/omnigram/discussions" target="_blank" class="text-slate-500 hover:text-slate-300 text-sm transition">Discussions</a>
    </div>
    <p class="text-slate-600 text-xs">{ui.footer.copyright} · {ui.footer.license}</p>
  </div>
</footer>
```

- [ ] **Step 4: Write `BaseLayout.astro`**

```astro
---
// site/src/layouts/BaseLayout.astro
import Nav from '@/components/Nav.astro';
import Footer from '@/components/Footer.astro';
import '@/styles/global.css';

interface Props {
  title: string;
  description?: string;
}

const { title, description = 'AI-native, self-hosted book library' } = Astro.props;
---
<!doctype html>
<html lang={Astro.url.pathname.startsWith('/zh') ? 'zh' : 'en'}>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="description" content={description} />
  <meta property="og:title" content={title} />
  <meta property="og:description" content={description} />
  <meta property="og:image" content="/og-image.png" />
  <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
  <link rel="icon" type="image/x-icon" href="/favicon.ico" />
  <title>{title} | Omnigram</title>
</head>
<body class="min-h-screen flex flex-col">
  <Nav />
  <main class="flex-1 pt-16">
    <slot />
  </main>
  <Footer />
</body>
</html>
```

- [ ] **Step 5: Verify build**

```bash
cd site && npx astro build
```

- [ ] **Step 6: Commit**

```bash
git add site/src/components/ site/src/layouts/
git commit -m "feat(site): add BaseLayout, Nav, Footer, LanguageSwitch"
```

---

### Task 5: Landing Page — Hero + Feature Cards

**Files:**
- Create: `site/src/components/Hero.astro`
- Create: `site/src/components/FeatureCard.astro`
- Create: `site/src/components/FeatureGrid.astro`
- Create: `site/src/pages/index.astro`

- [ ] **Step 1: Write `Hero.astro`**

```astro
---
// site/src/components/Hero.astro
import { getLangFromUrl, t } from '@/i18n/ui';

const lang = getLangFromUrl(Astro.url);
const ui = t(lang);
---
<section class="relative py-24 px-6 text-center bg-gradient-to-br from-brand-bg to-brand-bg-light">
  <div class="max-w-4xl mx-auto">
    <h1 class="text-5xl md:text-6xl font-extrabold tracking-tight text-slate-100">
      {ui.hero.tagline}
    </h1>
    <p class="mt-4 text-lg text-slate-400">
      {ui.hero.subtitle}
      <span class="text-indigo-400 font-semibold">{ui.hero.subtitleHighlight}</span>
    </p>
    <p class="mt-2 text-slate-500">{ui.hero.description}</p>
    <div class="mt-8 flex gap-3 justify-center flex-wrap">
      <a href="/docs/getting-started/quick-start" class="bg-brand-accent hover:bg-indigo-600 text-white px-6 py-3 rounded-lg font-semibold transition">
        {ui.hero.cta}
      </a>
      <a href="https://github.com/lxpio/omnigram" target="_blank" class="border border-brand-border text-slate-300 hover:text-white px-6 py-3 rounded-lg transition">
        {ui.hero.github}
      </a>
    </div>
    <div class="mt-6">
      <code class="bg-brand-bg-light border border-brand-border px-4 py-2 rounded-lg text-brand-accent text-sm font-mono">
        {ui.hero.docker}
      </code>
    </div>
  </div>
</section>
```

- [ ] **Step 2: Write `FeatureCard.astro`**

```astro
---
// site/src/components/FeatureCard.astro
interface Props {
  icon: string;
  title: string;
  description: string;
}

const { icon, title, description } = Astro.props;
---
<div class="bg-brand-bg-light border border-brand-border rounded-xl p-6 hover:border-brand-accent/50 transition group">
  <div class="text-3xl mb-3">{icon}</div>
  <h3 class="text-slate-100 font-semibold text-lg">{title}</h3>
  <p class="text-slate-400 text-sm mt-2">{description}</p>
</div>
```

- [ ] **Step 3: Write `FeatureGrid.astro`**

```astro
---
// site/src/components/FeatureGrid.astro
import FeatureCard from './FeatureCard.astro';
import { getLangFromUrl, t } from '@/i18n/ui';

const lang = getLangFromUrl(Astro.url);
const ui = t(lang);

const features = [
  { icon: '🤖', ...ui.features.ai },
  { icon: '🎧', ...ui.features.tts },
  { icon: '📚', ...ui.features.library },
  { icon: '📱', ...ui.features.reader },
  { icon: '🐳', ...ui.features.deploy },
];
---
<section class="py-20 px-6 bg-brand-bg border-t border-brand-border">
  <div class="max-w-6xl mx-auto">
    <p class="text-brand-accent text-xs uppercase tracking-widest text-center">{ui.features.sectionLabel}</p>
    <h2 class="text-3xl font-bold text-slate-100 text-center mt-2 mb-12">{ui.features.sectionTitle}</h2>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      {features.slice(0, 3).map(f => <FeatureCard icon={f.icon} title={f.title} description={f.desc} />)}
    </div>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
      {features.slice(3).map(f => <FeatureCard icon={f.icon} title={f.title} description={f.desc} />)}
    </div>
  </div>
</section>
```

- [ ] **Step 4: Write `index.astro` (EN landing page)**

```astro
---
// site/src/pages/index.astro
import BaseLayout from '@/layouts/BaseLayout.astro';
import Hero from '@/components/Hero.astro';
import FeatureGrid from '@/components/FeatureGrid.astro';
---
<BaseLayout title="Your Library, Alive">
  <Hero />
  <FeatureGrid />
</BaseLayout>
```

- [ ] **Step 5: Verify with dev server**

```bash
cd site && npx astro dev
# Open http://localhost:4321
```

Expected: Landing page shows Hero + Feature cards with dark theme.

- [ ] **Step 6: Commit**

```bash
git add site/src/components/Hero.astro site/src/components/FeatureCard.astro site/src/components/FeatureGrid.astro site/src/pages/index.astro
git commit -m "feat(site): add Hero and FeatureGrid to landing page"
```

---

### Task 6: Landing Page — Quadrant Chart + QuickStart + CTA

**Files:**
- Create: `site/src/components/QuadrantChart.astro`
- Create: `site/src/components/QuickStart.astro`
- Create: `site/src/components/CTA.astro`
- Modify: `site/src/pages/index.astro`

- [ ] **Step 1: Write `QuadrantChart.astro`**

SVG-based competitive positioning chart. Omnigram glows in top-right quadrant.

```astro
---
// site/src/components/QuadrantChart.astro
import { getLangFromUrl, t } from '@/i18n/ui';

const lang = getLangFromUrl(Astro.url);
const ui = t(lang);
---
<section class="py-20 px-6 bg-brand-bg border-t border-brand-border">
  <div class="max-w-4xl mx-auto">
    <p class="text-brand-accent text-xs uppercase tracking-widest text-center">{ui.quadrant.sectionLabel}</p>
    <h2 class="text-3xl font-bold text-slate-100 text-center mt-2 mb-12">{ui.quadrant.sectionTitle}</h2>
    <div class="bg-brand-bg-light border border-brand-border rounded-xl p-8 relative" style="aspect-ratio: 16/10;">
      <svg viewBox="0 0 800 500" class="w-full h-full" xmlns="http://www.w3.org/2000/svg">
        <!-- Axes -->
        <line x1="400" y1="30" x2="400" y2="470" stroke="#334155" stroke-width="1"/>
        <line x1="30" y1="250" x2="770" y2="250" stroke="#334155" stroke-width="1"/>
        <!-- Axis labels -->
        <text x="400" y="20" text-anchor="middle" fill="#64748b" font-size="12">Self-Hosted ↑</text>
        <text x="400" y="495" text-anchor="middle" fill="#64748b" font-size="12">↓ Client Only</text>
        <text x="780" y="254" text-anchor="start" fill="#64748b" font-size="12">AI →</text>
        <text x="20" y="254" text-anchor="end" fill="#64748b" font-size="12">← No AI</text>
        <!-- Competitors -->
        <text x="180" y="120" fill="#94a3b8" font-size="13">Calibre-Web</text>
        <text x="160" y="160" fill="#94a3b8" font-size="13">Kavita</text>
        <text x="200" y="190" fill="#94a3b8" font-size="13">Komga</text>
        <text x="150" y="350" fill="#94a3b8" font-size="13">KOReader</text>
        <text x="550" y="340" fill="#94a3b8" font-size="13">Anx Reader</text>
        <text x="530" y="270" fill="#94a3b8" font-size="12" font-style="italic">Readwise (SaaS)</text>
        <!-- Omnigram — glowing -->
        <rect x="540" y="70" width="160" height="40" rx="8" fill="#6366f1" opacity="0.15"/>
        <rect x="540" y="70" width="160" height="40" rx="8" fill="#6366f1" opacity="0.9"/>
        <text x="620" y="96" text-anchor="middle" fill="white" font-size="15" font-weight="bold">✦ Omnigram</text>
      </svg>
    </div>
  </div>
</section>
```

- [ ] **Step 2: Write `QuickStart.astro`**

```astro
---
// site/src/components/QuickStart.astro
import { getLangFromUrl, t } from '@/i18n/ui';

const lang = getLangFromUrl(Astro.url);
const ui = t(lang);
---
<section class="py-20 px-6 bg-brand-bg border-t border-brand-border">
  <div class="max-w-3xl mx-auto text-center">
    <h2 class="text-3xl font-bold text-slate-100 mb-8">{ui.quickstart.sectionTitle}</h2>
    <div class="bg-brand-bg-light border border-brand-border rounded-xl p-6 text-left font-mono text-sm relative">
      <button
        onclick="navigator.clipboard.writeText('docker compose up -d')"
        class="absolute top-4 right-4 text-slate-500 hover:text-slate-300 text-xs border border-brand-border px-2 py-1 rounded transition"
      >
        Copy
      </button>
      <div class="text-slate-500"># One command to start</div>
      <div class="text-indigo-400">docker compose up -d</div>
      <div class="text-slate-500 mt-3"># Open browser</div>
      <div class="text-indigo-400">open http://localhost:8080</div>
    </div>
  </div>
</section>
```

- [ ] **Step 3: Write `CTA.astro`**

```astro
---
// site/src/components/CTA.astro
import { getLangFromUrl, t, getLocalePath } from '@/i18n/ui';

const lang = getLangFromUrl(Astro.url);
const ui = t(lang);
---
<section class="py-20 px-6 bg-gradient-to-br from-indigo-950 to-brand-bg border-t border-brand-border text-center">
  <div class="max-w-3xl mx-auto">
    <h2 class="text-3xl font-bold text-slate-100">{ui.cta.title}</h2>
    <p class="text-slate-400 mt-3">{ui.cta.subtitle}</p>
    <div class="mt-8 flex gap-3 justify-center flex-wrap">
      <a href="/docs/getting-started/quick-start" class="bg-brand-accent hover:bg-indigo-600 text-white px-8 py-3 rounded-lg font-semibold transition">
        {ui.cta.primary}
      </a>
      <a href={getLocalePath(lang, '/docs')} class="border border-brand-border text-slate-300 hover:text-white px-8 py-3 rounded-lg transition">
        {ui.cta.secondary}
      </a>
    </div>
  </div>
</section>
```

- [ ] **Step 4: Update `index.astro` to include all sections**

```astro
---
// site/src/pages/index.astro
import BaseLayout from '@/layouts/BaseLayout.astro';
import Hero from '@/components/Hero.astro';
import FeatureGrid from '@/components/FeatureGrid.astro';
import QuadrantChart from '@/components/QuadrantChart.astro';
import QuickStart from '@/components/QuickStart.astro';
import CTA from '@/components/CTA.astro';
---
<BaseLayout title="Your Library, Alive">
  <Hero />
  <FeatureGrid />
  <QuadrantChart />
  <QuickStart />
  <CTA />
</BaseLayout>
```

- [ ] **Step 5: Verify with dev server**

```bash
cd site && npx astro dev
```

Expected: Full landing page with all 7 sections visible (Hero → Features → Quadrant → QuickStart → CTA → Footer).

- [ ] **Step 6: Commit**

```bash
git add site/src/components/QuadrantChart.astro site/src/components/QuickStart.astro site/src/components/CTA.astro site/src/pages/index.astro
git commit -m "feat(site): complete landing page (quadrant, quickstart, CTA)"
```

---

### Task 7: Chinese Landing Page

**Files:**
- Create: `site/src/pages/zh/index.astro`

- [ ] **Step 1: Write ZH landing page**

```astro
---
// site/src/pages/zh/index.astro
import BaseLayout from '@/layouts/BaseLayout.astro';
import Hero from '@/components/Hero.astro';
import FeatureGrid from '@/components/FeatureGrid.astro';
import QuadrantChart from '@/components/QuadrantChart.astro';
import QuickStart from '@/components/QuickStart.astro';
import CTA from '@/components/CTA.astro';
---
<BaseLayout title="让书架活过来" description="AI 原生、自托管书库服务。Docker 一键部署到你的 NAS。">
  <Hero />
  <FeatureGrid />
  <QuadrantChart />
  <QuickStart />
  <CTA />
</BaseLayout>
```

The components auto-detect language from URL (`/zh/` prefix) and render Chinese strings.

- [ ] **Step 2: Verify both languages**

```bash
cd site && npx astro dev
# Check http://localhost:4321/ (EN)
# Check http://localhost:4321/zh/ (ZH)
```

Expected: Both pages render correctly with respective language strings.

- [ ] **Step 3: Commit**

```bash
git add site/src/pages/zh/
git commit -m "feat(site): add Chinese landing page"
```

---

### Task 8: Features Detail Page (EN + ZH)

**Files:**
- Create: `site/src/pages/features.astro`
- Create: `site/src/pages/zh/features.astro`

- [ ] **Step 1: Write EN features page**

Five feature sections with alternating layout. Each section: title + description + placeholder for screenshot.

```astro
---
// site/src/pages/features.astro
import BaseLayout from '@/layouts/BaseLayout.astro';
import CTA from '@/components/CTA.astro';
import { t } from '@/i18n/ui';

const ui = t('en');

const sections = [
  { icon: '🤖', title: 'AI-Enhanced Reading', desc: 'Ask questions about any book. Get instant summaries. Search across your entire library by meaning, not just keywords. Auto-tag new imports with AI-generated categories.', details: 'Powered by OpenAI / Ollama — bring your own LLM or use the built-in integration.' },
  { icon: '🎧', title: 'TTS Audiobook Generation', desc: 'Turn any ebook into a high-quality audiobook. Multiple AI voices, chapter-by-chapter generation, server-side processing so your phone stays cool.', details: 'Backed by Fish Audio gRPC. Supports multi-voice, adjustable speed, and scheduled generation.' },
  { icon: '📚', title: 'Library Management', desc: 'Scan your book directory, extract metadata from EPUB/PDF/MOBI/FB2, edit metadata, organize with tags and shelves. OPDS and WebDAV protocols for universal client access.', details: 'Supports 6 formats. SQLite FTS5 full-text search. Calibre database import.' },
  { icon: '📱', title: 'Multi-Platform Reader', desc: 'Native apps for iOS, Android, macOS, and Windows. Read offline, sync progress, notes, and highlights across all devices.', details: 'Built with Flutter. Forked from Anx Reader (7,900+ ⭐, MIT license).' },
  { icon: '🐳', title: 'Self-Hosted & Open Source', desc: 'Deploy with a single Docker Compose command. Your data stays on your hardware. No cloud dependency, no subscription, no vendor lock-in.', details: 'MIT licensed. SQLite or PostgreSQL. Multi-arch Docker images (arm64/amd64).' },
];
---
<BaseLayout title="Features" description="Explore what makes Omnigram the AI-native book library">
  <div class="py-20 px-6">
    <div class="max-w-5xl mx-auto">
      <h1 class="text-4xl font-extrabold text-slate-100 text-center mb-16">Features</h1>
      {sections.map((s, i) => (
        <div class={`flex flex-col md:flex-row gap-8 mb-20 items-center ${i % 2 === 1 ? 'md:flex-row-reverse' : ''}`}>
          <div class="flex-1">
            <div class="text-4xl mb-4">{s.icon}</div>
            <h2 class="text-2xl font-bold text-slate-100">{s.title}</h2>
            <p class="text-slate-400 mt-3 leading-relaxed">{s.desc}</p>
            <p class="text-slate-500 text-sm mt-3 italic">{s.details}</p>
          </div>
          <div class="flex-1 bg-brand-bg-light border border-brand-border rounded-xl h-48 flex items-center justify-center text-slate-600 text-sm">
            [ Screenshot ]
          </div>
        </div>
      ))}
    </div>
  </div>
  <CTA />
</BaseLayout>
```

- [ ] **Step 2: Write ZH features page**

Same structure but with Chinese content. Create `site/src/pages/zh/features.astro` with translated `sections` array.

- [ ] **Step 3: Verify both pages**

```bash
cd site && npx astro dev
# Check /features and /zh/features
```

- [ ] **Step 4: Commit**

```bash
git add site/src/pages/features.astro site/src/pages/zh/features.astro
git commit -m "feat(site): add Features detail page (EN + ZH)"
```

---

### Task 9: Documentation (Starlight)

**Files:**
- Create: `site/src/content/config.ts`
- Create: `site/src/content/docs/en/index.mdx`
- Create: `site/src/content/docs/en/getting-started/quick-start.md`
- Create: `site/src/content/docs/en/getting-started/installation.md`
- Create: `site/src/content/docs/en/development/contributing.md`
- Create: ZH mirror docs

- [ ] **Step 1: Write `content/config.ts`**

```ts
// site/src/content/config.ts
import { defineCollection, z } from 'astro:content';
import { docsSchema } from '@astrojs/starlight/schema';

const blog = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    date: z.date(),
    description: z.string(),
    lang: z.enum(['en', 'zh']).default('en'),
  }),
});

export const collections = {
  docs: defineCollection({ schema: docsSchema() }),
  blog,
};
```

- [ ] **Step 2: Write docs landing page**

```mdx
---
# site/src/content/docs/en/index.mdx
title: Omnigram Documentation
description: Learn how to deploy and use Omnigram
---

Welcome to the Omnigram documentation. Omnigram is an AI-native, self-hosted book library management and reading service.

## Quick Links

- [Quick Start](/docs/getting-started/quick-start) — Deploy Omnigram in 30 seconds
- [Installation Guide](/docs/getting-started/installation) — Detailed setup instructions
- [Contributing](/docs/development/contributing) — Help improve Omnigram
```

- [ ] **Step 3: Write Quick Start doc**

```md
---
# site/src/content/docs/en/getting-started/quick-start.md
title: Quick Start
description: Deploy Omnigram with Docker in 30 seconds
---

## Prerequisites

- Docker and Docker Compose installed
- A directory with your ebook collection

## Deploy

```bash
docker compose up -d
```

Open `http://localhost:8080` in your browser.

## Default Credentials

Set your admin credentials via environment variables:

```yaml
environment:
  OMNI_USER: admin
  OMNI_PASSWORD: your-secure-password
```
```

- [ ] **Step 4: Write Installation doc and Contributing doc**

Create `installation.md` with Docker Compose details and `contributing.md` with build instructions referencing `CLAUDE.md`.

- [ ] **Step 5: Create ZH mirror docs**

Copy the EN docs to `site/src/content/docs/zh/` with translated content.

- [ ] **Step 6: Verify docs site**

```bash
cd site && npx astro dev
# Check /docs/ — Starlight docs should render with sidebar
```

- [ ] **Step 7: Commit**

```bash
git add site/src/content/
git commit -m "feat(site): add Starlight documentation (EN + ZH)"
```

---

### Task 10: Blog Infrastructure + First Post

**Files:**
- Create: `site/src/pages/blog/index.astro`
- Create: `site/src/pages/blog/[...slug].astro`
- Create: `site/src/pages/zh/blog/index.astro`
- Create: `site/src/pages/zh/blog/[...slug].astro`
- Create: `site/src/layouts/BlogPost.astro`
- Create: `site/src/content/blog/welcome.md`
- Create: `site/src/pages/rss.xml.ts`

- [ ] **Step 1: Write `BlogPost.astro` layout**

```astro
---
// site/src/layouts/BlogPost.astro
import BaseLayout from './BaseLayout.astro';

interface Props {
  title: string;
  date: Date;
  description: string;
}

const { title, date, description } = Astro.props;
---
<BaseLayout title={title} description={description}>
  <article class="py-20 px-6">
    <div class="max-w-3xl mx-auto">
      <p class="text-brand-accent text-sm">{date.toISOString().split('T')[0]}</p>
      <h1 class="text-4xl font-extrabold text-slate-100 mt-2 mb-8">{title}</h1>
      <div class="prose prose-invert prose-indigo max-w-none">
        <slot />
      </div>
    </div>
  </article>
</BaseLayout>
```

- [ ] **Step 2: Write blog list page**

```astro
---
// site/src/pages/blog/index.astro
import BaseLayout from '@/layouts/BaseLayout.astro';
import { getCollection } from 'astro:content';

const posts = (await getCollection('blog'))
  .filter(p => p.data.lang === 'en')
  .sort((a, b) => b.data.date.valueOf() - a.data.date.valueOf());
---
<BaseLayout title="Blog">
  <div class="py-20 px-6">
    <div class="max-w-3xl mx-auto">
      <h1 class="text-4xl font-extrabold text-slate-100 mb-12">Blog</h1>
      {posts.map(post => (
        <a href={`/blog/${post.slug}`} class="block mb-8 p-6 bg-brand-bg-light border border-brand-border rounded-xl hover:border-brand-accent/50 transition">
          <p class="text-brand-accent text-sm">{post.data.date.toISOString().split('T')[0]}</p>
          <h2 class="text-xl font-bold text-slate-100 mt-1">{post.data.title}</h2>
          <p class="text-slate-400 mt-2 text-sm">{post.data.description}</p>
        </a>
      ))}
    </div>
  </div>
</BaseLayout>
```

- [ ] **Step 3: Write blog post dynamic route**

```astro
---
// site/src/pages/blog/[...slug].astro
import BlogPost from '@/layouts/BlogPost.astro';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const posts = await getCollection('blog');
  return posts
    .filter(p => p.data.lang === 'en')
    .map(post => ({ params: { slug: post.slug }, props: { post } }));
}

const { post } = Astro.props;
const { Content } = await post.render();
---
<BlogPost title={post.data.title} date={post.data.date} description={post.data.description}>
  <Content />
</BlogPost>
```

- [ ] **Step 4: Write ZH blog pages** (mirror of EN with `lang === 'zh'` filter)

- [ ] **Step 5: Write first blog post**

```md
---
# site/src/content/blog/welcome.md
title: "Introducing Omnigram"
date: 2026-03-21
description: "Omnigram is an AI-native, self-hosted book library. Here's why we built it."
lang: en
---

**Jellyfin for videos. Immich for photos. Omnigram for books.**

We built Omnigram because the "self-hosted + AI + book management" space has zero competition. Calibre-Web is great but has no AI. Readwise is powerful but not self-hostable. Omnigram fills the gap.

## What's in v0.1

- Book library scanning and management
- Multi-format support (EPUB, PDF, MOBI, FB2, TXT)
- Docker one-click deployment
- Multi-platform reader (iOS, Android, macOS, Windows)

Stay tuned for AI features in upcoming releases.
```

- [ ] **Step 6: Write RSS feed**

```ts
// site/src/pages/rss.xml.ts
import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context: any) {
  const posts = await getCollection('blog');
  return rss({
    title: 'Omnigram Blog',
    description: 'AI-native, self-hosted book library',
    site: context.site,
    items: posts
      .filter(p => p.data.lang === 'en')
      .map(post => ({
        title: post.data.title,
        pubDate: post.data.date,
        description: post.data.description,
        link: `/blog/${post.slug}/`,
      })),
  });
}
```

- [ ] **Step 7: Verify blog**

```bash
cd site && npx astro dev
# Check /blog/, /blog/welcome, /rss.xml
```

- [ ] **Step 8: Commit**

```bash
git add site/src/pages/blog/ site/src/pages/zh/blog/ site/src/layouts/BlogPost.astro site/src/content/blog/ site/src/pages/rss.xml.ts
git commit -m "feat(site): add blog infrastructure, first post, RSS feed"
```

---

### Task 11: 404 Page

**Files:**
- Create: `site/src/pages/404.astro`

- [ ] **Step 1: Write 404 page**

```astro
---
// site/src/pages/404.astro
import BaseLayout from '@/layouts/BaseLayout.astro';
---
<BaseLayout title="Page Not Found">
  <div class="flex flex-col items-center justify-center min-h-[60vh] px-6 text-center">
    <h1 class="text-6xl font-extrabold text-slate-100">404</h1>
    <p class="text-slate-400 mt-4 text-lg">This page doesn't exist.</p>
    <a href="/" class="mt-8 bg-brand-accent hover:bg-indigo-600 text-white px-6 py-3 rounded-lg font-semibold transition">
      Back to Home →
    </a>
  </div>
</BaseLayout>
```

- [ ] **Step 2: Commit**

```bash
git add site/src/pages/404.astro
git commit -m "feat(site): add custom 404 page"
```

---

### Task 12: GitHub Actions Deployment

**Files:**
- Create: `.github/workflows/site.yaml`

- [ ] **Step 1: Write deployment workflow**

```yaml
# .github/workflows/site.yaml
name: Deploy Website

on:
  push:
    branches: [main]
    paths: ['site/**']
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
          cache-dependency-path: site/package-lock.json
      - run: npm ci
        working-directory: site
      - run: npx astro build
        working-directory: site
      - uses: actions/upload-pages-artifact@v3
        with:
          path: site/dist

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```

- [ ] **Step 2: Verify workflow syntax**

```bash
cd /Users/liuyou/Workspace/omnigram
cat .github/workflows/site.yaml | head -5
```

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/site.yaml
git commit -m "ci: add GitHub Pages deployment for website"
```

---

### Task 13: Final Verification + Build Check

- [ ] **Step 1: Full build test**

```bash
cd /Users/liuyou/Workspace/omnigram/site
npm ci
npx astro build
```

Expected: Build succeeds, output in `site/dist/`.

- [ ] **Step 2: Check output structure**

```bash
ls site/dist/
# Should contain: index.html, zh/, features/, blog/, docs/, 404.html, rss.xml
```

- [ ] **Step 3: Check page sizes**

```bash
wc -c site/dist/index.html
# Should be under 200KB
```

- [ ] **Step 4: Preview locally**

```bash
cd site && npx astro preview
# Open http://localhost:4321 and verify all pages
```

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "feat(site): Omnigram website v1 — landing, features, docs, blog"
```
