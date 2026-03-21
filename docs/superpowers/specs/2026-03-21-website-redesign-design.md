# Omnigram Website Redesign — Design Spec

> Date: 2026-03-21
> Status: Approved
> Scope: Landing Page + Features page + Documentation site + Blog

---

## 1. Goals

Redesign the Omnigram promotional website to:

1. **Attract open-source / self-hosted community** (r/selfhosted, GitHub, Hacker News) with technical credibility
2. **Attract general users** (knowledge workers, audiobook listeners) with product experience and visual appeal
3. **Provide comprehensive documentation** for installation, configuration, and API reference
4. Establish Omnigram's brand identity as the "AI-native self-hosted book library"

---

## 2. Tech Stack

| Component | Choice | Rationale |
|-----------|--------|-----------|
| Framework | **Astro** | Zero-JS output, component-based, supports landing page + docs + blog in one project |
| Docs | **Starlight** (Astro plugin) | Purpose-built for documentation, Markdown/MDX, sidebar navigation, search |
| Styling | **Tailwind CSS** | Utility-first, dark theme support, consistent with server Web UI tech choice |
| i18n | **Astro native i18n** | Full bilingual (EN/ZH), browser language detection + manual toggle |
| Deployment | **GitHub Pages** | Free, automatic via GitHub Actions on push to main |
| Content | **Astro Content Collections** | Type-safe Markdown for blog and docs |

### Starlight Integration Strategy

Starlight handles `/docs/**` routes only via its own layout and navigation. Landing page (`/`), Features (`/features`), and Blog (`/blog`) use `BaseLayout.astro` independently — they are plain Astro pages, not Starlight pages. The navigation bar component (`Nav.astro`) is shared across both: custom pages include it directly, while Starlight pages use its `components` override config to inject the same nav. This gives a unified navigation experience across the entire site.

---

## 3. Site Structure

```
site/
├── src/
│   ├── pages/
│   │   ├── index.astro              # Landing Page (EN, default)
│   │   ├── zh/index.astro           # Landing Page (ZH)
│   │   ├── features.astro           # Features detail page (EN)
│   │   └── zh/features.astro        # Features detail page (ZH)
│   ├── content/
│   │   ├── docs/en/                 # Documentation (EN)
│   │   │   ├── getting-started.md
│   │   │   ├── installation.md
│   │   │   ├── configuration.md
│   │   │   ├── api-reference.md
│   │   │   ├── app-guide.md
│   │   │   └── contributing.md
│   │   ├── docs/zh/                 # Documentation (ZH)
│   │   └── blog/                    # Blog posts (Markdown)
│   ├── components/
│   │   ├── Nav.astro                # Navigation bar
│   │   ├── Hero.astro               # Hero section
│   │   ├── FeatureCard.astro        # Feature highlight card
│   │   ├── QuadrantChart.astro      # Competitive positioning chart
│   │   ├── QuickStart.astro         # Docker quick start
│   │   ├── CTA.astro               # Call-to-action section
│   │   ├── Footer.astro            # Footer
│   │   └── LanguageSwitch.astro    # EN/ZH toggle
│   ├── layouts/
│   │   ├── BaseLayout.astro        # Shared layout (nav + footer)
│   │   └── BlogPost.astro          # Blog post layout
│   ├── i18n/
│   │   ├── en.json                 # English strings
│   │   └── zh.json                 # Chinese strings
│   └── styles/
│       └── global.css              # Tailwind global styles
├── public/
│   ├── favicon.svg                 # Copy from assets/img/favicon-32x32.png or convert logo_white.svg
│   ├── favicon.ico                 # Copy from assets/img/favicon.ico
│   ├── og-image.png                # Open Graph social preview (1200x630, generate from logo)
│   ├── logo/                       # Copied from project assets/img/
│   │   ├── logo_white.svg          # Logo icon only (for nav, favicon)
│   │   ├── logo_with_letter_dark.svg   # Logo + wordmark (dark background)
│   │   └── logo_with_letter_white.svg  # Logo + wordmark (light background)
│   ├── icons/                      # PWA / touch icons from assets/img/
│   │   ├── icon-192x192.png
│   │   ├── icon-512x512.png
│   │   └── apple-touch-icon.png
│   └── screenshots/               # Product screenshots
├── astro.config.mjs
├── tailwind.config.js
└── package.json
```

