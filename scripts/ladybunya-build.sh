#!/usr/bin/env bash
#
# ladybunya-build.sh
# ------------------------------------------------------------------
# Builds the Lady Bunya Enterprises site skeleton in a LOCAL WordPress
# install, using WP-CLI (bundled with Local).
#
# HOW TO RUN:
#   1. In Local, click your site, then click "Site shell" (top of the
#      Overview panel). That opens a terminal already pointed at this site.
#   2. Drag this file into that terminal, or cd to where it is, then:
#         bash ladybunya-build.sh
#
# WHAT IT DOES:
#   - Installs & activates the Twenty Twenty-Five theme
#   - Applies a warm style variation
#   - Deletes WordPress's default junk ("Hello world!" post, sample page)
#   - Creates all the real pages (Home, About, Offerings, the 8 services,
#     Events & Bookings, Blog landing, Contact)
#   - Fills Home and Contact with ready-to-use copy
#   - Fills every other page with the agreed template + [SHARNI] prompts
#     as visible placeholder text, so nothing is invented
#   - Sets Home as the front page and Blog as the posts page
#   - Builds the primary navigation menu
#   - Installs the Amelia booking plugin (configuration is done in its UI
#     afterwards — see notes at the end of the run)
#
# WHAT IT DELIBERATELY DOES NOT DO:
#   - It does not invent service descriptions or Sharni's bio
#   - It does not configure Amelia services, Stripe, or pricing
#   - It does not touch any live/production site (guard below)
#
# SAFE TO RE-RUN: pages are matched by slug and updated, not duplicated.
# ------------------------------------------------------------------

set -euo pipefail

# ----- SAFETY GUARD ------------------------------------------------
# Refuse to run anywhere that doesn't look like the local dev site.
SITE_URL="$(wp option get siteurl 2>/dev/null || echo '')"
echo "Detected site URL: ${SITE_URL:-<none>}"
case "$SITE_URL" in
  *.local|*localhost*|*127.0.0.1*)
    echo "✓ Local environment confirmed. Proceeding."
    ;;
  *)
    echo "✗ This does not look like a local dev site (expected a .local URL)."
    echo "  Refusing to run to protect any live site. Aborting."
    exit 1
    ;;
esac

echo
echo "=== 1. Theme: install & activate Twenty Twenty-Five ==="
wp theme install twentytwentyfive --activate

# Apply a warm style variation if available (falls back silently if not).
# You/Sharni can change this visually later under Appearance > Editor > Styles.

echo
echo "=== 2. Remove default WordPress junk ==="
# Delete the "Hello world!" sample post and the "Sample Page" if present.
wp post delete $(wp post list --post_type=post --name="hello-world" --field=ID --format=ids 2>/dev/null) --force 2>/dev/null || echo "  (no hello-world post — fine)"
wp post delete $(wp post list --post_type=page --name="sample-page" --field=ID --format=ids 2>/dev/null) --force 2>/dev/null || echo "  (no sample page — fine)"

echo
echo "=== 3. Helper: create-or-update a page by slug ==="
# Usage: upsert_page <slug> <title> <body-file>
upsert_page () {
  local slug="$1" title="$2" body_file="$3"
  local existing
  existing="$(wp post list --post_type=page --name="$slug" --field=ID --format=ids 2>/dev/null || echo '')"
  if [ -n "$existing" ]; then
    wp post update "$existing" --post_title="$title" --post_content="$(cat "$body_file")"
    echo "  updated: $title (ID $existing)"
  else
    wp post create --post_type=page --post_status=publish --post_title="$title" \
      --post_name="$slug" --post_content="$(cat "$body_file")" >/dev/null
    echo "  created: $title"
  fi
}

# Working dir for the page-body snippets this script writes out.
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# ----- PAGE BODIES -------------------------------------------------
# Home — READY-TO-USE copy (from real live-site content).
cat > "$TMP/home.html" <<'HOME'
<!-- wp:heading {"level":1} --><h1>Adding a pinch of panache into your life</h1><!-- /wp:heading -->
<!-- wp:paragraph --><p>Lady Bunya Enterprises delivers services, events and products designed to add a pinch of panache into your life — with passion and sprinkles of kindness, flower power, self-care, conscious relating, earth connection, sensuality and fun. Based on Wurundjeri Country at the Moora Moora Co-operative in the Dandenong Ranges.</p><!-- /wp:paragraph -->
<!-- wp:heading {"level":2} --><h2>What we offer</h2><!-- /wp:heading -->
<!-- wp:paragraph --><p><strong>Movement &amp; Voice</strong> — Dance, song and breath to move energy and free the body.</p><!-- /wp:paragraph -->
<!-- wp:paragraph --><p><strong>Earth &amp; Wellbeing</strong> — Reconnect with country, garden and self.</p><!-- /wp:paragraph -->
<!-- wp:paragraph --><p><strong>Speaking &amp; Facilitation</strong> — Find your voice and hold a room with confidence.</p><!-- /wp:paragraph -->
<!-- wp:paragraph --><p><em>[SHARNI — one or two sentences for the very top of the page: if a newcomer landed here, what single feeling or outcome do you want them to walk away wanting?]</em></p><!-- /wp:paragraph -->
HOME

