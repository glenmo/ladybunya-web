#!/usr/bin/env bash
#
# ladybunya-restructure.sh
# ------------------------------------------------------------------
# Updates the site structure to the agreed three-offering model:
#   - Trashes (recoverably) the old service pages
#   - Creates/updates the three offering pages, with content
#   - Rewrites the Home page as a 3-tile "choose your path" skeleton
#   - Leaves About, Blog, Contact untouched
#
# RUN FROM LOCAL'S SITE SHELL, from the repo root:
#     bash scripts/ladybunya-restructure.sh
#
# Page content comes from scripts/page-content/*.html (block markup).
# Safe to re-run. Trashes (not permanently deletes) old pages.
# ------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTENT_DIR="$SCRIPT_DIR/page-content"

# ----- SAFETY GUARD: local only -----
SITE_URL="$(wp option get siteurl 2>/dev/null || echo '')"
echo "Detected site URL: ${SITE_URL:-<none>}"
case "$SITE_URL" in
  *.local|*localhost*|*127.0.0.1*) echo "✓ Local environment confirmed." ;;
  *) echo "✗ Not a local site. Refusing to run. Aborting."; exit 1 ;;
esac

[ -d "$CONTENT_DIR" ] || { echo "✗ Can't find $CONTENT_DIR — run from the repo root."; exit 1; }

echo
echo "=== 1. Trash old service pages (recoverable — NOT permanent) ==="
# These came from the morning build, before the real offering was known.
# Wayapa Wuurrk in particular must come off (entertainer insurance, not wellness).
for slug in offerings dancercise vocal-coaching sanskrit-prayer-singing \
            eco-therapy wayapa-wuurrk gardening public-speaking \
            workshop-series-facilitation; do
  id="$(wp post list --post_type=page --name="$slug" --field=ID --format=ids 2>/dev/null || echo '')"
  if [ -n "$id" ]; then
    wp post delete "$id"   # no --force => goes to Trash, recoverable
    echo "  trashed: $slug (ID $id)"
  else
    echo "  (no '$slug' page — skipping)"
  fi
done

echo
echo "=== 2. Helper: create-or-update a page from an HTML file ==="
upsert_page () {
  local slug="$1" title="$2" file="$3"
  [ -f "$file" ] || { echo "  ✗ missing content file: $file"; return 1; }
  local id
  id="$(wp post list --post_type=page --name="$slug" --field=ID --format=ids 2>/dev/null || echo '')"
  if [ -n "$id" ]; then
    wp post update "$id" --post_title="$title" --post_content="$(cat "$file")" >/dev/null
    echo "  updated: $title (ID $id)"
  else
    wp post create --post_type=page --post_status=publish \
      --post_title="$title" --post_name="$slug" \
      --post_content="$(cat "$file")" >/dev/null
    echo "  created: $title"
  fi
}

echo
echo "=== 3. Create / update the three offering pages ==="
upsert_page "cultural-experience-host" "Cultural Experience Host" "$CONTENT_DIR/cultural-experience.html"
upsert_page "freedom-moves"            "Freedom Moves Dance Classes" "$CONTENT_DIR/freedom-moves.html"
upsert_page "dance-parlour"            "Lady Bunya's Dance Parlour" "$CONTENT_DIR/dance-parlour.html"

echo
echo "=== 4. Rewrite Home as a 3-tile chooser ==="
HOME_ID="$(wp post list --post_type=page --name=home --field=ID --format=ids)"
wp post update "$HOME_ID" --post_content="$(cat "$CONTENT_DIR/home-tiles.html")" >/dev/null
echo "  Home updated (ID $HOME_ID) — style the tiles visually in the editor."

echo
echo "=================================================================="
echo "DONE. Open the site to review."
echo
echo "NEXT (manual, in the block editor):"
echo "  • Style the 3 homepage tiles (images, spacing, buttons)."
echo "  • Lay out the Cultural Experience page (hero, button styling, FAQ)."
echo "  • Hook up the enquiry form (placeholder is marked in the page)."
echo "  • Add Glen's directions where [ASK GLEN] is marked."
echo "  • Curate header nav (Appearance > Editor) to the new pages."
echo "  • Trashed pages can be restored from Pages > Trash if needed."
echo "=================================================================="
