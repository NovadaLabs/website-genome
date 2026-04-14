# Website Genome OS v2.2

> Single-file agent OS. Every line burned in from a real failure.
> This is a QUALITY SYSTEM, not a checklist. "I did something" ≠ "I did it completely."
> For each step: did you produce the EXACT artifact? Is it COMPLETE?

---

## STEP 0: PREREQUISITES — BLOCKING GATE

```
FIRST QUESTION: Does the target site have auth-gated pages (dashboard, settings, billing)?

  NO  → Public site fast path. Skip Chrome setup entirely.
        Tools: site-crawler (bulk) + Playwright (backup). Proceed to LAYER 0.

  YES → Chrome is required. Do not skip this.

CHROME SETUP (auth-gated sites only — one command per session):
  Human runs: cd ~/Projects/agent-chrome-bridge && npm run launch-chrome
  What this does: copies your login sessions → relaunches Chrome on port 9222.

  Agent verifies: bb-browser open <any-url> — does it connect?
  → YES → proceed to LAYER 0
  → NO  → STOP. Tell human: "Please run: cd ~/Projects/agent-chrome-bridge && npm run launch-chrome"
           Do not proceed until confirmed.

  RULE: bb-browser = your Chrome's login sessions. No alternative for auth-gated pages.
  RULE: Each agent opens its OWN TAB. Never share tabs between agents.
```

---

## LAYER 0: MISSION — "What am I doing?"

```
READ → DECIDE → GO TO THE RIGHT PIPELINE

  Existing replica to fix?      → FIX mode  → §FIX
  URL to replicate?             → COPY mode → §COPY
  Project checklist to build?   → BUILD mode → §BUILD

SCALE:
  < 10 pages:   single agent, fully autonomous
  10-50 pages:  single agent, phase commits
  50+ pages:    orchestrator + fresh executor agents per phase
  Why fresh: orchestrator accumulates context bias after extraction → gets sloppy in build.
             Fresh agents read specs/ only — no bias, no shortcuts.

QUESTION POLICY:
  Ask ONLY when decision is irreversible: architecture, auth provider, data model.
  Default silently: colors, spacing, copy, icons. When torn: pick simpler, document choice.
```

---

## LAYER 1: TOOLS — "What do I use?"

```
EXTRACTION DECISION TREE:
  Public pages only?
  ├── YES → site-crawler + Playwright (no Chrome needed)
  └── NO (has auth-gated pages)
       ├── bb-browser connected? → bb-browser (primary)
       └── bb-browser down?     → CDP via agent-chrome-bridge

TOOL REFERENCE:
  bb-browser      open <url> | snapshot -i | eval "js" | click @ref | hover @ref | close
                  Best for: dropdowns, tabs, modals, auth-gated pages, component capture

  site-crawler    site-crawler <url> --output specs/ --max-pages 200
                  Best for: crawl 100+ pages, download all assets, generate manifest
                  Output: HTML + CSS + Markdown + screenshot + metadata + _assets/ per page
                  Repo: NovadaLabs/site-crawler

  Playwright      Headless. Public pages only. No login state.

  CDP (agent-chrome-bridge)  npm run launch-chrome → Chrome on port 9222
                          Backup when bb-browser can't connect.

  gstack          Responsive QA at 375 / 768 / 1440px

RULES:
  AI needs HTML + a11y tree + CSS. NOT screenshots.
  Auth-gated pages → always bb-browser (user's Chrome). Never a fresh browser instance.
  Screenshots = human QA only. Never a primary extraction artifact.

BUILD STACK: Next.js 16 + shadcn/ui + Tailwind 4 + Geist + Vercel
  Pinned versions: genome/v1/VERSION.md

SUB-AGENT RULE: Send 1 canary agent first. Verify it completes. Then dispatch rest in batches of 2-3.
  If agents fail: fall back to sequential. Don't block on broken parallelism.
```

---

## §COPY — Replicate a website from URL

