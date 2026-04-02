# Website Genome OS v2.1

> Single-file agent operating system for building or replicating any website.
> Old genome (24 files) → `genome/v1/` as reference library.
> This file IS the process. Reference files are pulled on demand.
>
> HOW TO READ THIS: Every line exists because an agent failed without it.
> This is a QUALITY SYSTEM, not a checklist. "I did something" ≠ "I did it completely."
> For each step: did you produce the EXACT artifact specified? Is it COMPLETE?
> If you catch yourself thinking "close enough, moving on" — you are failing.

---

## STEP 0: PREREQUISITES + CHROME (BLOCKING — before anything else)

```
PREREQUISITES: See README.md for full list. Human must have installed tools and set up accounts.

CHROME (the only human step per site):
  The human's Chrome must be running with their login sessions accessible.
  Without this, auth-gated extraction is impossible.

  Human runs: cd ~/Projects/novada-replicate && npm run launch-chrome
  This launches Chrome on port 9222 with the user's cookies.

  Agent verifies: bb-browser open <any-url> — does it work?
  → YES → proceed to LAYER 0
  → NO  → STOP. Tell human: "Please run: cd ~/Projects/novada-replicate && npm run launch-chrome"
           Do not proceed until Chrome is confirmed running.

  bb-browser connects to this Chrome instance. Without it, bb-browser has no auth sessions.

  MULTI-AGENT RULE: Each agent opens its OWN TAB. Never share tabs.
    bb-browser open <url> always opens a new tab. Use it. Close when done.
```

---

## LAYER 0: MISSION — "What am I doing?"

```
READ THIS → DECIDE → GO TO THE RIGHT PIPELINE

┌─────────────────────────────────────────────┐
│  INPUT: URL, project checklist, or handoff  │
│                                             │
│  Is there an existing replica to fix?       │
│  ├── YES → FIX mode → go to §FIX           │
│  └── NO                                     │
│       Is there a URL to replicate?          │
│       ├── YES → COPY mode → go to §COPY    │
│       └── NO  → BUILD mode → go to §BUILD  │
└─────────────────────────────────────────────┘

QUESTION POLICY:
  Ask ONLY when: checklist is ambiguous AND decision is irreversible
    (architecture, auth provider, data model)
  Default silently for: colors, spacing, copy, icons
  When torn between two options: pick the simpler one, document the choice

SCALING:
  Simple site (< 10 pages): single agent, this file, fully autonomous
  Complex site (10-50 pages): single agent, careful phase commits
  Large site (50+ pages): orchestrator + fresh executor agents

  ORCHESTRATOR PROTOCOL (for large sites):
    The orchestrator reads the genome and PLANS. Fresh agents EXECUTE.
    Why: a single agent accumulates context bias. After extraction it "knows" the site
    and gets sloppy during build — exactly what happened on iploop.io.

    Orchestrator:
      1. Reads genome + runs Steps 1-3 (CONNECT, CRAWL, EXTRACT)
      2. Generates specs/ folder
      3. Dispatches fresh executor agents per build phase
      4. Reviews each phase output (or delegates to review agent)
    Executor (fresh, zero context):
      1. Reads specs/ folder + genome §BUILD or §FIX
      2. Builds assigned phase
      3. Commits + pushes
    Handoff = git repo state + specs/ folder. No context carries over.
```

---

## LAYER 1: TOOLS — "What do I have?"

