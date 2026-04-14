# 14 — Extraction SOP (URL → Atom Decomposition)

## PURPOSE

```spec
Given a URL, decompose the existing website into atomic building blocks.
This is the REVERSE ENGINEERING pipeline.
Output: structured specification that feeds into 15-generation-sop.md.
USE CASE: Website replication (Phase 2 of Novada vision).

CRITICAL INSIGHT: Most valuable websites (dashboards, SaaS tools, admin panels)
are behind login. An extraction SOP that can't handle auth-gated pages is useless
for 80% of real use cases. Chrome login session reuse is the #1 capability.
```

---

## WHAT AI ACTUALLY NEEDS (not screenshots)

```spec
⚠️ Screenshots are for HUMAN QA, not for AI understanding.
   AI parses structured data far better than pixels.

FOR AI EXTRACTION, USE THESE FORMATS (priority order):
  1. Accessibility tree / snapshot   → structure, roles, text, hierarchy
  2. HTML source (outerHTML)         → exact DOM for recreation
  3. Computed CSS (getComputedStyle) → design tokens (colors, fonts, spacing)
  4. JSON snapshot                   → agent-to-agent handoff
  5. Screenshots                     → ONLY for human QA and pixel-diff verification

NEVER rely on screenshots as the primary extraction artifact.
Screenshots are the VERIFICATION step, not the CAPTURE step.
```

## EXTRACTION METHODS (priority order)

```spec
METHOD 1: BB-BROWSER (recommended — uses user's real Chrome with login)
  HOW: Runs in user's real Chrome browser, reuses all logged-in sessions
  SKILL: bb-browser (already installed at ~/.claude/skills/bb-browser/)
  AUTH: User's Chrome has all login sessions — no re-login, no cookie copying
  VISIBILITY: User can SEE the agent operating in their Chrome (not hidden)

  KEY COMMANDS:
    bb-browser open <url>                    # open in user's Chrome (new tab)
    bb-browser snapshot -i                   # structured element tree (interactive)
    bb-browser snapshot --json               # machine-parseable JSON structure
    bb-browser eval "document.querySelector('nav').outerHTML"   # extract exact HTML
    bb-browser eval "getComputedStyle(document.body).backgroundColor"  # CSS values
    bb-browser click @5                      # click element by ref
    bb-browser hover @3                      # hover for dropdowns
    bb-browser screenshot                    # visual capture (for human QA only)
    bb-browser close                         # close tab when done

  EXTRACTION WORKFLOW:
    1. bb-browser open <url>                            → navigate
    2. bb-browser snapshot -i                           → get element tree
    3. bb-browser eval "document.documentElement.outerHTML"  → get full HTML
    4. bb-browser eval "<css extraction script>"        → get design tokens
    5. bb-browser click @ref / hover @ref               → interact with elements
    6. bb-browser snapshot -i                           → capture changed state
    7. bb-browser close                                 → clean up

  BEST FOR: ALL extraction tasks. Public and auth-gated. Interactive capture.
  WHY PRIMARY: User's real Chrome → all login sessions → visible to user → structured output

METHOD 2: CHROME CDP PIPELINE (backup — when bb-browser unavailable)
  HOW: Copies cookies from human's real Chrome profile to a temp dir, launches via CDP
  CODE: ~/Projects/agent-chrome-bridge/tools/chrome-cdp.ts
  AUTH: Uses human's existing Chrome login sessions (no re-login needed)

  SETUP:
    cd ~/Projects/agent-chrome-bridge
    npm run launch-chrome     # launches Chrome with copied cookies on port 9222
    # Then in agent code:
    const browser = await pw.chromium.connectOverCDP('http://127.0.0.1:9222')

  ⚠️ CHROME 146+ CONSTRAINT:
    Chrome 146+ blocks --remote-debugging-port on the default profile directory.
    The CDP pipeline works around this by copying cookies to a temp directory.

  BEST FOR: Programmatic batch extraction (many pages in one script), when bb-browser
    has issues, or when you need Playwright API for complex automation.

METHOD 3: CHROME DEVTOOLS MCP (backup — separate profile)
  HOW: Connects to a Chrome instance with its own persistent profile
  PROFILE: ~/.cache/chrome-devtools-mcp/chrome-profile (auto-created)
  AUTH: Human logs into target site ONCE in the yellow-border Chrome → remembered
  TOOLS: take_snapshot, take_screenshot, evaluate_script, navigate_page

  BEST FOR: Quick checks when bb-browser and CDP are not set up.
  LIMITATION: Opens a SEPARATE Chrome window — user may not see it.
    Login sessions are separate from user's main Chrome.

METHOD 4: PLAYWRIGHT HEADLESS (backup — public pages only)
  HOW: Headless browser, no login state
  TOOLS: browser_navigate, browser_snapshot, browser_take_screenshot, browser_evaluate
  BEST FOR: Public pages where no auth is needed, batch screenshot comparison
  LIMITATION: Cannot access auth-gated pages

METHOD 5: GSTACK (backup — QA and responsive testing)
  SKILL: gstack (already installed at ~/.claude/skills/gstack/)
  HOW: Headless browser for QA testing, responsive layout checks, diff before/after
  BEST FOR: Verification phase — testing replica at 375px, 768px, 1440px

METHOD DECISION:
  Auth-gated pages         → Method 1 (bb-browser) — always first choice
  Public pages             → Method 1 (bb-browser) or Method 4 (Playwright)
  Batch extraction (50+)   → Method 2 (CDP pipeline with script)
  Quick spot check         → Method 3 (Chrome DevTools MCP)
  Responsive QA            → Method 5 (gstack)
  If bb-browser fails      → Method 2 (CDP) → Method 3 (DevTools MCP) → Method 4 (Playwright)
```

