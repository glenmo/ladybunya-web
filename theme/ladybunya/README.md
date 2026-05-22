# Lady Bunya child theme

A child theme of **Twenty Twenty-Five** that applies the Lady Bunya brand:
the real brand palette (ocean green, bone, gold, soft rose, warm grey) plus
Fraunces (headings) / Mulish (body), with fonts bundled locally so the site has
no dependency on Google's font CDN.

## What's in here

```
ladybunya/
├── style.css              # child-theme header (links to twentytwentyfive parent)
├── theme.json             # the brand: colour palette + font families + element styles
└── assets/fonts/          # bundled woff2 files (Fraunces 400/500/600, Mulish 400/500/700)
```

All design tokens live in `theme.json` — that's the single source of truth. Edit
colours or font sizes there and they flow through the whole site.

## The palette

| Token | Hex | Used for |
|-------|-----|----------|
| Bone Light | `#FAF7F2` | page background |
| Warm Grey | `#6F7774` | body text |
| Ocean Green | `#1F4E4A` | headings, links, primary buttons |
| Gold | `#C9A45C` | accents, button hover (never overpowering) |
| Soft Rose | `#E4A6B0` | supporting graphics only — "lipstick, not skeleton" |

Brand rules honoured: gold is an accent only; soft rose never appears in the
logo mark itself, only in supporting graphics; headings are serif, body is sans.

## Installing it on the dev site

The child theme has to live inside WordPress's themes folder. With Local, the
site's files are under the path shown in Local as "Site folder", then
`app/public/wp-content/themes/`.

### Option A — copy + activate via WP-CLI (Site shell)

From **Local's Site shell**, with this repo at a known path:

```bash
# 1. Copy the child theme into the WordPress themes directory
THEMES="$(wp theme path)/.."         # resolves to wp-content/themes
cp -R /path/to/ladybunya-web/theme/ladybunya "$THEMES/ladybunya"

# 2. Activate it
wp theme activate ladybunya
```

(Replace `/path/to/ladybunya-web` with your actual repo path, e.g.
`/Users/glen/Code/ladybunya-web`.)

### Option B — Appearance > Themes (dashboard)

Zip the `ladybunya` folder, then in WP Admin: Appearance > Themes > Add New >
Upload Theme > choose the zip > Install > Activate.

## After activating

- The cream background, plum headings, terracotta links and the new fonts apply
  automatically — no clicking needed.
- Fine-tune anything visually in Appearance > Editor > Styles; those edits layer
  on top of theme.json. (If you want edits to be reproducible, prefer changing
  theme.json here and re-copying.)
- If fonts don't appear: confirm the `assets/fonts/` files copied across, and
  that the child theme is the active theme (not the parent).

## Keeping it reproducible

This folder is the source of truth. The WordPress copy under wp-content is just
a deployment of it. Change things here, commit, and re-copy to the site — the
same recipe-not-runtime model the whole repo uses.