---

## 4. Visual Design

### Style Direction

**Dark tech aesthetic** — deep background, indigo/purple gradient accents.

| Element | Value |
|---------|-------|
| Background | `#0f172a` (slate-900) to `#1e293b` (slate-800) |
| Primary accent | `#6366f1` (indigo-500) to `#8b5cf6` (violet-500) gradient |
| Text primary | `#f1f5f9` (slate-100) |
| Text secondary | `#94a3b8` (slate-400) |
| Card background | `#1e293b` with `#334155` border |
| Code blocks | `#1e293b` with indigo syntax highlighting |
| CTA buttons | Solid indigo background, ghost border variant |

Reference sites: Vercel, Linear, Immich

### Typography

- Headings: Inter or system sans-serif, bold (700-800)
- Body: Inter, regular (400)
- Code: JetBrains Mono or system monospace

---

## 5. Landing Page Structure

Seven sections, top to bottom:

### 5.1 Navigation Bar

- Left: Logo + "Omnigram" wordmark
- Center/Right: Features / Docs / Blog / GitHub links
- Far right: Language switch (EN / 中文)
- Sticky on scroll, semi-transparent backdrop blur

### 5.2 Hero Section

- **Main tagline (EN):** "Your Library, Alive."
- **Main tagline (ZH):** "让书架活过来"
- **Subtitle:** "Jellyfin for videos. Immich for photos. **Omnigram for books.**"
- **Description:** "AI-native, self-hosted book library. Deploy on your NAS in seconds."
- **CTA buttons:** "Deploy Now →" (primary) + "⭐ Star on GitHub" (ghost)
- **Docker command:** `docker compose up -d` in a code badge below CTAs

### 5.3 Product Screenshot

- Hero image showing App + Web UI side by side
- Dark mockup frame (browser chrome / phone frame)
- Showcases: book grid view, AI conversation panel, TTS player
- Subtle glow/shadow effect
- **Asset note:** Server Web UI is still in development. Initial launch uses Flutter app screenshots only. Web UI screenshots added when available. Use mockup device frames (e.g., shots.so or browser-frame CSS) for presentation.

### 5.4 Feature Highlights (5 cards)

Layout: 3-column top row + 2-column bottom row

| # | Icon | Title | Description |
|---|------|-------|-------------|
| 1 | 🤖 | AI-Enhanced Reading | Summarize, Q&A, semantic search across your entire library |
| 2 | 🎧 | TTS Audiobooks | Turn any ebook into high-quality audiobook with AI voices |
| 3 | 📚 | Library Management | Scan, organize, tag, search — better than Calibre-Web |
| 4 | 📱 | Multi-Platform Reader | iOS, Android, macOS, Windows — read anywhere, sync everywhere |
| 5 | 🐳 | One-Click Deploy | Docker Compose on any NAS. Open source, self-hosted, yours forever |

Each card: dark background, border, icon + title + 1-line description. Hover effect with subtle glow.

### 5.5 Competitive Positioning (Quadrant Chart)

Interactive/static quadrant diagram:
- X-axis: No AI ← → AI-Native
- Y-axis: Client Only ↓ → Self-Hosted Server ↑
- Axis labels: Y = "Self-Hosted / Cloud/Client", X = "No AI / AI-Native"
- Competitors plotted: Calibre-Web, Kavita (top-left, self-hosted, no AI), Anx Reader (bottom-right, client-only, AI), Readwise (middle-right, cloud SaaS, AI), KOReader (bottom-left, client-only, no AI)
- **Omnigram** in top-right quadrant with indigo glow highlight — the empty space
- Section title: "The only AI-native self-hosted book library"

### 5.6 Quick Start

- Section title: "Deploy in 30 seconds"
- Styled code block with copy button:
  ```
  docker compose up -d
  open http://localhost:8080
  ```
- Optional: tabbed view for Docker / NAS platforms (Synology, Unraid, CasaOS)

### 5.7 CTA + Footer

- CTA: "Ready to bring your library alive?" + "Get Started →" + "Documentation"
- Footer links: GitHub, Discord, Twitter/X, License
- Copyright line