---

## EXTRACTION PIPELINE

```spec
STEP 0: CONNECT ──→ STEP 0.5: CRAWL ──→ STEP 1: DISCOVER ──→ STEP 1.5: INTERACTIVE CAPTURE
(auth + browser)     (automated URL tree)   (sitemap + nav)      (dropdowns + modals + forms)
     ──→ STEP 2: CAPTURE ──→ STEP 3: ANALYZE ──→ STEP 4: DECOMPOSE
         (screenshot+DOM)     (structure+style)    (atoms+compositions)
     ──→ STEP 5: SPECIFY ──→ STEP 5.5: COMPLETENESS GATE ──→ STEP 6: VERIFY
         (output spec)         (human reviews sitemap)          (pixel diff)

⚠️ SELF-CONTAINED REPLICA RULE:
  The replica is a STANDALONE site. Every link that points to the product's own
  domains (dashboard.*, api.*, developer.*, docs.*, app.*) MUST become an internal
  route in the replica. External links (LinkedIn, Twitter, GitHub) stay external.
  Login/signup/dashboard flows must be replicated as internal pages.
  The human should be able to click through the entire replica without ever
  leaving the replica domain.

⚠️ EXTRACTION TIME RULE:
  For complex sites (20+ pages), extraction should take 2-3x LONGER than building.
  Rushing extraction → garbage build. Thorough extraction → straightforward build.
  If you feel like extraction is taking too long, you're probably doing it right.
```

### STEP 0: CONNECT (establish auth + browser)

```spec
INPUT: URL + auth requirement (from project-checklist.md)
OUTPUT: authenticated browser session ready for extraction

PROCESS:
  0.1 Determine auth requirement:
      Public site → skip to Step 1 (use any method)
      Auth-gated → continue

  0.2 For Chrome DevTools MCP (Method 1):
      a. navigate_page to target URL
      b. Check if login page appears (take_snapshot, look for login form)
      c. If logged in → proceed to Step 1
      d. If not logged in → navigate to login page
         → Tell human: "Please log in to [site] in the yellow-border Chrome window"
         → Wait for human confirmation
         → Verify login succeeded (take_snapshot, check for dashboard/profile elements)

  0.3 For CDP pipeline (Method 2):
      a. Human ensures they are logged in to target site in their normal Chrome
      b. Agent runs: cd ~/Projects/agent-chrome-bridge && npm run launch-chrome
      c. Agent runs: npm run cdp <target-url>
      d. Verify login session carried over (check for auth-gated content)

  0.4 Record auth state:
      - What URL redirects to when not logged in
      - What elements appear only when logged in
      - Session cookie names (for reference)
```

### STEP 0.5: CRAWL (automated URL tree)

