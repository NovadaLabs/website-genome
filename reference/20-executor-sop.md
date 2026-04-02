# 20 — Executor SOP (Master Execution Guide)

## READ THIS FIRST

```spec
YOU ARE AN EXECUTOR AGENT.
You are building a website from scratch, or replicating one from a URL.
This is the ONLY file you need to start. It references all others.

QUESTION POLICY:
  Minimize questions. Only ask the human when:
    1. The checklist is genuinely ambiguous, AND
    2. The decision has irreversible consequences (architecture, auth provider, data model)
  Never ask about: colors, spacing, copy, icons — use defaults.
  When in doubt between two reasonable options: pick the simpler one, document the choice.

CONTEXT MANAGEMENT:
  ⚠️ Do NOT read all genome files upfront. Read ONLY what you need per phase.
  See: 00-index.md → PROGRESSIVE LOADING PROTOCOL

YOUR DELIVERABLE:
  A production-ready website, committed to GitHub, deployed on Vercel.
  The human should be able to visit the URL and see a working site.
```

---

## QUICK START (5 minutes to first page)

```spec
STEP 0: Read the human's project-checklist.md
  Location: human-setup/project-checklist.md (filled by human)
  Extract: brand name, website type, features, env vars, repo info

STEP 1: Scaffold
  npx create-next-app@latest [project-name] --typescript --tailwind --eslint --app --src-dir --turbopack --import-alias "@/*"
  cd [project-name]
  npx shadcn@latest init -d
  npm install geist lucide-react

STEP 2: Install conditional deps (based on checklist)
  If auth:     npm install @clerk/nextjs
  If database: npm install drizzle-orm @neondatabase/serverless && npm install -D drizzle-kit
  If forms:    npm install react-hook-form @hookform/resolvers zod
  If theme:    npm install next-themes
  If charts:   npm install recharts
  If tables:   npm install @tanstack/react-table
  If dates:    npm install date-fns
  If AI:       npm install ai @ai-sdk/react

STEP 3: Configure design tokens
  → Read: 02-design-tokens.md
  → Update globals.css with brand colors (or use defaults)
  → Set up fonts in app/layout.tsx

STEP 4: Install shadcn components
  npx shadcn@latest add button input label textarea select checkbox radio-group switch slider badge avatar separator skeleton progress scroll-area tooltip dialog alert-dialog sheet popover dropdown-menu tabs accordion card alert breadcrumb pagination command navigation-menu form sonner sidebar collapsible aspect-ratio

STEP 5: Build the first page (landing page)
  → Read: 04-components.md for organism patterns
  → Read: 05-page-templates.md for layout
  → Build app/(marketing)/layout.tsx + page.tsx

STEP 6: Git init + push
  git init && git add -A && git commit -m "feat: scaffold with Next.js 16 + shadcn/ui"
  [use human's repo or create new one]
  git push -u origin main

STEP 7: Connect Vercel
  vercel link
  vercel env pull
  vercel deploy

→ At this point you should have a live URL with a landing page.
→ Continue building the rest of the site below.
```

---

## FULL EXECUTION SEQUENCE

