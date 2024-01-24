/** @type {import('@docusaurus/types').DocusaurusConfig} */

import ConfigLocalized from './docusaurus.config.localized.json';

const defaultLocale = 'en';

function getLocalizedConfigValue(key) {
  const currentLocale = process.env.DOCUSAURUS_CURRENT_LOCALE ?? defaultLocale;
  const values = ConfigLocalized[key];
  if (!values) {
    throw new Error(`Localized config key=${key} not found`);
  }
  const value = values[currentLocale] ?? values[defaultLocale];
  if (!value) {
    throw new Error(
      `Localized value for config key=${key} not found for both currentLocale=${currentLocale} or defaultLocale=${defaultLocale}`,
    );
  }
  return value;
}


module.exports = {
  title: "Omnigram",
  tagline:
    "Powerful, minimalistic, cross-platform, opensource doc-reading app",
  url: "https://omnigram.lxpio.com",
  baseUrl: "/",
  onBrokenLinks: "throw",
  onBrokenMarkdownLinks: "warn",
  favicon: "img/favicon.ico",
  organizationName: "Lxpio Tream", // Usually your GitHub org/user name.
  projectName: "omnigram-doc", // Usually your repo name.
  i18n: {
    defaultLocale: defaultLocale,
    locales: [defaultLocale, "zh"],
  },
  themeConfig: {
    colorMode: {
      defaultMode: "dark",
      disableSwitch: false,
      respectPrefersColorScheme: true,
    },
    // announcementBar: {
    //   id: 'announcementBar-3', // Increment on change
    //   // content: `⭐️ If you like Docusaurus, give it a star on <a target="_blank" rel="noopener noreferrer" href="https://github.com/facebook/docusaurus">GitHub</a> and follow us on <a target="_blank" rel="noopener noreferrer" href="https://twitter.com/docusaurus">Twitter ${TwitterSvg}</a>`,
    //   content: `🎉️ <b><a target="_blank" href="https://docusaurus.io/blog/releases/3.0">Docusaurus v3.0</a> is now out!</b> 🥳️`,
    // },
    announcementBar: {
      id: 'support_us',
      content: getLocalizedConfigValue('DevAnnouncement'),
      backgroundColor: '#fafbfc',
      textColor: '#091E42',
      isCloseable: false,
    },
    algolia: {
      // The application ID provided by Algolia
      appId: "xxx",

      // Public API key: it is safe to commit it
      apiKey: "xxx",

      indexName: "docs-omnigram-lxpio",

      //... other Algolia params
    },
    navbar: {
      title: "Omnigram",
      logo: {
        alt: "Omnigram Logo",
        src: "img/logo_white.svg",
      },
      items: [
        {
          type: "doc",
          docId: "intro",
          // docsPluginId: "docs",
          position: "right",
          label: "Docs",
        },
        // {
        //   to: "downloads",
        //   label: "Downloads",
        //   position: "right",
        // },
        // {
        //   // type: "doc",
        //   // docId: "blog",
        //   // docsPluginId: "community",
        //   position: "right",
        //   label: "Blog",
        //   to: "/blog"
        // },
        {
          // label: "GitHub", header-icon-link 
          href: "https://github.com/lxpio/omnigram",
          className: "header-github-link",
          position: "right",
        },
        // {
        //   type: "docsVersionDropdown",
        //   position: "right",
        //   dropdownItemsBefore: [],
        //   dropdownItemsAfter: [{ to: "/versions", label: "All versions" }],
        //   dropdownActiveClassDisabled: true,
        // },
        {
          type: "localeDropdown",
          position: "right",
          // dropdownItemsAfter: [
          //   {
          //     to: "https://translate.lxpio.com/omnigram",
          //     label: "Help translate",
          //   },
          // ],
        },
      ],
    },
    footer: {
      style: "dark",
      links: [
        {
          title: "Community",
          items: [
            {
              label: "Github Discussions",
              href: "https://github.com/lxpio/omnigram/discussions",
            },
            {
              label: "Lxpio Team",
              href: "https://blog.lxipio.com",
            },
          ],
        },
        {
          title: "Source code",
          items: [
            {
              label: "Omnigram App",
              href: "https://github.com/lxpio/omnigram",
            },
            {
              label: "Omnigram Server",
              href: "https://github.com/lxpio/omnigram-server",
            },
            {
              label: "Contribution guide",
              href: "https://github.com/lxpio/omnigram/blob/main/CONTRIBUTING.md",
            },
          ],
        },
        {
          title: "Legal",
          items: [
            // {
            //   label: "Imprint",
            //   href: "https://omnigram.lxpio.com/imprint",
            // },
            {
              label: "Privacy Policy",
              href: "/privacypolicy",
            },
            {
              label: "Terms",
              href: "/terms-conditions",
            },
          ],
        },
      ],
      logo: {
        alt: "Lxpio Logo",
        src: "https://blog.lxpio.com/logos/logo.png",
        width: 100,
        href: "https://blog.lxpio.com/dev",
      },
      copyright: `Copyright © ${new Date().getFullYear()} Lxpio Team.`,
    },
  },
  presets: [
    [
      "@docusaurus/preset-classic",
      /** @type {import('@docusaurus/preset-classic').Options} */
      {
        docs: {
          sidebarPath: require.resolve("./sidebars.js"),
          editUrl: ({ locale, docPath }) => {
            if (locale !== 'en') {
              return `https://translate.lxpio.com/omnigram/${locale}`;
            }
            return `https://github.com/lxpio/omnigram/edit/main/docs/docs/${docPath}`;
          },
          // versions: {
          //   current: {
          //     label: "Main",
          //     path: "2.1",
          //   }
          // },
        },
        blog: false,
        theme: {
          customCss: require.resolve("./src/css/custom.css"),
        },
      },
    ],
  ],
  plugins: [
    [
      "@docusaurus/plugin-content-docs",
      {
        id: "community",
        path: "community",
        routeBasePath: "/",
        sidebarPath: require.resolve("./sidebarsCommunity.js"),
      },
    ],
    [
      "@docusaurus/plugin-pwa",
      {
        offlineModeActivationStrategies: [
          "appInstalled",
          "standalone",
          "queryString",
        ],
        pwaHead: [
          {
            tagName: "link",
            rel: "icon",
            href: "/img/logo.png",
          },
          {
            tagName: "link",
            rel: "manifest",
            href: "/manifest.json", // your PWA manifest
          },
          {
            tagName: "meta",
            name: "theme-color",
            content: "#f2b138",
          },
        ],
      },
    ],
    // Other tweaks
  ],

  webpack: {
    jsLoader: (isServer) => ({
      loader: require.resolve("swc-loader"),
      options: {
        jsc: {
          parser: {
            syntax: "typescript",
            tsx: true,
          },
          target: "es2017",
        },
        module: {
          type: isServer ? "commonjs" : "es6",
        },
      },
    }),
  },
};