```spec
INPUT: authenticated browser session
OUTPUT: complete URL tree with classification

⚠️ THIS STEP IS MANDATORY. Do NOT skip it and go straight to manual discovery.
   The crawl catches pages that manual browsing misses.

PROCESS:
  0.5.1 AUTOMATED LINK CRAWL
      Starting from the homepage, follow every <a href> recursively:
        a. Collect ALL links on the current page
        b. Filter to same-origin links (same hostname)
        c. Also collect links to product subdomains (dashboard.*, api.*, docs.*)
        d. Visit each unvisited link, repeat
        e. Stop at depth 3 or 500 pages (whichever comes first)

      Script pattern (Playwright):
        const visited = new Set();
        const toVisit = [startUrl];
        while (toVisit.length > 0) {
          const url = toVisit.pop();
          if (visited.has(url)) continue;
          visited.add(url);
          await page.goto(url);
          const links = await page.evaluate(() =>
            [...document.querySelectorAll('a[href]')]
              .map(a => a.href)
              .filter(h => h.includes(location.hostname) || h.includes('dashboard.') || h.includes('api.'))
          );
          links.forEach(l => { if (!visited.has(l)) toVisit.push(l); });
        }

  0.5.2 CLASSIFY EACH URL
      For each discovered URL, classify:
        INTERNAL:   Same domain, same product → replicate as internal page
        PRODUCT:    Product subdomain (dashboard, api, docs) → replicate as internal page
        EXTERNAL:   Third-party (LinkedIn, Twitter, GitHub) → keep as external link
        DUPLICATE:  Same content as another URL → skip

  0.5.3 OUTPUT: url-tree.json
      [
        { "url": "/", "type": "internal", "depth": 0, "found_on": "root" },
        { "url": "/products/scraper-api", "type": "internal", "depth": 1, "found_on": "/" },
        { "url": "https://dashboard.novada.com/sign-up/", "type": "product", "depth": 1, "found_on": "/",
          "replica_path": "/signup" },
        { "url": "https://developer.novada.com/novada", "type": "product", "depth": 1, "found_on": "/",
          "replica_path": "/docs" },
        ...
      ]

  0.5.4 COMPARE WITH MANUAL DISCOVERY (after Step 1)
      After manual discovery, diff the crawl results vs manual sitemap.
      Any URLs in crawl but not in manual = pages you would have missed.
      Add them to the sitemap.
```

### STEP 1: DISCOVER (sitemap + navigation structure)

```spec
INPUT: authenticated browser session
OUTPUT: complete sitemap + navigation hierarchy

PROCESS:
  1.1 EXTRACT TOP-LEVEL NAVIGATION
      Take accessibility tree snapshot → identify nav elements
      Record: every link in navbar, sidebar, footer

  1.2 DISCOVER SIDEBAR ITEMS (for dashboard/app sites)
      For each sidebar nav item:
        a. Click/navigate to it
        b. Record the URL path
        c. Check for sub-navigation (nested items, expandable groups)
        d. Record parent-child relationships

  1.3 DISCOVER SUB-TABS (within each page)
      ⚠️ THIS IS THE MOST COMMONLY MISSED STEP
      For each page:
        a. Take snapshot → look for Tabs, TabsList, TabsTrigger elements
        b. For each tab: click it, record what content appears
        c. Some tabs load new content without URL change → capture via snapshot
        d. Some tabs change URL (?tab=settings) → record URL variant

  1.4 DISCOVER DROPDOWN MENUS
      For each navigation element:
        a. Hover/click to reveal dropdowns
        b. Record all items in each dropdown
        c. Record their destinations

  1.5 DISCOVER MODAL/DIALOG TRIGGERS
      Identify buttons that open modals (create, edit, delete, settings)
      Click each → capture the modal content → close

  1.6 COMPILE FULL SITEMAP
      Output format:
        /                         (public, marketing)
        /features                 (public, marketing)
        /pricing                  (public, marketing)
        /dashboard                (auth, dashboard)
        /dashboard > Overview tab (auth, dashboard, sub-tab)
        /dashboard > Activity tab (auth, dashboard, sub-tab)
        /settings                 (auth, settings)
        /settings/general         (auth, settings, sub-page)
        /settings/billing         (auth, settings, sub-page)
        ...

      Total pages discovered: N (track this number)
```

### STEP 1.5: INTERACTIVE CAPTURE (dropdowns + modals + forms)

