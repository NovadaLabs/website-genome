# Website Construction Genome — Master Index

## AGENT INSTRUCTIONS

```
ROLE: You are an executor agent. Your job is to build a production-ready website.
INPUT: This document set + human-provided checklist (human-setup/project-checklist.md)
OUTPUT: Complete website codebase, committed to GitHub, deployed to Vercel.
CONSTRAINT: Minimize questions. Only ask the human when the checklist is genuinely
  ambiguous AND the decision has irreversible consequences (architecture, auth provider,
  data model). Never ask about colors, spacing, or copy — use defaults.
REVIEW: After completion, spawn a FRESH review sub-agent to validate against 16-validation.md.
MODE: Multi-session recommended. See PROGRESSIVE LOADING and ORCHESTRATOR PROTOCOL below.
```

## PROGRESSIVE LOADING PROTOCOL

```spec
⚠️ DO NOT read all files at once. Total genome is ~210KB — exceeds any single context window.
Read ONLY the files needed for the current execution phase.
Each file is self-contained for its phase.

PHASE-GATED READING ORDER:

PHASE 0 — ORIENTATION (always read first)
  → 20-executor-sop.md     [MASTER SOP — start here, drives everything]
  → 00-index.md            [THIS FILE — navigation, conventions]

PHASE 1 — SCAFFOLD + TOKENS (read for project setup)
  → 02-design-tokens.md    [DNA: colors, typography, spacing]
  → VERSION.md             [pinned dependency versions]

PHASE 2 — LAYOUTS + SHARED COMPONENTS (read for building structure)
  → 04-components.md       [molecules + organisms]
  → 05-page-templates.md   [layout patterns]

PHASE 3 — PUBLIC PAGES (read for content pages)
  → 06-page-types.md       [all page types, sitemap patterns]
  → 13-content-strategy.md [where to get copy, images, icons]

PHASE 4 — AUTH (read only if auth needed)
  → 08-state-data.md       [auth data flow section]

PHASE 5 — APP PAGES (read for dashboard/CRUD pages)
  → 06-page-types.md       [dashboard section]
  → 03-atomic-elements.md  [reference individual atoms as needed]

PHASE 6 — DATA LAYER (read only if database needed)
  → 08-state-data.md       [database + cache sections]

PHASE 7 — INTERACTIONS (read for wiring behavior)
  → 07-interactions.md     [every interaction type]

PHASE 8 — ERROR HANDLING (read for edge cases)
  → 11-error-edge-cases.md [loading, error, empty, offline states]

PHASE 9 — INVISIBLE LAYER (read for production polish)
  → 09-invisible-layer.md  [SEO, accessibility, performance, security]

PHASE 10 — AGENT-BROWSABLE (read for agent optimization)
  → 10-agent-browsable.md  [data-*, JSON-LD, API mirroring]

PHASE 11 — RESPONSIVE (read for breakpoint pass)
  → 12-responsive.md       [mobile, tablet, desktop specs]

PHASE 12 — VALIDATION + DEPLOY (read for final check)
  → 16-validation.md       [90-point review checklist]

EXTRACTION (only for URL replication mode)
  → 14-extraction-sop.md   [URL → atom decomposition]
  → For advanced extraction (auth-gated, sub-tabs): see SOP v3

TEMPLATES (copy and fill as needed)
  → 18-prd-template.md     [product requirements document]
  → 19-tech-rd-template.md [technical design document]

REFERENCE (consult as needed, don't pre-load)
  → 01-first-principles.md [foundational theory]
  → 17-industry-research.md [competitive landscape]
```

## ORCHESTRATOR PROTOCOL (recommended for complex sites)

```spec
For websites with 10+ pages, use multi-session execution:

ORCHESTRATOR (long-running session):
  1. Read checklist + 00-index.md
  2. Generate phase-specific handoff briefs (one per phase)
  3. Dispatch fresh executor agents per phase
  4. Review each phase's output (or delegate to review agent)
  5. Coordinate cross-phase issues

EXECUTOR (fresh session per phase):
  1. Read handoff brief from orchestrator
  2. Read ONLY the genome files listed for that phase
  3. Execute the phase
  4. Commit + push (Vercel auto-deploys)
  5. Report back to orchestrator

HANDOFF BETWEEN PHASES:
  - Git repo state IS the handoff artifact
  - Each phase starts by pulling latest from git
  - No context carries over — fresh agent, zero bias

REVIEW (always a separate fresh agent):
  - Reads 16-validation.md + live deployment URL
  - Has NO knowledge of build decisions
  - Reports pass/fail per check

WHEN TO USE:
  Marketing site (5 pages): single agent is fine
  SaaS app (20+ pages): use orchestrator
  Full replication: use orchestrator + extraction specialist
```

## FILE CONVENTIONS