```
EXTRACTION (for COPY/FIX mode):
  1. bb-browser        PRIMARY — interactive extraction (hover, click, login pages)
     open <url> | snapshot -i | eval "js" | click @ref | hover @ref | close
     Best for: dropdowns, tabs, modals, auth-gated pages, component capture
  2. site-crawler      BULK — automated crawl + extraction (100+ pages in one command)
     site-crawler <url> --output specs/ --max-pages 200
     Best for: crawling entire sites, downloading all assets, generating manifest
     Output: per-page HTML + CSS + Markdown + screenshot + metadata + _assets/
     Repo: NovadaLabs/site-crawler | Install: pip install -e .
  3. Chrome CDP        BACKUP — programmatic batch extraction
  4. Chrome DevTools    BACKUP — quick checks, separate profile
  5. Playwright         BACKUP — public pages only, headless
  6. gstack            QA — responsive testing at 375/768/1440

TOOL SELECTION:
  Crawl 100+ pages automatically?     → site-crawler (Step 2)
  Capture dropdowns/tabs/modals?      → bb-browser (Step 3-COMPONENTS)
  Auth-gated dashboard pages?         → bb-browser (needs user's Chrome)
  Download all images/fonts/CSS?      → site-crawler (automated)
  Responsive QA testing?              → gstack

BUILD:
  Next.js 16 + shadcn/ui + Tailwind 4 + Geist + Vercel
  → versions pinned in genome/v1/VERSION.md

RULE: AI needs structured data (HTML, a11y tree, CSS), NOT screenshots.
RULE: Auth-gated pages → bb-browser (user's Chrome). Never a fresh browser.
RULE: Screenshots are for human QA only — never the primary extraction artifact.

SUB-AGENT PROTOCOL:
  If dispatching parallel agents to build pages:
    → Send 1 agent as a canary first. Verify it completes successfully.
    → Only then dispatch the rest in batches of 2-3.
    → If agents hit limits or fail: fall back to sequential. Don't block on broken parallelism.
```

---

## §COPY — Replicate a website from URL