```spec
INPUT: authenticated browser session + sitemap from Step 1
OUTPUT: screenshot + HTML structure of every interactive state

⚠️ THIS IS A DEDICATED PASS. Do NOT combine with page-level capture.
   Interactive states are the #1 source of replication errors.
   Skipping this step = wrong dropdown layouts, missing modals, broken forms.

PROCESS:
  1.5.1 NAVBAR DROPDOWN PASS
      For EACH navigation item in the main header:
        a. Hover the nav item
        b. Wait 500-800ms for dropdown to appear
        c. take_screenshot (showing the open dropdown)
        d. take_snapshot (to get the dropdown's HTML structure)
        e. Record: layout type (simple list, mega-menu grid, multi-column)
        f. Record: every link in the dropdown with text + href + description
        g. Record: any icons, badges, categories, or sub-sections
        h. Move mouse away → dropdown closes → continue to next item

      ⚠️ Some dropdowns are MEGA-MENUS (full-width, multi-column, with cards).
         These are NOT simple lists. Capture the exact grid structure.
         Example: "Scraping solutions" dropdown might have:
         - Left column: featured product card with CTA
         - Middle: 2x2 grid of product cards
         - Right: sidebar list of target platforms

  1.5.2 FORM CAPTURE PASS
      For login, signup, contact, and any other forms:
        a. Navigate to the form page
        b. take_screenshot of the full form
        c. Record: every field (name, type, placeholder, required)
        d. Record: social login buttons (Google, GitHub, etc.)
        e. Record: terms/privacy links
        f. Record: "Already have account? Log in" type cross-links
        g. Record: validation behavior (what happens on empty submit)

  1.5.3 MODAL/DIALOG CAPTURE PASS
      For every button that opens a modal (identified in Step 1.5):
        a. Click the trigger button
        b. Wait for modal animation to complete
        c. take_screenshot of the open modal
        d. take_snapshot of the modal content
        e. Record: modal content structure
        f. Close the modal → continue

  1.5.4 HOVER STATE CAPTURE
      For key interactive elements (buttons, cards, nav items):
        a. Hover the element
        b. Note: color change, shadow, scale, underline
        c. Record as CSS transition description

  1.5.5 OUTPUT: interactions-captured/
      Save to extraction output directory:
        interactions-captured/
          nav-dropdown-scraping-solutions.png
          nav-dropdown-scraping-solutions.html  (raw dropdown HTML)
          nav-dropdown-proxies.png
          nav-dropdown-proxies.html
          nav-dropdown-pricing.png
          nav-dropdown-use-cases.png
          nav-dropdown-resource.png
          form-login.png
          form-signup.png
          modal-contact.png
          ...
```

### STEP 2: CAPTURE (screenshot + DOM per page)

```spec
INPUT: full sitemap from Step 1
OUTPUT: for EACH page: desktop screenshot, mobile screenshot, a11y tree, computed styles

PROCESS (for each page in sitemap):
  2.1 Navigate to the page URL

  2.2 Wait for load AND trigger lazy content:
      - Wait for network idle (no pending requests)
      - Wait for any skeleton/loading animations to resolve
      - ⚠️ SCROLL THE ENTIRE PAGE before taking screenshots:
        Scroll from top to bottom in 800px increments, waiting 500ms each.
        This triggers lazy-loaded images, intersection observers, and
        dynamically loaded sections. Many modern sites load <50% of content
        on initial page load.
      - After full scroll, scroll back to top and wait 2s
      - Check: did the page height increase? If yes, content was lazy-loaded.
        Log: "Page height before scroll: Xpx, after: Ypx"

  2.3 Desktop capture (1440px width):
      - resize_page to 1440x900
      - take_screenshot (full page)
      - take_snapshot (accessibility tree)
      - evaluate_script → extract computed styles (see EXTRACTION SCRIPTS below)

  2.4 Mobile capture (375px width):
      - resize_page to 375x812
      - take_screenshot (full page)
      - take_snapshot (may differ from desktop — hamburger menu, stacked layout)

  2.5 Sub-tab capture:
      For each tab/sub-tab on the page:
        - Click the tab
        - Wait for content to load
        - take_screenshot + take_snapshot
        - Record which tab was active

  2.6 Interactive element capture:
      For dropdowns, modals, popovers:
        - Trigger open state (click/hover)
        - take_screenshot showing the open state
        - take_snapshot of the overlay content
        - Close and continue

  2.7 Asset collection:
      evaluate_script to extract:
        - All image src URLs
        - All font-family values
        - All SVG icons (inline SVGs)
        - All external stylesheet URLs
        - Favicon URL

BATCH STRATEGY:
  For sites with 20+ pages, process in batches:
    Batch 1: All top-level pages (nav items)
    Batch 2: All sub-pages (detail pages, settings tabs)
    Batch 3: All modal/overlay states
    Batch 4: All error/empty states (if accessible)
  Commit captures after each batch (prevent data loss).
```