```
STEP 1: CONNECT
  bb-browser open <target-url>
  Gate: Can you see auth-gated pages?
  → NO → ask human to log in → retry

STEP 1.5: DETECT TECH STACK
  Before extraction, identify what the target site uses.
  Builder uses SAME stack as original — wrong tech stack = different behavior.

  bb-browser eval + page source inspection:
  Framework:  □ __NEXT_DATA__ → Next.js  □ ng-version → Angular  □ data-v- → Vue
  CSS:        □ flex bg-* text-* → Tailwind  □ col-md-* btn-* → Bootstrap
  Auth:       □ clerk.js → Clerk  □ next-auth cookies → NextAuth  □ auth0.js → Auth0  □ supabase-auth → Supabase
  Payment:    □ stripe.js → Stripe  □ paddle.js → Paddle
  Analytics:  □ gtag.js → GA  □ posthog-js → PostHog  □ plausible.js → Plausible
  Other:      □ sentry.js → Sentry  □ intercom widget → Intercom  □ algolia → Algolia

  Output: specs/tech-stack.json
  Gate: cat specs/tech-stack.json | python3 -c "import json,sys; d=json.load(sys.stdin); assert d.get('framework') and d.get('css'), 'FAIL: framework or css missing'"

STEP 2: DISCOVER ALL PAGES
  site-crawler <url> --output specs/public --max-pages 200   ← public pages
  bb-browser: navigate sidebar, click every link, collect paths  ← auth-gated pages
  Classify: INTERNAL (replicate) / EXTERNAL (keep as-is)
  DASHBOARD FIRST — auth-gated pages are the product. Marketing pages are the wrapper.
  Output: specs/sitemap.json
  Gate: python3 -c "import json; d=json.load(open('specs/sitemap.json')); print(f'Pages found: {len(d) if isinstance(d,list) else len(d.get(\"pages\",d))}')"
        → Verify count matches what you see in navigation. If short → re-crawl.

STEP 3: EXTRACT — 8 Dimensions (ALL required for EVERY page)

  REPLICATION QUALITY = EXTRACTION QUALITY.
  Extract 100% → build is mechanical. Extract 70% → guess 30% → human catches it every time.
  Every replication failure in history traces to incomplete extraction, not bad code.

  For EVERY page in the sitemap, capture ALL 8:

  DIM 1: STRUCTURE   document.documentElement.outerHTML → specs/html/<page>.html
                     This is the PRIMARY source for rebuilding. Don't use querySelector('main').

  DIM 2: STYLE       Computed CSS per page → specs/css/<page>.css
                     Design tokens (colors, fonts, spacing, radius) → specs/design-tokens.json
                     (site-crawler saves styles.css automatically)

  DIM 3: ASSETS      All images + fonts + SVGs → downloaded to specs/assets/
                     Gate: 0 placeholder images. Every <img> = real downloaded file.

  DIM 4: CONTENT     Verbatim text, all visible numbers, table data → specs/pages/<page>.md
                     (site-crawler saves page.md automatically)
                     Rule: every text in the replica comes from extraction, not AI imagination.

  DIM 5: BEHAVIOR    Click EVERY interactive element on EVERY page. Record what changes:
                     Tab → each tab's content. Dropdown → each option + what it changes.
                     Button → API call / modal / navigation. Form → all field states.
                     RECURSIVE: if clicking reveals new elements, click those too.
                     → specs/interactions.json

  DIM 6: STATE       ALL possible page states:
                     Tabs: click each → capture content → save URL (sub-tab URLs are hidden)
                     Dropdowns: each option + resulting content change
                     Forms: empty / filled / error / success
                     Auth: logged-in view + logged-out redirect
                     → specs/states/<page>/<state>.html

  DIM 7: NETWORK     Intercept API calls via DevTools or CDP.
                     For each: URL, method, headers, request body, response.
                     Strategy per endpoint: PROXY (real API) or MOCK (saved response).
                     Gate: every Submit button has a captured API endpoint.
                     → specs/apis.json

  DIM 8: METADATA    <title>, meta description, OG tags, JSON-LD
                     → specs/metadata/<page>.json (site-crawler saves automatically)

  SHARED COMPONENTS (navbar, footer, hero — appear on every page):
    Extract separately: outerHTML + structure (columns, items, sub-links).
    Navbar: hover each menu item → capture dropdown HTML + screenshot.
    → specs/components/
    WHY: Shared components affect every page. A wrong navbar = 100 broken pages.

  COMPLETENESS CHECK (after each page):
    □ HTML  □ CSS  □ Assets  □ Content  □ Interactions  □ States  □ APIs  □ Metadata
    Any unchecked = incomplete. Incomplete extraction → incomplete replica → human catches it.

  EXTRACTION GATE (non-negotiable — run this before any code):
    bash ~/.claude/skills/website-genome/verify-extraction.sh specs/
    → Exit 0: proceed to Step 3.5 / Step 4
    → Exit 1: fix every FAIL it reports. Re-run. Do not proceed until Exit 0.
    This script checks all 8 dimensions mechanically. It cannot be faked.

STEP 3.5: HUMAN GATE (conditional)
  Simple site (< 15 pages, no auth-gated areas):
    → Skip. Proceed autonomously.

  Complex site (15+ pages OR has dashboard):
    → Report: page count, route list, interactive states found, assets downloaded.
    → "Found N pages, M interactive elements, K assets. Ready to build?"
    → Human approves → Step 4. Human says missing pages → back to Step 2/3.
    WHY: Three agents skipped extraction and started coding. This gate prevents it.

STEP 4: BUILD
  a. Scaffold: Next.js 16 + shadcn/ui + Geist
     Wire verify-extraction.sh as prebuild hook (blocks npm run build if specs/ incomplete):
     npm pkg set scripts.prebuild="bash ~/.claude/skills/website-genome/verify-extraction.sh specs/"
  b. Apply design tokens from specs/design-tokens.json
  c. Scan all extracted pages → identify shared components → build ONCE, reuse everywhere
  d. Build each page bottom-up: every text = from specs/, every image = downloaded asset
     GOLDEN RULE: Every pixel traces to observed data. Never invent content.
  e. Wire interactions: dropdowns, tabs, forms, modals

  PARALLEL BUILD RULE:
    Agents ONLY write files. Orchestrator ONLY runs npm run build.
    Never both. An orchestrator that also executes always cuts corners.

  Reference on demand: 04-components.md | 05-page-templates.md | 02-design-tokens.md
  Gate: npm run build && bash ~/.claude/skills/website-genome/verify-build.sh . <original-domain>
        → Exit 0: proceed to Step 5
        → Exit 1: fix what it reports before continuing

STEP 5: VERIFY → REFLECT → ACT (max 3 iterations)

  COMPONENT COMPARE FIRST (before page checks):
    Open original + replica side by side. Never evaluate replica alone.
    For each shared component: trigger on original → trigger on replica → compare:
    □ Same column layout?  □ Same section headers?  □ Same item count?
    □ Same background?  □ Same interactive behavior?
    Fix structural mismatches BEFORE continuing to page-level checks.

  DEPTH-FIRST PAGE WALK (dashboard/app pages):
    For EACH page: list EVERY clickable element → click each on original → does replica match?
    A page with 4 tabs × 3 buttons × 2 forms = 24 paths. Click all of them.
    RECURSIVE: if clicking reveals new elements, click those too.

  VERIFY CHECKLIST:
    □ npm run build passes (zero errors)
    □ Zero broken internal links
    □ Zero links to original domains (self-contained)
    □ Every nav item navigates correctly
    □ Every <img> = real downloaded file (zero placeholders)
    □ Every dropdown/tab/form works (click each, don't screenshot)
    □ Dashboard: every sidebar item → working page with real content
    □ Dashboard depth: every sub-tab, button, form within each page works
    □ Content: replica sections >= 60% of original's sections per page
    □ Production: npm run build && npx next start (not dev server)

  All pass? → DISPATCH FRESH VERIFIER (see below). Then EXIT with its report.
  Any fail? → REFLECT: what failed? why? what data is missing?
             → ACT: fix. May need to re-extract (Step 3).
             → VERIFY again.

  FRESH VERIFIER DISPATCH (after all checks pass — orchestrator must not self-verify):
    Agent(
      subagent_type="general-purpose",
      prompt=open("~/.claude/skills/website-genome/verifier-prompt.md").read()
             + f"\n\nOriginal: <original-url>\nReplica: <project-dir>\nChrome: running on port 9222"
    )
    WHY: An agent that built the site will miss its own mistakes. Fresh eyes catch what fatigue hides.

  NEVER declare done without the verifier's report.
  Report format: "Pages: N | Links: X checked, 0 broken | Images: M assets | Score: XX/100"
```

