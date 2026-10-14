#!/usr/bin/env bash
# verify-extraction.sh — Mechanical gate that blocks build if specs are incomplete.
# Run AFTER extraction (Step 3), BEFORE build (Step 4).
# Exit 0 = pass (proceed to build). Exit 1 = fail (extraction incomplete).
#
# Usage: bash verify-extraction.sh [specs-dir] [sitemap-file]
#   specs-dir:    path to specs/ folder (default: ./specs)
#   sitemap-file: path to sitemap.json (default: specs/sitemap.json)

# No set -e: one failed check should NOT skip remaining checks
set -o pipefail

SPECS_DIR="${1:-./specs}"
SITEMAP="${2:-$SPECS_DIR/sitemap.json}"
FAIL=0
WARN=0

red()    { printf '\033[1;31m%s\033[0m\n' "$1"; }
green()  { printf '\033[1;32m%s\033[0m\n' "$1"; }
yellow() { printf '\033[1;33m%s\033[0m\n' "$1"; }
bold()   { printf '\033[1m%s\033[0m\n' "$1"; }

fail() { red "FAIL: $1"; FAIL=$((FAIL + 1)); }
warn() { yellow "WARN: $1"; WARN=$((WARN + 1)); }
pass() { green "PASS: $1"; }

bold "=== Website Genome Extraction Verification ==="
echo ""

# ── 1. Sitemap exists ──────────────────────────────────────────────────
if [[ ! -f "$SITEMAP" ]]; then
  fail "No sitemap found at $SITEMAP"
  red "  FIX: Run Step 2 (DISCOVER) to generate specs/sitemap.json"
  echo ""
  red "=== BLOCKED: Cannot verify without sitemap. Run extraction first. ==="
  exit 1
fi
pass "Sitemap exists: $SITEMAP"

# Parse page slugs from sitemap — handles multiple formats:
#   Format A: flat array of strings ["/about", "/pricing"]
#   Format B: array of objects [{path:"/about"}, {url:"/pricing"}]
#   Format C: wrapped object {"pages": [...]} or {"urls": [...]}
#   Format D: nested children [{path:"/products", children:[{path:"/products/api"}]}]
#   Format E: site-crawler manifest.json {"page-name": {htmlSize:...}}
PAGES=$(SITEMAP_PATH="$SITEMAP" python3 << 'PYEOF'
import json, sys, os

def slugify(path):
    """Convert a URL path to a filename-safe slug."""
    s = path.strip("/").replace("/", "-")
    return s if s else "index"

def extract_paths(data, results=None):
    """Recursively extract paths from any JSON structure."""
    if results is None:
        results = []

    if isinstance(data, str):
        results.append(slugify(data))
    elif isinstance(data, list):
        for item in data:
            extract_paths(item, results)
    elif isinstance(data, dict):
        # Check for path-like keys
        for key in ("path", "slug", "url", "route", "href"):
            if key in data and isinstance(data[key], str):
                results.append(slugify(data[key]))
                break
        else:
            # site-crawler manifest format: {"page-name": {...}}
            # Check if values are dicts with known extraction keys
            if all(isinstance(v, dict) for v in data.values()):
                for key in data:
                    results.append(key.replace("/", "-").strip("-") or "index")

        # Check for wrapper keys
        for wrapper in ("pages", "urls", "routes", "sitemap", "items"):
            if wrapper in data:
                extract_paths(data[wrapper], results)

        # Check for nested children
        if "children" in data and isinstance(data["children"], list):
            extract_paths(data["children"], results)

    return results

try:
    sitemap = os.environ["SITEMAP_PATH"]
    with open(sitemap) as f:
        data = json.load(f)
    paths = extract_paths(data)
    # Deduplicate while preserving order
    seen = set()
    for p in paths:
        if p not in seen:
            seen.add(p)
            print(p)
except Exception as e:
    print(f"PARSE_ERROR: {e}", file=sys.stderr)
PYEOF
)