```
STEP 1: CONNECT
  Action: bb-browser open <target-url>
  Gate:   Can you see the page? Auth-gated pages accessible?
          → If not: ask human to log in, then retry

STEP 2: CRAWL + BULK EXTRACT
  OPTION A — site-crawler (recommended for 10+ pages):
    site-crawler <url> --output specs/public --max-pages 200
    → Automatically crawls all pages, downloads per-page: HTML, CSS, Markdown, screenshot, metadata
    → Downloads all assets to specs/public/_assets/ (images, fonts, CSS, JS)
    → Generates manifest.json (structured sitemap)
    → For auth-gated pages: site-crawler <url> --browser-profile ./profile --output specs/dashboard

  OPTION B — bb-browser (for small sites or when site-crawler unavailable):
    bb-browser eval "[...document.querySelectorAll('a[href]')].map(a=>a.href)"
    Classify: INTERNAL (replicate) / PRODUCT-SUBDOMAIN (replicate) / EXTERNAL (keep)

  Output: specs/sitemap.json (or specs/public/manifest.json from site-crawler)
  Gate:   Total URLs discovered >= what you see in the navigation?

STEP 3: INTERACTIVE EXTRACT — what site-crawler misses
  site-crawler captures static page state. This step captures what it can't:
  hover states, dropdowns, tabs, modals, form states.

  For each page with interactive elements:
    a. bb-browser open <url>
       → Scroll full page before capturing (modern sites lazy-load below-fold content)
       → bb-browser eval "window.scrollTo(0, document.body.scrollHeight)" then wait 1s
    b. bb-browser snapshot -i → a11y tree (structure, roles, text)
    c. bb-browser screenshot → save to specs/screenshots/<page-name>.png (if not already from site-crawler)
    d. bb-browser eval "document.documentElement.outerHTML" → save to specs/html/<page-name>.html (if not already)
    e. bb-browser eval "<css-extraction-script>" → design tokens
    f. For interactive elements: hover/click → capture changed state
    g. Extract @font-face rules → download font files to specs/assets/fonts/
       → If fonts are custom/proprietary and unavailable, document the substitution

  If site-crawler already ran: focus this step ONLY on interactive captures (dropdowns, tabs, modals).
  The static HTML/CSS/assets are already in specs/public/.

  For sites with many blog posts:
    → Extract titles/dates/images for listing page
    → Save full HTML per post (building blog content from scratch is unreliable)

  Output: specs/design-tokens.json, specs/interactions.json, specs/assets-needed.json
  Gate:   Do spec files exist? Are assets downloaded?
          → NO SPEC FILES = NO CODE. This is the extraction product, not overhead.

  SPEC FILE SHAPES:
    specs/sitemap.json:        [{ path, template, auth, sub_tabs? }]
    specs/design-tokens.json:  { colors: { primary, bg, fg, ... }, fonts: { sans, mono }, spacing: { base: 4 }, radius: "0.5rem" }
    specs/interactions.json:   [{ element, trigger, action, target }]
    specs/assets-needed.json:  { images: [{ name, src, used_on }], fonts: [...], icons: [...] }

  CSS EXTRACTION SCRIPTS (for step 3d):
    Colors: bb-browser eval "(() => { const s=new Set(); document.querySelectorAll('*').forEach(e=>{const c=getComputedStyle(e);[c.backgroundColor,c.color,c.borderColor].forEach(v=>s.add(v))});return[...s].filter(c=>c!='rgba(0, 0, 0, 0)')})()"
    Fonts:  bb-browser eval "(() => { const s=new Set(); document.querySelectorAll('*').forEach(e=>s.add(getComputedStyle(e).fontFamily));return[...s]})()"
    Links:  bb-browser eval "[...new Set([...document.querySelectorAll('a[href]')].map(a=>a.href).filter(h=>h.startsWith(location.origin)).map(h=>new URL(h).pathname))].sort()"

  DASHBOARD RULE (if auth-gated pages exist):
    This is STEP 3, not STEP 10. Explore dashboard FIRST.
    → Click EVERY sidebar item → capture each sub-page
    → Click EVERY tab within each page → capture each tab
    → Count: sidebar items = N → you need N routes in the replica
    Three agents skipped this. Don't be the fourth.

STEP 3-COMPONENTS: SHARED COMPONENT EXTRACTION
  Shared components appear on EVERY page. Getting them wrong = every page is wrong.
  Extract them as COMPLETE VISUAL UNITS, not just link lists.

  NAVBAR:
    For each top-level nav item that has a dropdown:
      a. Hover the item → wait for dropdown to fully appear
      b. Screenshot the dropdown → specs/screenshots/nav-{item-name}.png
      c. Extract dropdown outerHTML → specs/components/nav-{item-name}.html
      d. Record structure:
         - Column count, section headers (exact text), items per section
         - Item structure: icon + title + subtitle + badge + sub-links
         - Background color, positioning (full-width vs floating)
      e. Save to specs/nav-structure.json

  FOOTER:
    a. Screenshot → specs/screenshots/footer.png
    b. Extract outerHTML → specs/components/footer.html
    c. Record: column count, section titles, link count per section

  HERO (homepage):
    a. Screenshot → specs/screenshots/hero.png
    b. Extract outerHTML → specs/components/hero.html
    c. Record: background, headline, subtitle, CTAs, trust badges

  RULE: A mega-menu is a COMPONENT, not a link list.
  Extract it as you would extract a page section — with HTML, screenshot, and structure.
  Output: specs/nav-structure.json, specs/components/

  Gate: Do component HTML files + screenshots + structure JSON all exist?

STEP 3-APIS: API ENDPOINT EXTRACTION
  A replica with dead APIs is a wireframe, not a product. For SaaS dashboards,
  the API IS the product. This step captures what makes the dashboard WORK.

  For each dashboard/app page:
    1. Open browser DevTools Network tab (or intercept via bb-browser/CDP)
    2. Interact: click submit buttons, change dropdowns, submit forms
    3. For each API call observed:
       - URL, method, headers, request body
       - Response status + body (sample)
       - Which UI element triggered it
    4. Save to specs/apis.json:
       [{ page: "/dashboard/scraper-api", trigger: "Submit Request",
          endpoint: "https://scraperapi.novada.com/search", method: "GET",
          params: ["engine", "q", "api_key"], response_sample: {...} }]
    5. Decide replication strategy per endpoint:
       - PROXY: create /api/ route that calls the real API (needs key)
       - MOCK: return captured response for offline demos
       - SKIP: not essential (analytics, tracking)

  Gate: specs/apis.json exists with at least one endpoint per dashboard page?
  A dashboard page with a "Submit" button that does nothing = extraction failure.

STEP 3.5: HUMAN GATE (conditional)
  Simple site (< 15 pages, no auth-gated areas):
    → SKIP this step. Proceed to Step 4 autonomously.
    → The spec files themselves are the quality gate.

  Complex site (15+ pages, OR has auth-gated dashboard):
    → Show the human: page count, route list, interactive states found, assets downloaded.
    → "I found N pages, M interactive elements, downloaded K assets. Ready to build?"
    → If human says pages are missing → go back to Step 2 or 3.
    → If human approves → proceed to Step 4.

  This gate exists because three agents skipped extraction and started coding.
  For complex sites, a self-check alone doesn't prevent that.

STEP 4: BUILD
  a. Scaffold: Next.js 16 + shadcn/ui + Geist
  b. Apply extracted design tokens (colors, fonts, spacing)
  c. Build layouts (marketing + dashboard + auth)
  d. Build pages bottom-up: for each page in sitemap →
     → Read its extracted HTML + structure
     → Build the component from EXTRACTED DATA, not imagination
     → Every text string = from extraction. Every image = downloaded asset.
  e. Wire interactions (dropdowns, tabs, forms, modals)

  GOLDEN RULE: Every pixel traces to observed data. Never invent content.

  Reference (read on demand during build):
    → genome/v1/04-components.md — molecule/organism patterns
    → genome/v1/05-page-templates.md — layout skeletons
    → genome/v1/02-design-tokens.md — token implementation

  Gate: npm run build passes? Every page renders?

STEP 5: VERIFY → REFLECT → ACT (loop, max 3 iterations)

  COMPONENT COMPARISON (do this FIRST — before route checks):
    Open BOTH original and replica simultaneously. Never evaluate replica alone.
    For each shared component (navbar dropdowns, footer, hero):
      1. Trigger the component on ORIGINAL → screenshot
      2. Trigger same component on REPLICA → screenshot
      3. Compare:
         □ Same column layout?
         □ Same section headers (exact text)?
         □ Same item count per section?
         □ Same background color / gradient?
         □ Same positioning (full-width vs floating)?
         □ Same interactive behavior (hover state, animation)?
      4. If ANY structural mismatch → fix BEFORE continuing to page-level verify
    WHY: Shared components affect every page. A broken navbar = 100 wrong pages.

  DEPTH-FIRST PAGE WALK (for dashboard/app pages — do this BEFORE the checklist):
    For EACH page in the sidebar, open it on the ORIGINAL site:
      1. List EVERY clickable element: tabs, buttons, links, dropdowns, forms
      2. Click/interact with EACH one on the ORIGINAL:
         - Tab → capture each tab's content
         - Button → what does it do? API call? Modal? Navigate?
         - Form → what fields? What happens on submit?
         - Dropdown → what options? Does selecting change content?
      3. Now do the SAME on the REPLICA — does each element behave identically?
      4. If clicking reveals NEW elements (sub-tabs, nested forms), repeat recursively
      5. Only mark this page "complete" when ALL clickable paths match at ALL depths
    This is RECURSIVE. Don't stop at the first level.
    A page with 4 tabs × 3 buttons × 2 forms = 24 paths to verify, not 1.

  VERIFY (run all checks):
    □ npm run build passes (zero errors)
    □ Every internal link resolves (zero 404s)
    □ Every <img> src = real downloaded file (zero placeholders)
    □ Every nav item navigates to correct page
    □ Every dropdown/tab/form works (click each, don't just look)
    □ Dashboard sidebar: every item → working page with content
    □ Dashboard depth: every sub-tab, form, button within each page works
    □ Content: replica sections >= 60% of original's sections per page
    □ Self-contained: zero links to original product domains
    □ Production server: npx next start (not dev server for verification)

  → All pass? EXIT → report to human with numbers
  → Any fail? ↓

  REFLECT:
    List each failure. For each:
      What failed? Why? What data am I missing?
    Prioritize: broken > missing > cosmetic

  ACT:
    Fix each failure. May need to go back to EXTRACT (step 3) for missing data.
    Then → back to VERIFY

  EXIT after: all gates pass OR 3 iterations completed
  NEVER declare done without passing VERIFY.

  Report format:
    Pages: N built | Links: X checked, 0 broken | Images: M real assets
    Dashboard: N/N sidebar items working | Score: XX/100
    Remaining gaps: [list honestly]
```