---

## §BUILD — Create a website from scratch

```
STEP 1: READ CHECKLIST
  Input: human-setup/project-checklist.md
  Extract: brand, type, features, pages, auth, database needs

STEP 2: GENERATE SPECS
  specs/prd.md      → template: genome/v1/18-prd-template.md
  specs/tech-rd.md  → template: genome/v1/19-tech-rd-template.md
  Gate: wc -l specs/prd.md specs/tech-rd.md  → both must be > 20 lines

STEP 3: SCAFFOLD
  npx create-next-app@16 <name> --typescript --tailwind --eslint --app --src-dir --turbopack
  npx shadcn@2 init -d
  npm install geist lucide-react
  + conditional deps from PRD (auth → @clerk/nextjs, db → drizzle-orm, etc.)
  Check genome/v1/VERSION.md for pinned versions before installing.
  Wire verify-build.sh as prebuild hook (blocks npm run build on broken builds):
  npm pkg set scripts.prebuild="bash ~/.claude/skills/website-genome/verify-build.sh ."
  git init && git add -A && git commit -m "chore: scaffold"
  gh repo create <name> --private --source=. --push

STEP 4: BUILD (each phase: Read ref → Do → Gate → Commit)

  Phase A: Design tokens + layouts
    Read: 02-design-tokens.md, 05-page-templates.md
    Do:   globals.css tokens, root layout, marketing/dashboard/auth layouts
    Gate: npm run dev 2>&1 | grep -i "error\|failed" | head -5  → must be empty
    Commit: "feat: scaffold + design tokens + layouts"

  Phase B: Public pages
    Read: 04-components.md, 06-page-types.md, 13-content-strategy.md
    Do:   landing, features, pricing, about, blog, docs, legal
    Gate: npm run build && bash ~/.claude/skills/website-genome/verify-build.sh .
          → check: zero broken links in public routes
    Commit: "feat: public pages"

  Phase C: Auth (skip if no auth)
    Read: 08-state-data.md §auth
    Do:   Clerk setup, proxy.ts, sign-in/up pages, ClerkProvider
    Gate: bb-browser open http://localhost:3000/sign-up → complete flow manually → confirm redirect to dashboard
    Commit: "feat: auth"

  Phase D: Dashboard (skip if no dashboard)
    Read: 06-page-types.md §dashboard
    Do:   overview, resource CRUD, settings, admin
    Gate: bash ~/.claude/skills/website-genome/verify-build.sh . → check dashboard routes all return 200
    Commit: "feat: dashboard"

  Phase E: Data layer (skip if no database)
    Read: 08-state-data.md §database
    Do:   schema, migrations, server actions, wire forms
    Gate: bb-browser create → read → update → delete one record → confirm in db
    Commit: "feat: database"

  Phase F: Interactions + state
    Read: 07-interactions.md
    Do:   button handlers, form submissions, modals, filters, loading states
    Gate: bb-browser: click every button/dropdown/form on 3 representative pages → confirm responses
    Commit: "feat: interactions"

  Phase G: Invisible layer + polish
    Read: 09-invisible-layer.md, 10-agent-browsable.md, 11-error-edge-cases.md, 12-responsive.md
    Do:   metadata per page, sitemap.ts, robots.ts, JSON-LD, a11y, CSP, rate limiting,
          loading.tsx + error.tsx + not-found.tsx, responsive at 375/768/1440px
    Gate: npx next start & sleep 3 && npx lighthouse http://localhost:3000 --output json --quiet \
          | python3 -c "import json,sys; d=json.load(sys.stdin); [print(k,round(v['score']*100)) for k,v in d['categories'].items()]"
          → all categories >= 90
    Commit: "feat: invisible layer + error handling + responsive"

  GATE FAILURE RULE: Fix before next phase. Blocked after 2 attempts → report to human.

STEP 5: VERIFY → REFLECT → ACT (same loop as §COPY Step 5)
  Use genome/v1/16-validation.md (90-point review). Target: >= 90% to ship.
```