```
FORMAT: All genome/ files use agent-to-agent language.
STRUCTURE: Each file follows →
  # Title
  ## SECTION_NAME
  ### SUBSECTION
  - KEY: value
  - SPEC: { property: value }

NOTATION:
  →       dependency (A requires B)
  ↔       bidirectional integration
  ⇢       alternative to
  ⊃       contains / parent-child
  [R]     required
  [O]     optional
  [C]     conditional (depends on website type)
  [D]     default value (use unless overridden)
  ✅      implemented / verified
  ❌      not implemented / failed
  ⚠️      warning / gotcha

CODE BLOCKS:
  ```tsx     — React/Next.js component code
  ```css     — Tailwind/CSS specification
  ```bash    — CLI commands
  ```json    — Configuration
  ```spec    — Structured specification (custom format)

CROSS-REFERENCES:
  → see: 03-atomic-elements.md#button
  Format: filename.md#heading-slug
```

## TECH STACK (DEFAULT)

```spec
RUNTIME:        node.js >= 22 LTS
LANGUAGE:       typescript 5.x [R]
FRAMEWORK:      next.js 16 (app router) [R]
STYLING:        tailwind css 4.x [R]
COMPONENTS:     shadcn/ui (latest) [R]
FONT:           geist sans + geist mono [D]
ICONS:          lucide-react [D]
PACKAGE_MGR:    pnpm [D] | npm | bun
DEPLOYMENT:     vercel [R]
VERSION_CTRL:   git + github [R]
AUTH:           clerk [C] — when auth needed
DATABASE:       neon (postgres) [C] — when persistent data needed
CACHE:          upstash redis [C] — when caching needed
PAYMENTS:       stripe [C] — when monetization needed
EMAIL:          resend [C] — when email needed
AI:             ai sdk 6 + ai gateway [C] — when AI features needed
ANALYTICS:      vercel analytics + speed insights [D]
```

## ATOMIC DESIGN HIERARCHY

```
LEVEL 0: Design Tokens (DNA)
  → see: 02-design-tokens.md
  Colors, typography, spacing, shadows, radii, animations.
  Change tokens → everything downstream changes.

LEVEL 1: Atoms (indivisible elements)
  → see: 03-atomic-elements.md
  Button, Input, Label, Icon, Badge, Avatar, Separator, etc.
  Each atom has: variants, sizes, states, accessibility, code template.

LEVEL 2: Molecules (atom compositions)
  → see: 04-components.md#molecules
  SearchBar = Input + Button + Icon
  FormField = Label + Input + ErrorMessage
  NavLink = Icon + Text + Badge

LEVEL 3: Organisms (molecule compositions)
  → see: 04-components.md#organisms
  Navbar = Logo + NavLinks + SearchBar + AuthButtons
  HeroSection = Heading + Paragraph + CTAButtons + Image
  PricingCard = Heading + Price + FeatureList + CTAButton

LEVEL 4: Templates (page layout skeletons)
  → see: 05-page-templates.md
  DashboardLayout = Sidebar + TopNav + MainContent + Footer
  MarketingLayout = Navbar + FullWidthContent + Footer
  AuthLayout = CenteredCard

LEVEL 5: Pages (templates filled with real data + interactions)
  → see: 06-page-types.md
  /dashboard = DashboardLayout + StatsCards + RecentActivity + Charts
  /pricing = MarketingLayout + PricingTable + FAQ + CTA
  /login = AuthLayout + LoginForm + SocialButtons + ForgotLink
```

## EXECUTION MODEL

```
STEP 1: Read human-provided project-checklist.md
  → Extract: brand, domain, website type, features needed, env vars

STEP 2: Generate PRD (fill 18-prd-template.md)
  → Define: pages, user stories, acceptance criteria

STEP 3: Generate Tech RD (fill 19-tech-rd-template.md)
  → Define: architecture, data model, API routes, component tree

STEP 4: Scaffold project
  → npx create-next-app@latest → configure → install dependencies
  → see: 15-generation-sop.md#scaffold

STEP 5: Implement design tokens
  → Configure tailwind + shadcn themes
  → see: 02-design-tokens.md

STEP 6: Build atoms → molecules → organisms → templates → pages
  → Bottom-up construction
  → see: 03 → 04 → 05 → 06

STEP 7: Wire interactions + state + data
  → see: 07-interactions.md, 08-state-data.md

STEP 8: Add invisible layer
  → see: 09-invisible-layer.md

STEP 9: Add agent-browsable layer
  → see: 10-agent-browsable.md

STEP 10: Handle error/edge cases
  → see: 11-error-edge-cases.md

STEP 11: Responsive pass
  → see: 12-responsive.md

STEP 12: Content population
  → see: 13-content-strategy.md

STEP 13: Self-validation
  → Run checklist from 16-validation.md
  → Spawn review sub-agent if available

STEP 14: Git commit + push + deploy
  → git add -A && git commit -m "feat: initial website build" && git push
  → Vercel auto-deploys from git push
  → Verify deployment URL loads correctly

STEP 15: Report completion
  → Output: deployment URL, page count, component count, validation score
```

## QUALITY GATES

```
GATE 1 (after Step 6): All pages render without errors
GATE 2 (after Step 7): All interactions functional
GATE 3 (after Step 11): Responsive at 375px, 768px, 1440px
GATE 4 (after Step 13): Validation score >= 90%
GATE 5 (after Step 14): Live URL accessible, no console errors
```