---

## §BUILD — Create a website from scratch

```
STEP 1: READ CHECKLIST
  Input: human-setup/project-checklist.md
  Extract: brand, website type, features, pages needed, auth, database

STEP 2: GENERATE SPECS
  a. Fill specs/prd.md (from genome/v1/18-prd-template.md)
  b. Fill specs/tech-rd.md (from genome/v1/19-tech-rd-template.md)
  Gate: PRD + Tech RD exist with real content, not placeholders?

STEP 3: SCAFFOLD
  npx create-next-app@16 <name> --typescript --tailwind --eslint --app --src-dir --turbopack
  npx shadcn@2 init -d
  npm install geist lucide-react
  + conditional deps from PRD (auth → @clerk/nextjs, db → drizzle-orm, etc.)
  → Check genome/v1/VERSION.md for all pinned versions before installing

  git init && git add -A && git commit -m "chore: scaffold"
  gh repo create <name> --private --source=. --push

STEP 4: BUILD (phase by phase)

  Phase A: Design tokens + layouts
    Read: genome/v1/02-design-tokens.md, 05-page-templates.md
    Do:   globals.css tokens, root layout, marketing layout, dashboard layout, auth layout
    Out:  app/layout.tsx, app/(marketing)/layout.tsx, app/(dashboard)/layout.tsx
    Gate: npm run dev renders empty layouts without errors
    Commit: "feat: scaffold + design tokens + layouts"

  Phase B: Public pages
    Read: genome/v1/04-components.md, 06-page-types.md, 13-content-strategy.md
    Do:   landing, features, pricing, about, blog, docs, legal pages
    Out:  page.tsx files under (marketing) route group
    Gate: every public page renders, internal links work
    Commit: "feat: public pages"

  Phase C: Auth (skip if no auth needed)
    Read: genome/v1/08-state-data.md §auth
    Do:   Clerk setup, proxy.ts, sign-in/sign-up pages, ClerkProvider
    Out:  proxy.ts, app/(auth)/ pages, env vars configured
    Gate: can sign up → sign in → see dashboard redirect → sign out
    Commit: "feat: auth with Clerk"

  Phase D: App pages (skip if no dashboard needed)
    Read: genome/v1/06-page-types.md §dashboard
    Do:   dashboard overview, resource CRUD, settings, admin
    Out:  app/(dashboard)/ pages
    Gate: sidebar navigation works, every route shows content
    Commit: "feat: dashboard and app pages"

  Phase E: Data layer (skip if no database needed)
    Read: genome/v1/08-state-data.md §database
    Do:   schema, migrations, server actions, wire to forms
    Out:  db/schema.ts, db/index.ts, server actions
    Gate: CRUD persists data end-to-end
    Commit: "feat: database and server actions"

  Phase F: Interactions + state
    Read: genome/v1/07-interactions.md
    Do:   all button handlers, form submissions, modals, filters, search, loading states
    Gate: every interactive element responds correctly
    Commit: "feat: wire interactions"

  Phase G: Invisible layer
    Read: genome/v1/09-invisible-layer.md
    Do:   metadata per page, sitemap.ts, robots.ts, JSON-LD, a11y, CSP, rate limiting
    Gate: Lighthouse all categories >= 90
    Commit: "feat: SEO + a11y + security"

  Phase G.5: Agent-browsable layer
    Read: genome/v1/10-agent-browsable.md
    Do:   data-agent-* attributes on interactive elements, JSON-LD structured data,
          API discovery endpoint (/api), API endpoints mirroring page data
    Gate: accessibility tree meaningful, status conveyed via text not just color
    Commit: "feat: agent-browsable layer"

  Phase G.6: Error + edge cases
    Read: genome/v1/11-error-edge-cases.md
    Do:   loading.tsx per route group, error.tsx, not-found.tsx, global-error.tsx,
          empty states for lists/tables, form validation errors, network error handling
    Gate: no unhandled errors, graceful degradation on empty data
    Commit: "feat: error handling and edge cases"

  Phase H: Responsive pass
    Read: genome/v1/12-responsive.md
    Do:   verify at 375px, 768px, 1440px; fix overflow, mobile nav, table scroll
    Gate: no horizontal scrollbar, all pages usable on mobile
    Commit: "fix: responsive adjustments"

  GATE FAILURE RULE (all phases):
    Gate fails → fix before proceeding to next phase.
    Blocked after 2 attempts → report to human with what's failing and why.

STEP 5: VERIFY → REFLECT → ACT (same loop as §COPY step 5)
  Use checklist from genome/v1/16-validation.md (90-point review)
  Target: >= 90% to ship
```