---

## §FIX — Patch an existing replica

```
STEP 0: DASHBOARD FIRST (no exceptions)
  Before reading any handoff, before writing any code:
  → bb-browser open <dashboard-url> → capture full sidebar structure.
  This is Step 0 because "dashboard first" is the #1 persistent failure pattern.

STEP 1: READ HANDOFF
  Treat it as a hypothesis, not ground truth. Read the SOP sections it references.

STEP 2: OWN COMPARISON
  Navigate original + replica side by side. List EVERY difference with your own eyes.
  The handoff may be incomplete. Trust observation over documentation.

STEP 3: FIXES (priority order)
  P0: Broken links, missing pages, external links that should be internal
  P1: Layout/structure mismatches, wrong components
  P2: Content depth (missing sections)
  P3: Visual polish (images, spacing, icons)

STEP 4: VERIFY → REFLECT → ACT (same loop, same gates, no shortcuts)
```

---

## LAYER 3: QUALITY GATES — "Am I done?"

```
HARD GATES (any fail = not done):
  □ npm run build passes
  □ Zero broken internal links
  □ Zero links to original product domains (self-contained)
  □ Every nav item navigates correctly
  □ Dashboard: every sidebar item → real page (not placeholder)
  □ Logo + hero images = real downloaded files
  □ Every Submit button returns real data (not empty, not "coming soon")

SOFT GATES (target, gaps allowed):
  □ Every <img> = real asset (>= 80% of original's image count)
  □ Content depth >= 60% of original's sections per page
  □ Every dropdown/tab/form functional
  □ API responses match original format (proxy or mock)
  □ Responsive at 375px / 768px / 1440px
  □ Lighthouse >= 90 (all categories)

VERIFICATION RULES:
  Production build only: npm run build && npx next start (not dev server)
  Click every interactive element — never screenshot-verify behavior
  Report with numbers: "52 pages, 0 404s" not "looks good"
  NEVER declare done until VERIFY loop exits clean
```

