import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import tailwind from '@astrojs/tailwind';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://omnigram.lxpio.com',
  integrations: [
    starlight({
      title: 'Omnigram',
      // Pin to dark; the marketing pages have no light variant. Without
      // this, OS-light-mode visitors see a half-light Starlight sidebar
      // bleeding into the brand-dark surrounding nav.
      head: [
        {
          tag: 'script',
          content:
            "document.documentElement.setAttribute('data-theme','dark');",
        },
      ],
      locales: {
        root: { label: 'English', lang: 'en' },
        zh: { label: '中文', lang: 'zh' },
      },
      sidebar: [
        {
          label: 'Getting Started',
          items: [
            { label: 'Quick Start', slug: 'getting-started/quick-start' },
            { label: 'Installation', slug: 'getting-started/installation' },
            { label: 'TTS Setup', slug: 'getting-started/tts-setup' },
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
        Header: './src/components/StarlightHeader.astro',
      },
    }),
    tailwind(),
    sitemap(),
  ],
});