---

## §FIX — Patch an existing replica

```
STEP 0: DASHBOARD FIRST
  Before reading any handoff, before writing any code:
  → Infer dashboard URL from the project's existing routes or original site domain
    (e.g., dashboard.example.com, or /dashboard in the replica)
  → bb-browser open <dashboard-url>
  → Is the dashboard accessible? Capture FULL sidebar structure NOW.
  → See §COPY Step 3 DASHBOARD RULE for full capture protocol.
  This is Step 0 because it's the #1 persistent failure.

STEP 1: READ HANDOFF + REFERENCED SOPs
  The handoff is a HYPOTHESIS. Read the actual SOP sections it points to.

STEP 2: OWN COMPARISON
  Navigate original + replica side-by-side. List EVERY difference.
  The handoff may be incomplete — trust your own eyes over the handoff.

STEP 3: EXECUTE FIXES (priority order)
  P0: Broken links, missing pages, external links that should be internal
  P1: Layout/structure mismatches, wrong components
  P2: Content depth (missing sections)
  P3: Visual polish (images, icons, spacing)

STEP 4: VERIFY → REFLECT → ACT (same loop, same gates)
  No shortcuts. Fix-forward runs ALL exit criteria.
```

---

## LAYER 3: QUALITY GATES — "Am I done?"