```spec
PHASE 1: SCAFFOLD + TOKENS (Steps 0-3 above)
  Time: ~10 minutes
  Output: Empty project with design system configured
  Gate: `npm run dev` shows default page without errors

PHASE 2: LAYOUTS + SHARED COMPONENTS
  → Read: 05-page-templates.md
  → Read: 04-components.md

  Build in order:
    a. Root layout (app/layout.tsx): providers, fonts, theme, analytics
    b. Marketing layout: Navbar + Footer
    c. Auth layout: centered card (if auth needed)
    d. Dashboard layout: Sidebar + TopBar (if app pages needed)
    e. Shared components: SearchBar, UserMenu, EmptyState, etc.

  Gate: All layouts render without errors
  Commit: "feat: add layouts and shared components"

PHASE 3: PUBLIC PAGES
  → Read: 06-page-types.md for page specs
  → Read: 13-content-strategy.md for content generation

  Build in order:
    a. Landing page (/) — Hero + Features + Testimonials + CTA + FAQ
    b. Pricing page (/pricing) — if applicable
    c. About page (/about) — if applicable
    d. Blog pages — if applicable
    e. Docs pages — if applicable
    f. Legal pages (/privacy, /terms) — use template markers

  Gate: All public pages render, internal links work
  Commit: "feat: add public pages"

PHASE 4: AUTH PAGES (if auth required)
  → Read: 08-state-data.md#auth-data-flow

  Build:
    a. Sign-in page (/sign-in or /login)
    b. Sign-up page (/sign-up or /signup)
    c. Proxy/middleware (src/proxy.ts)
    d. ClerkProvider in root layout

  Gate: Can sign up, sign in, and see dashboard redirect
  Commit: "feat: add auth with Clerk"

PHASE 5: APP PAGES (dashboard, CRUD, settings)
  → Read: 06-page-types.md#dashboard-app-pages
  → Read: 08-state-data.md for data patterns

  Build:
    a. Dashboard overview (/dashboard)
    b. Resource listing + detail + create + edit
    c. Settings page
    d. Admin pages (if applicable)

  Gate: CRUD operations work, navigation correct
  Commit: "feat: add dashboard and app pages"

PHASE 6: DATA LAYER (if database needed)
  → Read: 08-state-data.md#database-layer

  Build:
    a. db/schema.ts (Drizzle schema)
    b. db/index.ts (connection)
    c. npx drizzle-kit push (create tables)
    d. Server Actions for CRUD
    e. Wire forms to actions

  Gate: Data persists, CRUD works end-to-end
  Commit: "feat: add database and server actions"

PHASE 7: INTERACTIONS + STATE
  → Read: 07-interactions.md

  Wire:
    a. All button handlers
    b. All form submissions
    c. All navigation
    d. All modals/drawers
    e. Filters, sort, search, pagination (URL state)
    f. Loading states for all async operations

  Gate: Every interactive element responds correctly
  Commit: "feat: wire all interactions"

PHASE 8: ERROR + EDGE CASES
  → Read: 11-error-edge-cases.md

  Add:
    a. loading.tsx for each route group
    b. error.tsx for each route group
    c. not-found.tsx (global 404)
    d. global-error.tsx
    e. Empty states for all lists/tables
    f. Form validation error states
    g. Network error handling

  Gate: No unhandled errors, graceful degradation
  Commit: "feat: add error handling and edge cases"

PHASE 9: INVISIBLE LAYER
  → Read: 09-invisible-layer.md

  Add:
    a. Metadata for every page (title, description, OG)
    b. sitemap.ts + robots.ts
    c. JSON-LD structured data
    d. Skip-to-content link
    e. Alt text on all images
    f. Labels on all form inputs
    g. CSP + security headers
    h. Rate limiting on API routes

  Gate: Lighthouse all categories >= 90
  Commit: "feat: add SEO, accessibility, security layers"

PHASE 10: AGENT-BROWSABLE LAYER
  → Read: 10-agent-browsable.md

  Add:
    a. data-agent-* attributes on interactive elements
    b. API discovery endpoint (/api)
    c. API endpoints mirroring page data
    d. Verify accessibility tree is meaningful

  Gate: Agent can navigate and interact via a11y tree
  Commit: "feat: add agent-browsable layer"

PHASE 11: RESPONSIVE PASS
  → Read: 12-responsive.md

  Verify at 375px, 768px, 1440px:
    a. All pages render correctly
    b. Mobile nav works
    c. Tables scroll or card-ify
    d. Forms are usable
    e. No horizontal overflow

  Gate: All pages pass responsive check
  Commit: "fix: responsive adjustments"

PHASE 12: FINAL DEPLOY + VALIDATE
  a. npm run build (must succeed with zero errors)
  b. git add -A && git commit -m "feat: production-ready" && git push
  c. Wait for Vercel deployment
  d. Run validation checklist (→ 16-validation.md)
  e. Fix any critical failures
  f. Final commit + push

  Gate: Validation score >= 90%
  Commit: "fix: validation fixes" (if needed)
```

---

## DECISION SHORTCUTS

```spec
IF: Website has no auth → SKIP Phases 4, 6 (unless DB needed for other reasons)
IF: Website is marketing only → SKIP Phases 5, 6, 10 (no dashboard, no DB, minimal agent layer)
IF: Website is replication → Run 14-extraction-sop.md FIRST (ALL steps including 0.5, 1.5, 5.5),
      pass completeness gate, THEN follow this SOP with extracted specs.
      ⚠️ Do NOT start building until sitemap.json + interactions.json exist.
      ⚠️ ALL product-domain links must become internal routes (login, signup, dashboard, docs).
IF: Website needs AI features → Add AI SDK in Phase 2, wire in Phase 7
IF: Website needs payments → Add Stripe in Phase 6, wire in Phase 7
IF: In doubt about any component → Check 03-atomic-elements.md or 04-components.md
IF: In doubt about any page → Check 06-page-types.md
IF: In doubt about any interaction → Check 07-interactions.md
```