---

## DELIVERY

```
git add -A && git commit && git push
Verify live Vercel URL (3-5 key pages).
Report: deployment URL + verification numbers.
```

---

## LAYER 4: REFERENCE — "How do I build this specific thing?"

```
Read ON DEMAND during build. Do NOT pre-load all files.

genome/v1/01-first-principles.md    — 8 website primitives, capability audit
genome/v1/02-design-tokens.md       — colors, typography, spacing, shadows, animations
genome/v1/03-atomic-elements.md     — 43 UI atoms (button, input, badge, avatar, etc.)
genome/v1/04-components.md          — 22 molecules + organisms (navbar, hero, pricing, etc.)
genome/v1/05-page-templates.md      — 10 layout skeletons (marketing, dashboard, auth, docs)
genome/v1/06-page-types.md          — page catalog by category + sitemap patterns
genome/v1/07-interactions.md        — click, hover, scroll, form, keyboard patterns
genome/v1/08-state-data.md          — UI state, URL state, server state, database patterns
genome/v1/09-invisible-layer.md     — SEO, accessibility, performance, security
genome/v1/10-agent-browsable.md     — data-agent-* attributes, JSON-LD, API mirroring
genome/v1/11-error-edge-cases.md    — loading, error, empty, offline states
genome/v1/12-responsive.md          — breakpoint specs, responsive component patterns
genome/v1/13-content-strategy.md    — text, images, icons, video sourcing
genome/v1/16-validation.md          — 90-point review checklist (for final review)
genome/v1/17-industry-research.md   — competitive landscape
genome/v1/18-prd-template.md        — PRD template (copy and fill)
genome/v1/19-tech-rd-template.md    — Tech RD template (copy and fill)
genome/v1/VERSION.md                — pinned dependency versions

WHEN TO READ:
  Building navbar?         → 04-components.md §4.11
  Choosing layout?         → 05-page-templates.md
  Wiring form validation?  → 07-interactions.md §7.4
  Adding SEO?              → 09-invisible-layer.md §9.1
  Final review?            → 16-validation.md
  Verify extraction gates? → verify-extraction.sh (blocks build if specs/ incomplete)
  Post-build review?       → verifier-prompt.md (fresh agent review prompt)
```

---

<!-- Genome OS v2.2 | 2026-04-14 | Validated: novada.com, iploop.io -->