### STEP 3: ANALYZE (identify design system + structure)

```spec
INPUT: screenshots + DOM + styles + assets
OUTPUT: structural analysis

PROCESS:
  3.1 IDENTIFY LAYOUT TEMPLATE
      Compare page structure against 05-page-templates.md catalog.
      Output: template type (marketing, dashboard, auth, docs, etc.)

  3.2 IDENTIFY COLOR PALETTE
      Extract: background colors, text colors, accent colors, border colors
      Map to: design token equivalents (→ 02-design-tokens.md)
      Tool: evaluate_script sampling computed styles from key elements
      Focus on: body bg, card bg, heading color, muted text, primary buttons, borders

  3.3 IDENTIFY TYPOGRAPHY
      Extract: font-family, font-size scale, font-weight scale, line-height
      Map to: Tailwind text-* classes or custom font config
      Check: is it using system fonts, Google Fonts, or custom fonts?

  3.4 IDENTIFY SPACING SYSTEM
      Extract: padding, margin, gap patterns
      Look for: consistent base unit (4px, 8px)
      Map to: Tailwind spacing scale

  3.5 IDENTIFY COMPONENT LIBRARY
      Detect: is the site using a known component library?
      Check: Radix primitives (data-radix-* attributes), headless UI, Material UI, Chakra
      If shadcn/ui compatible: note which atoms map directly
      If custom: note each custom component for recreation

  3.6 IDENTIFY NAVIGATION STRUCTURE
      Map: all nav links, their destinations, hierarchy
      Record: active state styling, dropdown behavior, mobile behavior
      Record: sidebar collapse behavior, breadcrumb pattern
```

### STEP 4: DECOMPOSE (atom-by-atom specification)

```spec
INPUT: structural analysis
OUTPUT: atom-by-atom specification per page

PROCESS:
  4.1 FOR EACH PAGE:
      a. Identify the layout template
      b. Identify all organisms (sections)
      c. For each organism, identify molecules
      d. For each molecule, identify atoms
      e. For each atom, record:
         - Type (→ match against 03-atomic-elements.md)
         - Variants used (color, size, state)
         - Content (text, image src, icon name)
         - Position (within parent, grid placement)
         - Responsive behavior (what changes at mobile?)
         - Interaction (what happens on click/hover?)

  4.2 OUTPUT FORMAT (per page):
      ```yaml
      page: /pricing
      template: marketing
      auth_state: public
      organisms:
        - type: hero
          variant: centered
          atoms:
            - type: badge
              variant: secondary
              content: "New"
            - type: heading
              level: h1
              content: "Simple, transparent pricing"
              style: "text-4xl md:text-5xl font-bold text-center"
            - type: paragraph
              variant: lead
              content: "Start free, upgrade when you need to."
          molecules: []
        - type: pricing-section
          variant: 3-column
          molecules:
            - type: pricing-card
              variant: standard
              atoms:
                - type: heading
                  level: h3
                  content: "Starter"
                - type: text
                  variant: metric
                  content: "$0"
                - type: text
                  variant: muted
                  content: "/month"
                - type: list
                  variant: check-list
                  items: ["5 projects", "1GB storage", "Community support"]
                - type: button
                  variant: outline
                  content: "Get Started"
                  action: navigate
                  target: "/signup?plan=starter"
      ```

  4.3 FOR INTERACTIONS:
      Record every interactive element:
        trigger: what activates it (click, hover, scroll)
        behavior: what happens (navigate, open modal, toggle, submit)
        destination: where it goes or what it affects
        visual feedback: hover style, active state, loading state
```

### STEP 5: SPECIFY (output generation-ready files)