---

## 6. Features Detail Page

Route: `/features` (EN), `/zh/features` (ZH)

Expanded version of the 5 feature cards. Each feature gets a full section:

- Alternating layout: image-left/text-right → image-right/text-left
- Each section: title + 2-3 paragraph description + screenshot/animation + technical details
- Dark theme consistent with landing page

Sections:
1. **AI-Enhanced Reading** — AI summary, Q&A with RAG, semantic search, auto-tagging
2. **TTS Audiobook Generation** — Multi-voice, chapter-by-chapter, server-side generation
3. **Library Management** — Scan, metadata editing, tags, shelves, OPDS, WebDAV
4. **Multi-Platform Reader** — Flutter app (iOS/Android/macOS/Windows), offline reading, sync
5. **Self-Hosted & Open Source** — Docker deploy, data ownership, privacy, open core model

---

## 7. Documentation Site (Starlight)

Route: `/docs/` (EN), `/docs/zh/` (ZH)

Powered by Astro Starlight plugin. Sidebar navigation:

```
Getting Started
├── Quick Start
├── Installation
│   ├── Docker Compose
│   ├── Synology NAS
│   ├── Unraid
│   └── CasaOS
└── Configuration

Using Omnigram
├── App Setup
│   ├── Connect to Server
│   ├── WebDAV Sync
│   └── OPDS Clients
├── Library Management
├── AI Features
└── TTS Audiobooks

API Reference
├── Authentication
├── Books API
├── Tags & Shelves
├── Sync API
└── OPDS Protocol

Development
├── Building from Source
├── Contributing Guide
└── Architecture Overview
```

---

## 8. Blog

Route: `/blog/`

- Astro Content Collections (Markdown)
- Bilingual routing: `/blog/` shows EN posts, `/zh/blog/` shows ZH posts
- Blog post frontmatter includes `lang: "en" | "zh"` field for filtering
- List page: title + date + excerpt, filtered by language, chronological order
- Detail page: full post with BaseLayout
- Use cases: release announcements, technical articles, roadmap updates
- RSS feed via `@astrojs/rss` (self-hosted community expects RSS)
- Dark theme consistent with rest of site

---

## 9. Multilingual Strategy

- **Default:** English (path: `/`)
- **Chinese:** path prefix `/zh/`
- **Detection:** Browser `Accept-Language` header → auto-redirect on first visit
- **Manual switch:** Toggle in navigation bar, persisted in localStorage
- **Shared components:** All UI components use i18n string keys from `en.json` / `zh.json`
- **Docs:** Separate content directories (`docs/en/`, `docs/zh/`)
- **Blog:** Posts can be single-language or bilingual (per-post decision)

---

## 10. Deployment

- **Hosting:** GitHub Pages (free, sufficient for static site)
- **CI/CD:** New GitHub Actions workflow `site.yaml`:
  - Trigger: push to `main` with changes in `site/` directory
  - Steps: install Node.js → `npm ci` → `astro build` → deploy to GitHub Pages
- **Domain:** `omnigram.lxpio.com` (existing, point to GitHub Pages)
- **CDN:** GitHub Pages includes global CDN

---

## 11. SEO & Social

- Open Graph meta tags on all pages (title, description, og:image)
- `og-image.png`: branded social preview card
- Canonical URLs for EN/ZH variants
- `sitemap.xml` auto-generated by Astro
- `robots.txt` allowing all crawlers

---

## 12. Out of Scope (YAGNI)

- Pricing page (no paid product yet)
- Changelog page (use blog for release notes)
- Community forum (use GitHub Discussions)
- Analytics dashboard (add later if needed, Plausible/Umami)
- Dark/light theme toggle (dark only, consistent with brand)

---

## 13. Additional Details

- **404 page:** Custom `src/pages/404.astro` with branded design + link back to home
- **OG image:** 1200x630px, PNG format, branded social preview card
- **Font strategy:** System font stack as primary, Inter self-hosted as progressive enhancement (privacy-conscious for self-hosted audience)
- **Performance target:** Landing page < 200KB total, Lighthouse score 95+
- **Social links:** Only include links to channels that exist at launch time. Create GitHub Discussions first; Discord and Twitter/X added when ready