## PHASE EXIT CRITERIA (mandatory before proceeding to next phase)

```spec
⚠️ NEVER declare a phase complete without passing these checks.
   The human should NOT be the one finding bugs. The agent self-verifies.

AFTER EVERY PHASE:
  1. LINK AUDIT: Run automated link checker on the deployed site.
     Every internal <a href> must resolve (zero 404s).
     Script: crawl the replica, check every link, report broken ones.
     If any broken → fix before declaring phase complete.

  2. SCREENSHOT COMPARE (for replication projects):
     For every page built in this phase:
       a. Open the ORIGINAL page and take a screenshot
       b. Open the REPLICA page and take a screenshot
       c. Compare side-by-side (visual or pixelmatch)
       d. If layout/content differs significantly → fix before proceeding

  3. INTERACTIVE VERIFY (for replication projects):
     For every dropdown, tab, form, modal on pages built in this phase:
       a. Click/hover the interactive element on the REPLICA
       b. Compare behavior with the ORIGINAL
       c. If different → fix before proceeding

  4. NAVIGATION TEST:
     Start at homepage → click through 5-10 common user paths.
     Does it feel like the real site? Can you reach every section?
     If any dead ends or wrong destinations → fix before proceeding.

  5. CONTENT DEPTH AUDIT (for replication projects):
     For every page built or modified in this phase:
       a. Count the number of major sections (h2 headings or <section> elements) on the ORIGINAL
       b. Count the same on the REPLICA
       c. If replica has <60% of original's sections → page is incomplete
       d. Incomplete pages MUST be flagged and fixed before declaring phase complete

     Quick script:
       // On original: document.querySelectorAll('section, h2, h3').length
       // On replica: same query
       // Compare: replica_count / original_count >= 0.6

  6. DASHBOARD GATE (for sites with auth-gated pages):
     ⚠️ This is the #1 persistent failure across all replication attempts.
     Three different agents, same mistake: dashboard treated as placeholder.
     This gate exists because "try harder" doesn't work — enforcement does.

     BEFORE any phase involving dashboard/app pages can be declared complete:
       a. Navigate to EVERY sidebar item on the original dashboard
       b. Verify the replica has a corresponding page (not placeholder)
       c. Each page must have real content structure (not "Coming soon")
       d. Each sidebar item must navigate to its page on the replica
       e. Each tab within a dashboard page must switch content on the replica
       f. Count: original sidebar items = N, replica working pages = M
          If M < N → phase is NOT complete

  7. ASSET GATE (for replication projects):
     ⚠️ Zero images = the site looks like a wireframe, not a replica.
     Images are the single biggest visual gap in every replication attempt.

     BEFORE declaring any phase complete:
       a. Count <img> elements on the original page
       b. Count <img> elements on the replica page
       c. If replica has <50% of original's images → page is NOT complete
       d. Key assets (logo, hero image, partner logos) must be real, not text placeholders

FAILING ANY CHECK = phase is NOT complete. Fix and re-verify.
```

## NEVER DECLARE DONE

```spec
⚠️ THIS IS THE MOST IMPORTANT RULE IN THIS SOP.

The agent MUST run the full verification pipeline BEFORE reporting to the human.
If the agent finds issues, FIX THEM FIRST, then report.

The human should receive a report that says:
  "52 pages built, 0 404s, screenshot comparison passed on all pages,
   all dropdowns verified, login flow works end-to-end."

NOT:
  "Deployed! Here's the URL."

If the agent says "done" and the human finds a 404, a broken dropdown,
or a link to the original site — the agent has failed at self-verification.
Go back and re-verify.
```

## FIX-FORWARD MODE (patching an existing replica)

