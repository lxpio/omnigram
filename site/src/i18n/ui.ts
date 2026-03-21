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