```
HARD GATES (any fail = not done):
  □ npm run build passes
  □ Zero broken internal links
  □ Zero links to original product domains (self-contained)
  □ Every nav item navigates correctly
  □ Dashboard sidebar: every item → real page (not placeholder)
  □ Logo and hero images are real downloaded files (not text placeholders)
  □ Dashboard API gate: every "Submit" button returns real data (not empty, not "coming soon")

SOFT GATES (target, may have gaps):
  □ Every <img> = real asset (target: >= 80% of original's image count)
  □ Content depth: >= 60% of original's sections per page
  □ Every dropdown/tab/form functional
  □ API responses match original format (proxy or mock)
  □ Responsive at 375px + 768px + 1440px
  □ Lighthouse >= 90 (all categories)

VERIFICATION RULES:
  → Use production build (npm run build && npx next start), not dev server
  → Click every interactive element, don't just screenshot
  → Report with numbers, not feelings ("52 pages, 0 404s" not "looks good")
  → NEVER declare done until VERIFY loop exits clean
```

---

## DELIVERY — "Ship it"

```
After VERIFY passes:
  git add -A && git commit && git push
  Verify live Vercel URL loads (3-5 key pages)
  Report: deployment URL + verification numbers
```

---

## LAYER 4: REFERENCE — "How do I build this specific thing?"

