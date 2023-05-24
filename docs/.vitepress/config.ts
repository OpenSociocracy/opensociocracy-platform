import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "OpenSociocracy",
  description: "Open Source Sociocracy Tools",
  head: [
    [
      'script',
      { async: '', src: 'https://www.googletagmanager.com/gtag/js?id=G-G19NFP630F' }
    ],
    [
      'script',
      {},
      "window.dataLayer = window.dataLayer || [];\nfunction gtag(){dataLayer.push(arguments);}\ngtag('js', new Date());\ngtag('config', 'G-XXXXXXXXXX');"
    ]
  ],
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Join in', link: 'https://handbook.opensociocracy.org/contributing/' },
      { text: 'Tech Docs', link: '/technical-docs/' },
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/orgs/OpenSociocracy' },
      { icon: 'twitter', link: 'https://twitter.com/OpenSociocracy'},
      { icon: 'facebook', link: 'https://www.facebook.com/OpenSociocracy/'},
      { icon: 'mastodon', link: 'https://fosstodon.org/@opensociocracy'},
      { icon: "linkedin", link: "https://www.linkedin.com/company/opensociocracy/" },
    ],

    footer: {
      message: 'Sponsored by "Sociocracy org name" and "funding org name"',
      copyright: 'Released under the <a href="https://github.com/OpenSociocracy/documentation-website/blob/main/LICENSE">MIT</a> and <a href="https://github.com/OpenSociocracy/open-sociocracy-saas/blob/main/LICENSE">AGPL</a> License</a>.<br />Copyright <a href="https://creativecommons.org/licenses/by-sa/4.0/">CC BY-SA</a>'
    }
  }
})