```spec
INPUT: atom decomposition
OUTPUT: generation-ready specification files

PROCESS:
  5.1 Generate design-tokens.json:
      {
        "colors": { "primary": "#...", "background": "#...", ... },
        "fonts": { "sans": "Inter", "mono": "JetBrains Mono" },
        "spacing": { "base": 4 },
        "radius": "0.5rem"
      }

  5.2 Generate sitemap.json:
      [
        { "path": "/", "template": "marketing", "auth": "public" },
        { "path": "/pricing", "template": "marketing", "auth": "public" },
        { "path": "/dashboard", "template": "dashboard", "auth": "authenticated",
          "sub_tabs": ["overview", "activity"] },
        ...
      ]

  5.3 Generate pages/*.yaml (one per page):
      Detailed atom-by-atom specification (format from Step 4.2)

  5.4 Generate assets-needed.json:
      {
        "images": [
          { "name": "hero.png", "size": "1200x600", "source_url": "https://...", "description": "Hero background" },
          { "name": "logo.svg", "source_url": "https://...", "description": "Brand logo" }
        ],
        "fonts": [{ "name": "Inter", "source": "google", "weights": [400, 500, 600, 700] }],
        "icons": ["lucide:search", "lucide:menu", "custom:logo-icon"]
      }

  5.5 Generate interactions.json:
      [
        { "element": "login-button", "trigger": "click", "action": "navigate", "target": "/login" },
        { "element": "mobile-menu", "trigger": "click", "action": "open", "target": "mobile-nav-sheet" },
        { "element": "sidebar-project", "trigger": "click", "action": "navigate", "target": "/dashboard/projects/:id" },
        ...
      ]

OUTPUT FILES → feed directly into 15-generation-sop.md
```

### STEP 5.5: COMPLETENESS GATE (human reviews before build)

```spec
INPUT: all spec files from Step 5
OUTPUT: human approval to proceed to build

⚠️ DO NOT PROCEED TO BUILD without passing this gate.
   Present the following to the human for review:

COMPLETENESS CHECKLIST:
  ☐ sitemap.json lists N pages (state the number)
  ☐ Every nav dropdown captured as screenshot (list them)
  ☐ Login/signup forms captured and replicated as internal routes
  ☐ Dashboard/app pages captured (if auth-gated site)
  ☐ design-tokens.json generated with colors, fonts, spacing
  ☐ interactions.json generated with every interactive element
  ☐ All product-subdomain links mapped to internal replica paths
  ☐ Total assets identified: N images, N icons, N fonts

PRESENT TO HUMAN:
  "Extraction complete. Found [N] pages across [M] templates.
   Key routes: [list top-level routes]
   Interactive states captured: [N] dropdowns, [N] forms, [N] modals
   Product subdomain routes to replicate: [list]
   Shall I proceed to build?"

If human says there are missing pages or interactions, go back to Step 1.
```

### STEP 6: VERIFY (pixel diff comparison)

```spec
INPUT: original screenshots + replica screenshots
OUTPUT: accuracy score per page

PROCESS:
  6.1 After replica is built (via 15-generation-sop.md), capture screenshots of EVERY page
      at the same viewport sizes (1440px desktop, 375px mobile)

  6.2 Compare original vs replica using pixel diff:
      TOOL: pixelmatch (npm install pixelmatch pngjs)

      import pixelmatch from 'pixelmatch'
      import { PNG } from 'pngjs'

      const img1 = PNG.sync.read(fs.readFileSync('original.png'))
      const img2 = PNG.sync.read(fs.readFileSync('replica.png'))
      const diff = new PNG({ width: img1.width, height: img1.height })

      const numDiffPixels = pixelmatch(
        img1.data, img2.data, diff.data,
        img1.width, img1.height,
        { threshold: 0.1 }
      )

      const totalPixels = img1.width * img1.height
      const matchPercent = ((totalPixels - numDiffPixels) / totalPixels) * 100

  6.3 SCORING:
      PASS:   >= 95% pixel match (near-identical)
      WARN:   80-95% pixel match (close but has visible differences)
      FAIL:   < 80% pixel match (significant deviations)

  6.4 Generate diff images:
      Save diff PNG (highlights mismatched pixels in red)
      Human or review agent visually inspects diff to identify:
        - Layout shifts (structural problem)
        - Color mismatches (token mapping problem)
        - Missing content (extraction gap)
        - Font differences (font loading problem)

  6.5 ITERATE:
      For WARN/FAIL pages:
        a. Identify the specific diff areas
        b. Trace back to which atom/molecule/organism is wrong
        c. Fix in the replica code
        d. Re-capture and re-compare
        e. Repeat until PASS or acceptable WARN

TARGET: >= 90% of pages scoring PASS, remaining at WARN, zero FAIL.
```