```spec
When you receive a fix-forward handoff (an existing replica that needs improvement),
you are NOT starting from scratch — but you MUST still follow extraction discipline.

STEP 0: DASHBOARD FIRST (if auth-gated pages exist)
  BEFORE reading the handoff plan, BEFORE writing any code:
    a. Open Chrome DevTools MCP
    b. Navigate to the auth-gated URL (dashboard.*, app.*, etc.)
    c. Is the human's login session active? Can you see logged-in content?
    d. If YES → capture FULL structure: sidebar items, tabs, sub-pages, forms
    e. If NO → ask human to log in, then capture
  This takes 5-10 minutes and prevents the #1 replication failure.
  THREE agents skipped this step. Don't be the fourth.

STEP 0.5: READ THE HANDOFF + REFERENCED SOPs
  Read the handoff document AND the specific SOP sections it references.
  Not just the handoff. The handoff is a hypothesis. The SOPs are the methodology.
  If the handoff says "Read SOP 14 §1.5" — read it. It's there for a reason.

STEP 1: DO YOUR OWN COMPREHENSIVE COMPARISON (before executing the handoff plan)
  The handoff plan may be incomplete. The previous agent may have missed things.
  Before writing any code:
    a. Navigate to the ORIGINAL site in Chrome DevTools MCP
    b. Navigate to the REPLICA (npm run dev)
    c. Compare 5-10 key pages side-by-side (snapshot + screenshot both)
    d. List EVERY difference you find — not just what the handoff mentioned
    e. Amend the handoff plan with your findings

STEP 2: EXPLORE AUTH-GATED PAGES (if they exist)
  Navigate to ALL product subdomains (dashboard.*, api.*, docs.*) via Chrome DevTools MCP.
  The human's login session may already be active.
  If logged in → capture the FULL structure (sidebar, tabs, every sub-page)
  If not logged in → ask the human to log in

STEP 3: INTERACTIVE CAPTURE (even for fix-forward)
  Run the extraction checklist (14a-extraction-checklist.md) §INTERACTIVE CAPTURE.
  Even if the replica already has dropdowns/tabs/forms, verify they MATCH the original.
  Click every interactive element on BOTH sites. Compare.

STEP 4: EXECUTE FIXES
  Now execute the (amended) plan. Fix in priority order:
    P0: Broken links, missing pages, external links that should be internal
    P1: Layout/structure mismatches (wrong dropdown type, missing sections)
    P2: Content depth (missing sections on existing pages)
    P3: Visual polish (images, icons, badges, spacing)

STEP 5: VERIFY (full pipeline from Phase Exit Criteria)
  Run ALL exit criteria. No exceptions for fix-forward.
```

## COMMIT PROTOCOL

```spec
COMMIT AFTER EVERY PHASE.
Message format: "<type>: <description>"
Types: feat, fix, chore, refactor, docs
PUSH after every commit (Vercel auto-deploys, human can check progress).
NEVER leave uncommitted work. NEVER forget to push.
```

## REVIEW HANDOFF

```spec
AFTER PHASE 12:
  1. RUN FULL SELF-VERIFICATION (before telling the human anything):
     a. Automated link audit: crawl every page, check every <a href> → zero 404s
     b. Screenshot comparison: capture every page on replica, compare with original
     c. Interactive verification: test every dropdown, form, tab, modal
     d. Navigation paths: click through 10 common user journeys
     e. Self-contained check: search all code for external product-domain links
        (grep for dashboard.*, app.*, api.*, docs.* of original site)
        Any found = bug. Replace with internal routes.

  2. FIX any issues found in step 1. Re-verify after fixing.

  3. ONLY AFTER zero issues, report to human:
     - URL: https://[project].vercel.app
     - Pages: N built (list by template type)
     - Link audit: X internal links, 0 broken
     - Screenshot match: X pages compared, Y at PASS (≥95%), Z at WARN (80-95%)
     - Interactive states: X dropdowns verified, X forms working, X modals captured
     - Self-contained: ☐ yes / ☐ no (list any remaining external links)
     - Score: XX/100
     - Status: APPROVE / CONDITIONAL / REVISE
     - Known gaps: [list honestly — don't hide issues]

  4. If review agent available: spawn review agent with 16-validation.md
     A FRESH agent with no prior context catches things the builder misses.
```

## HANDOFF FORMAT (for orchestrator → executor handoffs)

```spec
When writing a handoff document for a fix-forward or fresh-build executor,
always include SPECIFIC SOP SECTION POINTERS — not just "read SOP 14."

TEMPLATE:

  ## Required Reading (with section pointers)
  1. Post-mortem: [path] — read the 5 failures, don't repeat them
  2. SOP 14 §0 (auth session) — you need Chrome login for [reason]
  3. SOP 14 §1.5 (interactive capture) — [what specifically to capture]
  4. SOP 14 §2.7 (asset collection) — images are [status]
  5. SOP 20 §FIX-FORWARD — you're patching, not building fresh
  6. SOP 20 §PHASE EXIT — MUST run before reporting

  ## Pre-flight
  Run 14a-extraction-checklist.md before writing any code.

WHY SECTION POINTERS MATTER:
  The full SOPs are 400+ lines each. An executor given "read SOP 14" will skim it.
  An executor given "read SOP 14 §1.5 (interactive capture) — this is where the last
  agent failed" will read those 30 lines carefully and actually follow them.
  The pointer says WHAT to read and WHY it matters for this specific task.
```
