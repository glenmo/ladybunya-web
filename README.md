# ladybunya-web

Website project for **Lady Bunya Enterprises** — dance lessons, fun events and
cultural experiences, based at the Moora Moora Co-operative, Mount Toolebewong,
Wurundjeri Country, VIC.

Live site: <https://www.ladybunya.com/> (WordPress)

## What this repo is (and isn't)

This repo is the **source of truth for the things we author** — the build
recipe, the page content, and any custom theme tweaks. It is **not** a copy of
the WordPress install.

WordPress keeps its real state in a database (pages, settings) plus an uploads
folder (images). Those aren't files git can usefully version, so they're
deliberately *not* tracked (see `.gitignore`). Instead, the build script can
**regenerate the whole site skeleton** from scratch — the repo holds the recipe,
WordPress holds the running state.

## Structure

```
.
├── README.md              # this file
├── .gitignore             # keeps the WP install / secrets / cruft out
├── scripts/
│   └── ladybunya-build.sh # WP-CLI script: builds pages, menu, theme, plugin
├── content/
│   └── ladybunya-content-kit.md  # page-by-page copy + prompts for Sharni
└── theme/                 # (future) custom style tweaks / child theme bits
```

## Local development

The dev site runs locally via **Local by Flywheel** (`ladybunya-dev.local`).
It is never built against the live site directly.

### Rebuilding the site skeleton

1. In Local, open the site → **Site shell**.
2. Run the build script:
   ```bash
   bash scripts/ladybunya-build.sh
   ```
   It installs the Twenty Twenty-Five theme, creates all pages, sets the front
   page and menu, removes default WordPress junk, and installs the Amelia
   booking plugin. It is idempotent (safe to re-run) and refuses to run on any
   site whose URL isn't `*.local` (a guard against touching production).

### Done manually (by design, not scripted)

- Visual theme styling (Appearance → Editor → Styles).
- Replacing every `[SHARNI — ...]` content prompt with her real words.
- Amelia configuration: services, pricing, and **Stripe** (Sharni's own
  account; test mode first), then placing the booking block on Events & Bookings.
- Replacing placeholder social links with the real Lady Bunya accounts.

## Going live

Build and test everything locally first (including a full booking test in Stripe
**test mode**). Migrate to live via Local's **Push**, or by re-applying the
config on the live site once it's known-good. Decide the migration approach
once we know the live host.

## Status

- [x] Local dev site created
- [x] Build script + content kit drafted
- [ ] Skeleton built in Local
- [ ] Theme styled for brand
- [ ] Service copy written (awaiting Sharni's input)
- [ ] Amelia + Stripe configured (test mode)
- [ ] Reviewed and pushed to live