---

## EXTRACTION TOOL COMMANDS

```spec
BB-BROWSER (PRIMARY — user's real Chrome with login):
  bb-browser open <url>                  → open in user's Chrome (new tab, visible)
  bb-browser open <url> --tab current    → open in current tab (no new tab)
  bb-browser snapshot -i                 → interactive element tree (@ref for clicking)
  bb-browser snapshot --json             → machine-parseable JSON structure
  bb-browser eval "<js>"                 → execute JS and return result
  bb-browser click @5                    → click element by ref number
  bb-browser hover @3                    → hover element (for dropdowns)
  bb-browser fill @2 "text"              → fill input field
  bb-browser screenshot                  → take screenshot (for human QA)
  bb-browser back / forward / refresh    → navigation
  bb-browser close                       → close current tab (ALWAYS do this when done)
  bb-browser tab list                    → list open tabs
  bb-browser frame "#iframe-id"          → switch to iframe
  bb-browser frame main                  → switch back to main frame

  STRUCTURED EXTRACTION via bb-browser eval:
    # Get full page HTML (best for AI understanding)
    bb-browser eval "document.documentElement.outerHTML"

    # Get specific section HTML
    bb-browser eval "document.querySelector('nav').outerHTML"
    bb-browser eval "document.querySelector('.hero').outerHTML"
    bb-browser eval "document.querySelector('.sidebar').outerHTML"

    # Get page metadata
    bb-browser eval "JSON.stringify({title: document.title, url: location.href, lang: document.documentElement.lang})"

    # Get all links
    bb-browser eval "[...document.querySelectorAll('a[href]')].map(a=>({text:a.textContent.trim(),href:a.href})).filter(l=>l.text)"

CHROME CDP PIPELINE (BACKUP — programmatic batch extraction):
  cd ~/Projects/agent-chrome-bridge
  npm run launch-chrome      → launch Chrome with copied cookies on port 9222
  npm run cdp <url>          → capture page (screenshot + DOM + styles)
  npm run cdp-batch <urls>   → batch capture multiple pages
  # Then connect via Playwright:
  const browser = await pw.chromium.connectOverCDP('http://127.0.0.1:9222')

CHROME DEVTOOLS MCP (BACKUP — separate Chrome profile):
  navigate_page url=<url>    → go to URL
  take_snapshot              → get accessibility tree (DOM structure)
  take_screenshot            → get visual snapshot (PNG)
  evaluate_script            → run JS to extract computed styles, colors, fonts
  click uid=<uid>            → click element
  hover uid=<uid>            → hover element

PLAYWRIGHT HEADLESS (BACKUP — public pages only):
  browser_navigate url=<url> → go to URL
  browser_snapshot           → get accessibility tree
  browser_take_screenshot    → get visual screenshot
  browser_evaluate           → run extraction JS

GSTACK (VERIFICATION — responsive QA):
  # Use gstack skill for testing replica at multiple viewports
  # See: ~/.claude/skills/gstack/

EXTRACTION SCRIPTS (run via evaluate_script):

  // Get all colors used on page
  () => {
    const elements = document.querySelectorAll('*')
    const colors = new Set()
    elements.forEach(el => {
      const style = getComputedStyle(el)
      if (style.display !== 'none') {
        colors.add(style.backgroundColor)
        colors.add(style.color)
        colors.add(style.borderColor)
      }
    })
    return [...colors].filter(c => c !== 'rgba(0, 0, 0, 0)' && c !== 'transparent')
  }

  // Get all font families
  () => {
    const elements = document.querySelectorAll('*')
    const fonts = new Set()
    elements.forEach(el => {
      if (getComputedStyle(el).display !== 'none') {
        fonts.add(getComputedStyle(el).fontFamily)
      }
    })
    return [...fonts]
  }

  // Get all internal links (sitemap discovery)
  () => {
    const links = document.querySelectorAll('a[href]')
    const origin = window.location.origin
    return [...new Set(
      [...links]
        .map(a => a.href)
        .filter(href => href.startsWith(origin))
        .map(href => new URL(href).pathname)
    )].sort()
  }

  // Get all sidebar navigation items
  () => {
    const navItems = document.querySelectorAll('nav a, [role="navigation"] a, aside a')
    return [...navItems].map(a => ({
      text: a.textContent?.trim(),
      href: a.href,
      active: a.getAttribute('aria-current') === 'page' ||
              a.classList.contains('active') ||
              a.getAttribute('data-state') === 'active'
    }))
  }

  // Get all tab triggers on current page
  () => {
    const tabs = document.querySelectorAll('[role="tab"], [data-state="active"], [data-state="inactive"]')
    return [...tabs].map(t => ({
      text: t.textContent?.trim(),
      active: t.getAttribute('data-state') === 'active' || t.getAttribute('aria-selected') === 'true',
      id: t.id
    }))
  }
```