```
Read ON DEMAND during build. Do NOT pre-load.

genome/v1/01-first-principles.md    — 8 website primitives, capability audit
genome/v1/02-design-tokens.md       — colors, typography, spacing, shadows, animations
genome/v1/03-atomic-elements.md     — 43 UI atoms (button, input, badge, etc.)
genome/v1/04-components.md          — 22 molecules + organisms (navbar, hero, pricing, etc.)
genome/v1/05-page-templates.md      — 10 layout skeletons (marketing, dashboard, auth, docs, etc.)
genome/v1/06-page-types.md          — page catalog by category + sitemap patterns
genome/v1/07-interactions.md        — click, hover, focus, scroll, form, keyboard patterns
genome/v1/08-state-data.md          — UI state, URL state, server state, database patterns
genome/v1/09-invisible-layer.md     — SEO, accessibility, performance, security
genome/v1/10-agent-browsable.md     — data-agent-* attributes, JSON-LD, API mirroring
genome/v1/11-error-edge-cases.md    — loading, error, empty, offline states
genome/v1/12-responsive.md          — breakpoint specs, component responsive patterns
genome/v1/13-content-strategy.md    — text, images, icons, video sourcing
genome/v1/16-validation.md          — 90-point review checklist (for review agent)
genome/v1/17-industry-research.md   — competitive landscape
genome/v1/18-prd-template.md        — PRD template (copy and fill)
genome/v1/19-tech-rd-template.md    — Tech RD template (copy and fill)
genome/v1/VERSION.md                — pinned dependency versions

WHEN TO READ:
  Building a navbar? → 04-components.md §4.11
  Choosing a layout? → 05-page-templates.md
  Wiring form validation? → 07-interactions.md §7.4
  Adding SEO? → 09-invisible-layer.md §9.1
  Need the validation checklist? → 16-validation.md
```

---

## PRINCIPLES (burned into this OS from 3 failed replications)

```
1. EXTRACT > IMAGINE
   Every pixel traces to observed data. Agent creativity is the enemy in COPY mode.

2. SPECS BEFORE CODE
   No React until sitemap.json + design-tokens.json + interactions.json exist.

3. DASHBOARD FIRST
   Auth-gated pages are the product. Marketing pages are the wrapper.
   → See §COPY Step 3 DASHBOARD RULE for the full protocol.

4. ASSETS > CODE
   Downloading 61 real images was the single biggest quality jump.
   Replace code-level placeholders with real downloaded files.

5. VERIFY THEN REPORT
   Run the full gate checklist. Fix failures. Only then tell the human.
   "52 pages, 0 broken links, all dropdowns verified" — not "looks good."

6. CLICK, DON'T SCREENSHOT
   Screenshots test rendering. Clicking tests behavior.
   A dashboard that looks right in a screenshot but has broken nav = failure.

7. PRODUCTION BUILD FOR VERIFICATION
   npm run build && npx next start. Dev server is unreliable for QA.

8. QUALITY SYSTEM, NOT CHECKLIST
   "I extracted something" ≠ "I extracted everything the step specifies."
   For each step: did you produce the EXACT artifact? Is it COMPLETE?
   Every line in this file exists because an agent failed without it.
   If you're thinking "close enough, moving on" — you are failing.

9. MEGA-MENUS ARE COMPONENTS, NOT LINK LISTS
   A dropdown with 3 columns, section headers, icons, and sub-links
   cannot be reconstructed from a flat list of URLs.
   Extract the dropdown's outerHTML, screenshot, and structure.
   The navbar appears on EVERY page — getting it wrong multiplies across the entire replica.

10. COMPARE BOTH SITES FOR EVERY CHECK
    Never evaluate the replica in isolation. Open original and replica side by side.
    For each component: trigger on original → trigger on replica → compare.
    "All 108 routes return 200" is a function check, not an appearance check.
    You need BOTH to pass before declaring done.

11. A REPLICA WITH DEAD APIS IS A WIREFRAME
    For SaaS products, the API IS the product. A dashboard that looks right but
    where buttons do nothing is NOT a replica — it's a screenshot.
    Capture API endpoints during extraction (Step 3-APIS).
    Wire proxy routes during build. Verify every Submit button returns real data.

12. VERIFY TO DEPTH, NOT BREADTH
    "Dashboard has 11 pages" is breadth. "Each page's tabs, forms, buttons, and
    sub-states all work identically to the original" is depth.
    Agents consistently pass gates at the shallowest level. This principle says:
    for every page, click every clickable element. For every sub-state, repeat.
    Stop only when there are no more unvisited clickable paths.
```

---

<!-- Genome OS v2.1 | Created: 2026-04-01 | Validated: iploop.io | Old genome: genome/v1/ -->
