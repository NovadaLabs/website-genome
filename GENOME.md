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

STEP 2: DISCOVER ALL PAGES
  Use site-crawler (bulk) + bb-browser (auth-gated) to find every URL:
    site-crawler <url> --output specs/public --max-pages 200
    bb-browser: navigate sidebar, click every link, collect all paths
  Classify: INTERNAL (replicate) / PRODUCT-SUBDOMAIN (replicate) / EXTERNAL (keep)
  Auth-gated pages (dashboard) come FIRST — they are the product.
  Output: specs/sitemap.json
  Gate: total discovered >= what you see in navigation?

STEP 3: EXTRACT — The 8 Dimensions of a Complete Webpage

  REPLICATION QUALITY = EXTRACTION QUALITY.
  If you extract 100% of a page, replication is mechanical.
  If you extract 70%, you guess the other 30%, and the human catches it.
  Every failure in our history traces to incomplete extraction, not bad code.

  A webpage is made of exactly 8 things. For EVERY page in the sitemap,
  capture ALL 8. A page missing ANY dimension is an incomplete extraction.

  ┌─────────────────────────────────────────────────────────────────────┐
  │ DIM 1: STRUCTURE — the HTML DOM tree                              │
  │   bb-browser eval "document.documentElement.outerHTML"             │
  │   Save to: specs/html/<page-name>.html                            │
  │   Contains: every element, every attribute, every text node        │
  │   This is the PRIMARY source for rebuilding the page.              │
  ├─────────────────────────────────────────────────────────────────────┤
  │ DIM 2: STYLE — computed CSS for every element                     │
  │   site-crawler saves styles.css per page automatically             │
  │   Also extract design tokens (colors, fonts, spacing, radius):     │
  │     Colors: getComputedStyle → backgroundColor, color, borderColor │
  │     Fonts: getComputedStyle → fontFamily (+ download @font-face)   │
  │   Save to: specs/design-tokens.json + specs/css/<page-name>.css    │
  ├─────────────────────────────────────────────────────────────────────┤
  │ DIM 3: ASSETS — every file the page references                    │
  │   Images: all <img> src URLs → download to specs/assets/images/    │
  │   Fonts: all @font-face URLs → download to specs/assets/fonts/     │
  │   SVGs: all inline <svg> elements → save to specs/assets/svgs/     │
  │   Icons: all icon references → download or extract                 │
  │   Gate: 0 placeholder images. Every <img> = real downloaded file.  │
  ├─────────────────────────────────────────────────────────────────────┤
  │ DIM 4: CONTENT — every text string, verbatim                      │
  │   site-crawler saves page.md (clean Markdown) per page             │
  │   For blog posts: save FULL article HTML, don't summarize          │
  │   For data pages: save all visible numbers, labels, table data     │
  │   Rule: every text in the replica comes from extraction, not AI    │
  ├─────────────────────────────────────────────────────────────────────┤
  │ DIM 5: BEHAVIOR — what happens when you interact                  │
  │   For EVERY clickable element on EVERY page:                       │
  │     Click it. What happens? Record:                                │
  │     - Tab → content changes (capture each tab's content)           │
  │     - Button → API call / modal / navigation (capture result)      │
  │     - Dropdown → options list + what changes (capture each option) │
  │     - Hover → reveal / color change / tooltip (capture state)      │
  │     - Form → fields + validation + submit result (capture all)     │
  │   This is RECURSIVE: if clicking reveals new elements, click those │
  │   Save to: specs/interactions.json                                 │
  │   Gate: every clickable element documented with its result         │
  ├─────────────────────────────────────────────────────────────────────┤
  │ DIM 6: STATE — all possible states the page can be in             │
  │   Tabs: capture content for EVERY tab, not just the default        │
  │     → Click each tab. Screenshot. Save HTML. Record the URL.       │
  │     → Sub-tab URLs are often hidden until you click                │
  │       (e.g., /overview/res/ has tabs at /consume/, /account/, etc.)│
  │     → Save tab-urls.json mapping tab names to their actual URLs    │
  │   Dropdowns: capture ALL options and what each selection changes    │
  │   Forms: capture empty state, filled state, error state, success   │
  │   Auth: capture logged-in view + logged-out redirect               │
  │   Save to: specs/states/<page-name>/<state-name>.html              │
  │   Gate: number of states captured >= number of interactive elements │
  │                                                                     │
  │   SPA NOTE: React/Vue/Angular apps render inside a deep component  │
  │   tree. document.querySelector('main') may return empty.            │
  │   Use document.documentElement.outerHTML for the full page.         │
  │   Parse offline. Screenshots are the backup when HTML is unusable.  │
  ├─────────────────────────────────────────────────────────────────────┤
  │ DIM 7: NETWORK — every API call the page makes                    │
  │   Open DevTools Network tab or intercept via CDP                   │
  │   Interact with the page: click buttons, submit forms              │
  │   For each API call: URL, method, headers, request, response       │
  │   Save to: specs/apis.json                                        │
  │   Strategy per endpoint: PROXY (real API) / MOCK (saved response)  │
  │   Gate: every Submit button has a captured API endpoint             │
  ├─────────────────────────────────────────────────────────────────────┤
  │ DIM 8: METADATA — everything invisible but essential              │
  │   <title>, <meta description>, OG tags, JSON-LD                    │
  │   site-crawler saves metadata.json per page automatically          │
  │   Save to: specs/metadata/<page-name>.json                         │
  └─────────────────────────────────────────────────────────────────────┘

  SHARED COMPONENTS (navbar, footer, hero):
    These appear on EVERY page. Extract them separately as visual units:
    → Screenshot + outerHTML + structure (columns, items, sub-links)
    → Navbar dropdowns: hover each → capture each dropdown state
    → Save to: specs/components/

  COMPLETENESS CHECK (after extracting a page):
    □ HTML saved?  □ CSS saved?  □ Assets downloaded?  □ Content captured?
    □ Every click documented?  □ All states visited?  □ APIs intercepted?  □ Metadata saved?
    If ANY box is unchecked → the page extraction is INCOMPLETE.
    Incomplete extraction → incomplete replica → human catches it → wasted time.

  TOOLS:
    site-crawler: bulk extraction (HTML, CSS, Markdown, screenshots, assets per page)
    bb-browser: interactive extraction (hover, click, forms, auth-gated pages)
    Use BOTH: site-crawler for the static 8 dimensions, bb-browser for behavior + state.

  OUTPUT: specs/ folder with all 8 dimensions for every page.
  GATE: NO CODE UNTIL SPECS ARE COMPLETE. The specs ARE the product of extraction.

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

  SHARED COMPONENT DETECTION (before building pages):
    Scan all extracted sub-tabs. If multiple pages share identical layouts
    (e.g., Analytics tab looks the same across 5 products), build ONE shared
    component and reuse it. This prevents 5 copies of the same pricing page.

  PARALLEL BUILD RULE:
    If dispatching multiple agents to build pages in parallel:
    → Agents ONLY write files. They do NOT run npm run build.
    → Only the orchestrator runs npm run build (prevents race conditions).
    → An orchestrator that also executes will always cut corners.
      After hours of strategic work, the instinct is to "just get it done."
      Fresh agents don't have this fatigue — dispatch them for execution.

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

## PRINCIPLES

```
THE CORE TRUTH:
  Replication quality = extraction quality. Period.
  If you extract 100% of a page's data, replication is mechanical.
  If you extract 70%, you guess 30%, and the human catches it every time.
  Every failure traces to incomplete extraction, not bad code.

1. EXTRACTION IS THE PRODUCT
   The specs/ folder is what matters, not the code. Code is assembly.
   Spend 70% of time on extraction, 30% on build.
   A complete extraction makes build trivial. An incomplete one makes it impossible.

2. 8 DIMENSIONS, ALL REQUIRED
   Structure + Style + Assets + Content + Behavior + State + Network + Metadata.
   A page missing ANY dimension is incomplete. Check the 8-box list for every page.

3. RECURSIVE DEPTH
   For every page: click every clickable element. For every result: repeat.
   A page with 4 tabs × 3 buttons × 2 forms = 24 paths to capture, not 1.
   "I visited the page" ≠ "I explored all its states."

4. DASHBOARD FIRST
   Auth-gated pages are the product. Marketing pages are the wrapper.
   Extract the dashboard BEFORE marketing pages — it has the most depth.

5. COMPARE BOTH SITES, ALWAYS
   Never evaluate the replica alone. Open original + replica side by side.
   For every element: trigger on original → trigger on replica → match?

6. QUALITY SYSTEM, NOT CHECKLIST
   "I did something" ≠ "I did it completely."
   Agents optimize for gate-passing, not quality. Fight this instinct.
   For each step: is the artifact COMPLETE across all 8 dimensions?

7. VERIFY WITH PRODUCTION BUILD
   npm run build && npx next start. Dev server is unreliable.
   Click every interactive element. Report with numbers, not feelings.
```

---

<!-- Genome OS v2.1 | Created: 2026-04-01 | Validated: iploop.io | Old genome: genome/v1/ -->