---

## RESEARCH EXISTING TOOLS (before writing custom extraction code)

```spec
⚠️ The agent's built-in capability is NOT enough for pixel-perfect replication.
   Before writing custom extraction scripts, search for existing tools:

SEARCH (in order):
  1. GitHub: gh search repos "website clone" "site copy" "html to nextjs"
  2. npm: search for site-copier, httrack, single-file, website-scraper
  3. Web: search for "pixel perfect website replication tools"

TOOLS TO CONSIDER:
  - httrack / wget --mirror: full site download (HTML/CSS/images)
  - single-file (npm): save complete page as single HTML
  - Playwright codegen: record interactions → generate test scripts
  - pixelmatch / BackstopJS / Percy: visual regression / screenshot comparison
  - css-to-tailwind tools: convert extracted CSS to Tailwind classes
  - svg-to-react tools: convert extracted SVGs to React components

WHEN TO USE:
  - httrack/wget: as a REFERENCE alongside manual extraction, not as primary
  - single-file: to capture exact HTML of complex pages (modals, dropdowns)
  - BackstopJS: for automated screenshot comparison during VERIFY step
  - css-to-tailwind: when mapping extracted computed styles to Tailwind

The goal is to AUGMENT agent capability with specialized tools,
not to replace the structured extraction pipeline.
```

---

## ACCURACY CHECKLIST

```spec
AFTER EXTRACTION, VERIFY:
  ☐ Automated crawl completed (url-tree.json generated)
  ☐ All pages captured (compare crawl results + manual sitemap vs actual navigation)
  ☐ All sub-tabs discovered (check each page for Tabs components)
  ☐ All sidebar items captured (expand all collapsible groups)
  ☐ All dropdown menus explored AND SCREENSHOT'D (hover/click every nav trigger)
  ☐ Dropdown screenshots show exact layout (simple list vs mega-menu vs grid)
  ☐ All modal dialogs captured (click every "create", "edit", "settings" button)
  ☐ Login/signup forms captured with every field documented
  ☐ Dashboard/app pages captured (if site has auth-gated area)
  ☐ All product-subdomain links mapped to internal replica paths
  ☐ Color palette matches (compare extracted colors vs visual)
  ☐ Typography matches (compare fonts, sizes)
  ☐ All interactive elements recorded (buttons, links, inputs, toggles)
  ☐ All images/assets listed with source URLs
  ☐ Auth states documented (before login vs after login)
  ☐ Mobile layout captured (375px screenshots)
  ☐ Desktop layout captured (1440px screenshots)
  ☐ Empty states captured (what pages look like with no data)
  ☐ Lazy-loaded content captured (scrolled every page fully before screenshot)
  ☐ sitemap.json + design-tokens.json + interactions.json all generated
  ☐ Completeness gate passed (human reviewed sitemap before build)

ACCURACY TARGET: 90%+ of atoms correctly identified and specified.
Pixel diff target: >= 90% of pages at PASS (≥95% match), rest at WARN (80-95%).
```

---

## ADVANCED: REFERENCE MATERIAL

```spec
For complex extraction scenarios, consult:
  SOP v3:        ~/Projects/novada-web/sop/website-replication-sop-v3.md
  CDP pipeline:  ~/Projects/agent-chrome-bridge/tools/chrome-cdp.ts
  Pixel diff:    ~/Projects/agent-chrome-bridge/tools/pixel-diff.ts

These contain battle-tested patterns from real extraction runs (Tavily, Bright Data).
The genome's extraction process above is the GENERALIZED version.
SOP v3 is the SPECIALIZED version for Novada's specific pipeline.
```