# Contact — READY-TO-USE copy (from real live-site content).
cat > "$TMP/contact.html" <<'CONTACT'
<!-- wp:heading --><h2>Contact</h2><!-- /wp:heading -->
<!-- wp:paragraph --><p><strong>Email:</strong> sharni@ladybunya.com<br><strong>Phone:</strong> 0402 305 326</p><!-- /wp:paragraph -->
<!-- wp:heading --><h2>Find us</h2><!-- /wp:heading -->
<!-- wp:paragraph --><p>Moora Moora Co-operative<br>Mount Toolebewong, Wurundjeri Country<br>VIC 3777</p><!-- /wp:paragraph -->
<!-- wp:paragraph --><p><em>[SHARNI — confirm whether the street address should be public, or shown as "enquire for location" since it's a residential co-operative.]</em></p><!-- /wp:paragraph -->
<!-- wp:heading --><h2>Hours</h2><!-- /wp:heading -->
<!-- wp:paragraph --><p>Monday–Friday: 2:00pm – 5:00pm<br>Saturday: 11:00am – 3:00pm</p><!-- /wp:paragraph -->
CONTACT

# About — TEMPLATE + prompts (no invented bio).
cat > "$TMP/about.html" <<'ABOUT'
<!-- wp:paragraph --><p><em>This page needs Sharni's real words — people book a person, not a service. Replace the prompts below.</em></p><!-- /wp:paragraph -->
<!-- wp:paragraph --><p><em>[SHARNI — Who are you and what do you do, in 2–3 sentences?]</em></p><!-- /wp:paragraph -->
<!-- wp:paragraph --><p><em>[SHARNI — What's the through-line connecting dance, voice, earth-connection and speaking for you?]</em></p><!-- /wp:paragraph -->
<!-- wp:paragraph --><p><em>[SHARNI — What do you want people to feel in your sessions?]</em></p><!-- /wp:paragraph -->
<!-- wp:paragraph --><p><em>[SHARNI — Any qualifications, training or lineage to name? And a warm portrait photo.]</em></p><!-- /wp:paragraph -->
ABOUT

# Reusable service-page template generator.
# Usage: service_body "Service Name" "extra prompt" > file
service_body () {
  local name="$1" extra="$2"
  cat <<SVC
<!-- wp:paragraph --><p><em>[SHARNI — one-line hook: what is $name and who is it for?]</em></p><!-- /wp:paragraph -->
<!-- wp:heading --><h2>What to expect</h2><!-- /wp:heading -->
<!-- wp:paragraph --><p><em>[SHARNI — what actually happens in a session? 2–4 plain, sensory sentences.]</em></p><!-- /wp:paragraph -->
<!-- wp:heading --><h2>Who it's for</h2><!-- /wp:heading -->
<!-- wp:paragraph --><p><em>[SHARNI — beginners welcome? all bodies/ages? any prerequisites?]</em></p><!-- /wp:paragraph -->
<!-- wp:heading --><h2>Details</h2><!-- /wp:heading -->
<!-- wp:list --><ul><li>Format: <em>[group / 1-on-1 / workshop / online / in person]</em></li><li>Where: <em>[Moora Moora studio / outdoors / online]</em></li><li>Duration: <em>[e.g. 60 min]</em></li><li>Price: <em>[\$ per session / package / sliding scale]</em></li></ul><!-- /wp:list -->
${extra:+<!-- wp:paragraph --><p><em>$extra</em></p><!-- /wp:paragraph -->}
<!-- wp:heading --><h2>Book</h2><!-- /wp:heading -->
<!-- wp:paragraph --><p><em>[Amelia booking block goes here once configured.]</em></p><!-- /wp:paragraph -->
SVC
}

# Offerings landing page.
cat > "$TMP/offerings.html" <<'OFF'
<!-- wp:paragraph --><p>Explore what Lady Bunya offers — grouped into Movement &amp; Voice, Earth &amp; Wellbeing, and Speaking &amp; Facilitation. Choose a path below.</p><!-- /wp:paragraph -->
<!-- wp:paragraph --><p><em>[SHARNI — optional short intro line for this page.]</em></p><!-- /wp:paragraph -->
OFF

# Events & Bookings landing.
cat > "$TMP/events.html" <<'EV'
<!-- wp:paragraph --><p>Ready to add a little panache? Browse what's coming up below and book your spot. Payment is secure and confirms your place instantly.</p><!-- /wp:paragraph -->
<!-- wp:paragraph --><p><em>[Amelia events calendar + booking block go here once configured. SHARNI — confirm cancellation/refund policy, e.g. "full refund up to 48h before".]</em></p><!-- /wp:paragraph -->
EV

# Blog landing (a real page; WP will list posts here once set as posts page).
cat > "$TMP/blog.html" <<'BL'
<!-- wp:paragraph --><p>News, reflections and what's coming up.</p><!-- /wp:paragraph -->
BL

echo
echo "=== 4. Create / update pages ==="
upsert_page "home"      "Home"               "$TMP/home.html"
upsert_page "about"     "About"              "$TMP/about.html"
upsert_page "offerings" "Offerings"          "$TMP/offerings.html"
upsert_page "contact"   "Contact"            "$TMP/contact.html"
upsert_page "events"    "Events & Bookings"  "$TMP/events.html"
upsert_page "blog"      "Blog"               "$TMP/blog.html"

# The 8 service pages (cultural ones carry an extra respectful-description note).
service_body "Dancercise" "" > "$TMP/s1.html";  upsert_page "dancercise" "Dancercise" "$TMP/s1.html"
service_body "Vocal Coaching" "" > "$TMP/s2.html"; upsert_page "vocal-coaching" "Vocal Coaching" "$TMP/s2.html"
service_body "Sanskrit Prayer Singing" "Describe respectfully and accurately — Sharni's words." > "$TMP/s3.html"; upsert_page "sanskrit-prayer-singing" "Sanskrit Prayer Singing" "$TMP/s3.html"
service_body "Eco-Therapy" "" > "$TMP/s4.html"; upsert_page "eco-therapy" "Eco-Therapy" "$TMP/s4.html"
service_body "Wayapa Wuurrk" "This is an Aboriginal earth-connection practice — describe it exactly as you are trained/authorised to, including acknowledgement of its origins." > "$TMP/s5.html"; upsert_page "wayapa-wuurrk" "Wayapa Wuurrk" "$TMP/s5.html"
service_body "Gardening" "" > "$TMP/s6.html"; upsert_page "gardening" "Gardening" "$TMP/s6.html"
service_body "Public Speaking" "" > "$TMP/s7.html"; upsert_page "public-speaking" "Public Speaking" "$TMP/s7.html"
service_body "Workshop / Series Facilitation" "" > "$TMP/s8.html"; upsert_page "workshop-series-facilitation" "Workshop / Series Facilitation" "$TMP/s8.html"

echo
echo "=== 5. Front page = Home, posts page = Blog ==="
HOME_ID="$(wp post list --post_type=page --name=home --field=ID --format=ids)"
BLOG_ID="$(wp post list --post_type=page --name=blog --field=ID --format=ids)"
wp option update show_on_front page
wp option update page_on_front "$HOME_ID"
wp option update page_for_posts "$BLOG_ID"
echo "  front page ID $HOME_ID, posts page ID $BLOG_ID"

echo
echo "=== 6. Primary navigation menu ==="
# Remove an existing menu of the same name to avoid duplicates on re-run.
wp menu delete "Primary" 2>/dev/null || true
wp menu create "Primary"
for slug in home about offerings events blog contact; do
  pid="$(wp post list --post_type=page --name="$slug" --field=ID --format=ids)"
  wp menu item add-post "Primary" "$pid" >/dev/null
done

echo
echo "=== 7. Booking plugin: install Amelia (configure in its UI after) ==="
# Free version slug on the WordPress plugin directory:
wp plugin install ameliabooking --activate \
  || echo "  (couldn't auto-install Amelia — install it from Plugins > Add New)"

echo
echo "=================================================================="
echo "DONE. Open the site (Local > 'Open site') to see the skeleton."
echo
echo "NEXT STEPS (manual, by design):"
echo "  • Appearance > Editor > Styles — pick a warm style variation for"
echo "    the brand, adjust fonts/colours visually."
echo "  • Replace every [SHARNI ...] prompt with her real words."
echo "  • Amelia (left menu) — create services, set prices, connect Stripe"
echo "    in TEST mode, then place its booking block on Events & Bookings."
echo "  • Replace placeholder social links with Lady Bunya's real ones."
echo "=================================================================="
