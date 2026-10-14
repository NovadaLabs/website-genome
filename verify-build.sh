#!/bin/bash
# verify-build.sh — mechanical gate between BUILD and DELIVERY
# Run this BEFORE deploying. Fails if the build is broken.
# Usage: bash verify-build.sh <project-dir> [original-domain]

set -o pipefail
DIR="${1:-.}"
ORIGINAL_DOMAIN="${2:-}"
FAIL=0
WARN=0

echo "=== verify-build.sh ==="
echo "Project: $DIR"
[ -n "$ORIGINAL_DOMAIN" ] && echo "Original domain: $ORIGINAL_DOMAIN"
echo ""

# 1. npm run build passes
echo "CHECK 1: npm run build"
cd "$DIR" || { echo "FAIL: directory $DIR not found"; exit 1; }
if npm run build 2>&1 | tail -3 | grep -qi "error"; then
  echo "  FAIL: build has errors"
  FAIL=1
else
  echo "  PASS"
fi

# 2. Every route returns 200
echo ""
echo "CHECK 2: Route health (start server, curl each route)"
npx next start -p 4567 &>/dev/null &
SERVER_PID=$!
sleep 3

if [ -f "specs/sitemap.json" ]; then
  ROUTES=$(cat specs/sitemap.json 2>/dev/null | python3 -c "
import json,sys
try:
  data = json.load(sys.stdin)
  # Handle both array and object formats
  if isinstance(data, list):
    pages = data
  elif isinstance(data, dict):
    pages = data.get('pages', data.get('urls', [data]))
    if isinstance(pages, dict): pages = [pages]
  else:
    pages = []
  for p in pages:
    path = p.get('path', p.get('url', '')) if isinstance(p, dict) else str(p)
    if path: print(path)
except: pass
" 2>/dev/null)
else
  # Fallback: scan app directory for page.tsx files
  ROUTES=$(find src/app -name "page.tsx" 2>/dev/null | sed 's|src/app||;s|/page.tsx||;s|^$|/|')
fi

ROUTE_COUNT=0
ROUTE_FAIL=0
for route in $ROUTES; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:4567${route}" 2>/dev/null)
  ROUTE_COUNT=$((ROUTE_COUNT + 1))
  if [ "$STATUS" != "200" ]; then
    echo "  FAIL: $route → HTTP $STATUS"
    ROUTE_FAIL=$((ROUTE_FAIL + 1))
    FAIL=1
  fi
done
echo "  Routes checked: $ROUTE_COUNT, failed: $ROUTE_FAIL"
[ $ROUTE_FAIL -eq 0 ] && echo "  PASS"

kill $SERVER_PID 2>/dev/null

# 3. Self-contained check (no links to original domain)
echo ""
echo "CHECK 3: Self-contained (no external product links)"
if [ -n "$ORIGINAL_DOMAIN" ]; then
  EXTERNAL=$(grep -r "$ORIGINAL_DOMAIN" src/ --include="*.tsx" --include="*.ts" -l 2>/dev/null | wc -l | tr -d ' ')
  if [ "$EXTERNAL" -gt 0 ]; then
    echo "  WARN: $EXTERNAL files reference $ORIGINAL_DOMAIN"
    grep -r "$ORIGINAL_DOMAIN" src/ --include="*.tsx" --include="*.ts" -l 2>/dev/null | head -5 | sed 's/^/    /'
    WARN=$((WARN + 1))
  else
    echo "  PASS"
  fi
else
  echo "  SKIP (no original domain provided)"
fi

# 4. Placeholder check
echo ""
echo "CHECK 4: No placeholder content"
PLACEHOLDERS=$(grep -ri "lorem ipsum\|coming soon\|TODO.*implement\|placeholder" src/ --include="*.tsx" --include="*.ts" -l 2>/dev/null | wc -l | tr -d ' ')
if [ "$PLACEHOLDERS" -gt 0 ]; then
  echo "  WARN: $PLACEHOLDERS files may have placeholder content"
  grep -ri "lorem ipsum\|coming soon\|TODO.*implement\|placeholder" src/ --include="*.tsx" --include="*.ts" -l 2>/dev/null | head -5 | sed 's/^/    /'
  WARN=$((WARN + 1))
else
  echo "  PASS"
fi

# 5. Image check
echo ""
echo "CHECK 5: Images resolve"
IMG_TOTAL=$(find public/images -type f 2>/dev/null | wc -l | tr -d ' ')
echo "  Images in public/: $IMG_TOTAL"
[ "$IMG_TOTAL" -eq 0 ] && echo "  WARN: zero images — replica may look like a wireframe" && WARN=$((WARN + 1))
[ "$IMG_TOTAL" -gt 0 ] && echo "  PASS"

# Summary
echo ""
echo "=== SUMMARY ==="
echo "Failures: $FAIL"
echo "Warnings: $WARN"
if [ $FAIL -gt 0 ]; then
  echo "RESULT: BLOCKED — fix failures before delivery"
  exit 1
elif [ $WARN -gt 0 ]; then
  echo "RESULT: PASS WITH WARNINGS — review before delivery"
  exit 0
else
  echo "RESULT: ALL CLEAR — ready for delivery"
  exit 0
fi