# If python parsing failed, fall back to counting HTML files directly
if [[ -z "$PAGES" ]] || echo "$PAGES" | grep -q "PARSE_ERROR"; then
  warn "Could not parse sitemap JSON — falling back to counting specs/html/ files"
  HTML_DIR="$SPECS_DIR/html"
  if [[ -d "$HTML_DIR" ]]; then
    PAGES=$(find "$HTML_DIR" -name "*.html" -exec basename {} .html \; 2>/dev/null)
  fi

  if [[ -z "$PAGES" ]]; then
    # Try site-crawler output format (specs/public/manifest.json)
    MANIFEST="$SPECS_DIR/public/manifest.json"
    if [[ -f "$MANIFEST" ]]; then
      SITEMAP="$MANIFEST"
      PAGES=$(python3 -c "
import json
with open('$MANIFEST') as f:
    data = json.load(f)
if isinstance(data, dict):
    for k in data: print(k)
elif isinstance(data, list):
    for item in data:
        if isinstance(item, dict):
            print(item.get('path','').strip('/').replace('/','-') or 'index')
        elif isinstance(item, str):
            print(item.strip('/').replace('/','-') or 'index')
" 2>/dev/null || echo "")
    fi
  fi

  if [[ -z "$PAGES" ]]; then
    fail "Could not parse pages from $SITEMAP and no HTML files found"
    red "  FIX: Ensure sitemap.json exists OR specs/html/ has .html files"
    PAGES="index"
  fi
fi

PAGE_COUNT=$(echo "$PAGES" | wc -l | tr -d ' ')
echo "  Pages in sitemap: $PAGE_COUNT"
echo ""

# ── 2. HTML files exist (>1KB each) ───────────────────────────────────
bold "--- Dimension 1: STRUCTURE (HTML) ---"
HTML_DIR="$SPECS_DIR/html"
if [[ ! -d "$HTML_DIR" ]]; then
  fail "No html/ directory at $HTML_DIR"
  red "  FIX: Extract HTML for each page → specs/html/<page>.html"
else
  HTML_COUNT=0
  SMALL_HTML=0
  for page in $PAGES; do
    html_file="$HTML_DIR/${page}.html"
    if [[ -f "$html_file" ]]; then
      size=$(wc -c < "$html_file" | tr -d ' ')
      if [[ "$size" -lt 1024 ]]; then
        warn "HTML too small (<1KB): $html_file ($size bytes)"
        SMALL_HTML=$((SMALL_HTML + 1))
      else
        HTML_COUNT=$((HTML_COUNT + 1))
      fi
    else
      # Try alternative names (with/without leading dash)
      found=0
      for alt in "$HTML_DIR"/*"${page}"*.html; do
        if [[ -f "$alt" ]]; then found=1; break; fi
      done
      if [[ $found -eq 0 ]]; then
        fail "Missing HTML: $html_file"
        red "  FIX: existing-chrome cdp.py eval <match> 'document.documentElement.outerHTML' on this page"
      fi
    fi
  done
  if [[ $HTML_COUNT -eq $PAGE_COUNT ]]; then
    pass "All $PAGE_COUNT pages have HTML files (>1KB)"
  else
    echo "  HTML coverage: $HTML_COUNT / $PAGE_COUNT pages"
  fi
fi
echo ""

# ── 3. Design tokens ──────────────────────────────────────────────────
bold "--- Dimension 2: STYLE ---"
if [[ -f "$SPECS_DIR/design-tokens.json" ]]; then
  pass "Design tokens file exists"
else
  fail "No design-tokens.json"
  red "  FIX: Extract colors, fonts, spacing from computed styles"
fi
echo ""

# ── 4. Assets downloaded ──────────────────────────────────────────────
bold "--- Dimension 3: ASSETS ---"
ASSETS_DIR="$SPECS_DIR/assets"
if [[ -d "$ASSETS_DIR" ]]; then
  IMG_COUNT=$(find "$ASSETS_DIR" -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.svg' -o -name '*.webp' -o -name '*.gif' -o -name '*.ico' \) 2>/dev/null | wc -l | tr -d ' ')
  FONT_COUNT=$(find "$ASSETS_DIR" -type f \( -name '*.woff' -o -name '*.woff2' -o -name '*.ttf' -o -name '*.otf' \) 2>/dev/null | wc -l | tr -d ' ')
  if [[ $IMG_COUNT -gt 0 ]]; then
    pass "Images downloaded: $IMG_COUNT files"
  else
    fail "No images found in $ASSETS_DIR"
    red "  FIX: Download all <img> src URLs to specs/assets/images/"
  fi
  if [[ $FONT_COUNT -gt 0 ]]; then
    pass "Fonts downloaded: $FONT_COUNT files"
  else
    warn "No font files found (may use system/CDN fonts)"
  fi
else
  fail "No assets/ directory at $ASSETS_DIR"
  red "  FIX: Download images, fonts, SVGs to specs/assets/"
fi
echo ""

# ── 5. Interactions documented ────────────────────────────────────────
bold "--- Dimension 5: BEHAVIOR ---"
if [[ -f "$SPECS_DIR/interactions.json" ]]; then
  INTERACTION_COUNT=$(python3 -c "
import json
with open('$SPECS_DIR/interactions.json') as f:
    data = json.load(f)
print(len(data) if isinstance(data, list) else sum(len(v) for v in data.values()) if isinstance(data, dict) else 0)
" 2>/dev/null || echo "0")
  if [[ "$INTERACTION_COUNT" -gt 0 ]]; then
    pass "Interactions documented: $INTERACTION_COUNT entries"
  else
    warn "interactions.json exists but appears empty"
  fi
else
  warn "No interactions.json — interactive elements may not be captured"
  yellow "  FIX: Click every interactive element, record results → specs/interactions.json"
fi
echo ""

# ── 6. States captured ────────────────────────────────────────────────
bold "--- Dimension 6: STATE ---"
STATES_DIR="$SPECS_DIR/states"
if [[ -d "$STATES_DIR" ]]; then
  STATE_COUNT=$(find "$STATES_DIR" -type f | wc -l | tr -d ' ')
  pass "State files captured: $STATE_COUNT"
else
  warn "No states/ directory — tab/form states may not be captured"
  yellow "  FIX: Capture each tab, dropdown, form state → specs/states/<page>/<state>.html"
fi
echo ""

# ── 7. APIs captured (for dashboard/SaaS sites) ──────────────────────
bold "--- Dimension 7: NETWORK ---"
if [[ -f "$SPECS_DIR/apis.json" ]]; then
  API_COUNT=$(python3 -c "
import json
with open('$SPECS_DIR/apis.json') as f:
    data = json.load(f)
print(len(data) if isinstance(data, list) else len(data.keys()) if isinstance(data, dict) else 0)
" 2>/dev/null || echo "0")
  if [[ "$API_COUNT" -gt 0 ]]; then
    pass "API endpoints captured: $API_COUNT"
  else
    warn "apis.json exists but appears empty"
  fi
else
  warn "No apis.json — dashboard Submit buttons may be dead"
  yellow "  FIX: Intercept network calls during interaction → specs/apis.json"
fi
echo ""

# ── 8. Metadata ───────────────────────────────────────────────────────
bold "--- Dimension 8: METADATA ---"
META_DIR="$SPECS_DIR/metadata"
if [[ -d "$META_DIR" ]]; then
  META_COUNT=$(find "$META_DIR" -type f -name '*.json' | wc -l | tr -d ' ')
  pass "Metadata files: $META_COUNT"
else
  warn "No metadata/ directory"
  yellow "  FIX: Extract <title>, <meta>, OG tags → specs/metadata/<page>.json"
fi
echo ""

# ── 9. Shared components ──────────────────────────────────────────────
bold "--- SHARED COMPONENTS ---"
COMP_DIR="$SPECS_DIR/components"
if [[ -d "$COMP_DIR" ]]; then
  COMP_COUNT=$(find "$COMP_DIR" -type f | wc -l | tr -d ' ')
  pass "Component specs: $COMP_COUNT files"
else
  warn "No components/ directory — navbar/footer may not be extracted separately"
fi
echo ""

# ── 10. Build check (if project exists) ───────────────────────────────
bold "--- BUILD ---"
if [[ -f "package.json" ]]; then
  if npm run build --silent 2>/dev/null; then
    pass "npm run build passes"
  else
    fail "npm run build failed"
    red "  FIX: Resolve build errors before delivery"
  fi
else
  echo "  (No package.json — skipping build check)"
fi
echo ""

# ── Summary ───────────────────────────────────────────────────────────
bold "=== SUMMARY ==="
echo "  Pages:    $PAGE_COUNT"
echo "  Failures: $FAIL"
echo "  Warnings: $WARN"
echo ""

if [[ $FAIL -gt 0 ]]; then
  red "=== BLOCKED: $FAIL failures. Extraction incomplete. Do NOT proceed to build. ==="
  red "=== Fix the failures above, then re-run this script. ==="
  exit 1
else
  if [[ $WARN -gt 0 ]]; then
    yellow "=== PASSED with $WARN warnings. Review warnings before building. ==="
  else
    green "=== PASSED. Extraction complete. Proceed to build. ==="
  fi
  exit 0
fi
