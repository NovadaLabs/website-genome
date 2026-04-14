# 21 — UI/UX Design Patterns

## PURPOSE

```spec
This file answers: "What does good design look like, and how do I get there?"
It exists because the genome had no quality bar for visual design — only code checks.

WHEN TO READ: Before any visual polish pass, design improvement task, or when building
a site that must compete with Linear/Vercel/Stripe quality.

PRINCIPLE: NEVER design from imagination. Always anchor to reference sites.
```

---

## 21.1 REFERENCE-DRIVEN DESIGN WORKFLOW

```spec
RULE: NEVER design from imagination. Always:
  1. Pick 2-3 reference sites at your target quality bar
  2. Open your site and references side-by-side in a browser
  3. Identify the 5 biggest VISUAL gaps (not code gaps)
  4. Fix one gap at a time, verifying in browser after each change
  5. Never do bulk text replacements for visual changes
  6. Check BOTH light and dark mode after every change

PROCESS (step by step):
  a. Open the site in Chrome at 1440px desktop
  b. Open 2 reference sites in adjacent tabs
  c. Scan: typography, spacing, card treatment, color usage, hover states
  d. List the 5 most glaring differences
  e. For each gap → find the component → read the reference approach → adapt → implement → verify
  f. One component per commit — never batch visual changes

ANTI-PATTERNS:
  ✗ Changing 20 files at once and refreshing
  ✗ Copy-pasting reference CSS verbatim
  ✗ Only checking dark mode (most users are on light)
  ✗ Declaring "done" from looking at code, not the rendered page
```

---

## 21.2 REFERENCE DATABASE

```spec
MASTER LIST: https://github.com/alexpate/awesome-design-systems
  200+ design systems. Use this as the canonical reference library.

TIER 1 — Developer Platform / SaaS (most relevant):
  Vercel Geist       https://vercel.com/geist — gold standard for dev tool UI
                     Restraint: large whitespace, hairline borders, systematic spacing
  Linear             https://linear.app — premium dark mode, minimal decoration
                     Restraint: 4-weight color system, tight typography, clean icons
  Stripe             https://stripe.com/docs — documentation excellence, typography hierarchy
                     Strength: paragraph density + heading contrast, visual rhythm
  Resend             https://resend.com — clean developer tool, sharp mono + sans pairing
  Clerk              https://clerk.com — auth page gold standard, conversion-focused

TIER 2 — Component Systems (reference for individual patterns):
  Shadcn/ui          https://ui.shadcn.com — our component base, know its limits
  Radix UI           https://radix-ui.com/themes — accessible primitives with good defaults
  Shopify Polaris    https://polaris.shopify.com — comprehensive component guidelines
  IBM Carbon         https://carbondesignsystem.com — enterprise patterns, accessibility

TIER 3 — Discovery (when building novel page types):
  Awwwards           https://awwwards.com — cutting edge interaction patterns
  Godly              https://godly.website — modern marketing site patterns
  Mobbin             https://mobbin.com — mobile + web UI patterns

QUERY BY PAGE TYPE:
  Landing page    → Vercel, Resend, Railway
  Pricing page    → Vercel, Linear, Stripe
  Dashboard       → Linear, Vercel Analytics, Railway
  Auth pages      → Clerk, Supabase, Railway
  Docs            → Stripe, Linear, Mintlify
  API console     → Stripe Dashboard, RapidAPI
```

---

## 21.3 DESIGN QUALITY CHECKLIST (per page)

```spec
Run this checklist when reviewing any page visually.

TEXT HIERARCHY: 4 levels max
  Level 1 — Display:  page titles, hero text
    → text-3xl to text-5xl font-bold tracking-tight
  Level 2 — Heading:  section titles, card titles, dialog titles
    → text-xl to text-2xl font-semibold
  Level 3 — Body:     paragraphs, descriptions, list items
    → text-sm leading-relaxed text-muted-foreground
  Level 4 — Caption:  labels, timestamps, badges, helper text
    → text-xs text-muted-foreground
  FAIL if: two adjacent elements use the same size with no weight difference
  FAIL if: body text uses text-base or larger (too big for dense dashboards)
  FAIL if: more than 4 distinct size/weight combinations on one page

SPACING: Consistent rhythm
  Marketing section gaps:  py-20 to py-24 (never mix py-16 and py-32 on same page)
  Dashboard section gaps:  gap-6 (between cards), p-6 (page padding)
  Card internal padding:   p-5 to p-6 (never p-3 — too cramped)
  FAIL if: arbitrary spacing values (e.g. py-[72px]) without documented reason
  FAIL if: spacing values inconsistent between similar elements on same page

BORDERS: Theme-aware
  Default:  border-border (semantic — works in light + dark)
  Hover:    hover:border-foreground/15
  Active:   ring-1 ring-primary/30
  FAIL if: border-white/[0.06] in theme-aware components (invisible on light)
  FAIL if: border-[#hex] in component files (hardcoded, theme-breaking)

COLORS: Semantic tokens only in components
  Background surfaces: bg-background, bg-card, bg-muted
  Text:                text-foreground, text-muted-foreground
  Brand accent:        text-primary, bg-primary
  FAIL if: text-white used on theme-aware page (invisible in light mode)
  FAIL if: bg-[#hex] or bg-zinc-900 in component outside globals.css
  EXCEPTION: Marketing pages with explicit dark-only wrapper may use text-white

CARDS: Standard treatment
  Base:       rounded-xl border border-border bg-card
  Hover:      hover:border-foreground/15
  Interactive: cursor-pointer + hover effect + transition-colors
  FAIL if: cards have no border (they disappear in low-contrast themes)
  FAIL if: card hover effect uses transition-all (causes perceived lag)

BUTTONS:
  Transition: transition-colors — NEVER transition-all
  Press:      active:translate-y-px (subtle, not scale transforms)
  Primary CTA: shadow glow on marketing pages (btn-primary class)
  FAIL if: button click feels laggy or delayed
  FAIL if: no hover state (plain text button with no feedback)

EMPTY STATES:
  Pattern: centered icon (48px, muted) + heading (text-sm font-medium) + description + CTA
  FAIL if: empty list shows nothing or raw "No data" text

LOADING STATES:
  Pattern: Skeleton matching exact shape of loaded content
  FAIL if: Spinner only (no shape skeleton — causes layout shift on load)
```

---

## 21.4 "IMPROVE EXISTING SITE" SOP

```spec
WHEN: Site works functionally but looks generic, inconsistent, or unpolished.
This is NOT a rebuild — it is targeted visual improvement.

STEP 1: Visual audit (browser only, no code)
  a. Open site at 1440px desktop
  b. Open 2 references at same width
  c. Write down 5 specific visual gaps (not vague — be precise):
     BAD:  "looks dark and heavy"
     GOOD: "heading font-size is text-lg but should be text-2xl for a section title"
     GOOD: "card has border-white/[0.06] which is invisible in light mode"
     GOOD: "CTA button has transition-all causing 200ms perceived click lag"

STEP 2: Prioritize gaps
  Order: broken → inconsistent → polish
  1. Theme-breaking bugs (invisible borders, hardcoded colors) — fix first
  2. Typography hierarchy inconsistencies — second
  3. Card/surface inconsistencies — third
  4. Hover state and animation polish — last

STEP 3: Fix one gap at a time
  For each gap:
    a. Find the specific file + component
    b. Read reference site's approach (not pixel-copy — understand the principle)
    c. Make the minimal change
    d. Refresh browser immediately
    e. Verify in light mode AND dark mode
    f. Move to next gap only if this one is resolved

STEP 4: Cross-page consistency check
  After fixing individual components, do a sweep:
    Open: home, pricing, dashboard, auth pages in sequence
    Check: do all pages feel like they belong to the same product?
    If inconsistent: find the mismatched element and apply the winning pattern.

ANTI-PATTERNS:
  ✗ Editing 10 files and refreshing once
  ✗ Using bulk find+replace for styling changes
  ✗ Checking only one page after change
  ✗ Only verifying in dark mode (default or current theme)
  ✗ Declaring done from code review, not browser verification
```

---

## 21.5 THEME-SAFE STYLING RULES

```spec
⚠️ THESE RULES EXIST BECAUSE REAL BUGS HIT PRODUCTION. NOT THEORETICAL.

RULE 1: Never hardcode hex colors in TSX/component files
  BAD:  className="bg-[#0f0f13] border-[#16161d] text-[#fafafa]"
  GOOD: className="bg-card border-border text-foreground"
  WHY:  Hex values don't switch when theme changes. Light mode shows dark colors.

RULE 2: Never use opacity-based white borders in theme-aware components
  BAD:  className="border-white/[0.06]"
  GOOD: className="border-border"
  WHY:  border-white on white background = invisible border in light mode.

RULE 3: Dynamic Tailwind class names don't compile
  BAD:  className={`bg-${color}-500/10`}          // purged at build time
  GOOD: const colorMap = {
          blue:   "bg-blue-500/10 text-blue-500",
          green:  "bg-green-500/10 text-green-500",
          red:    "bg-red-500/10 text-red-500",
        };
        className={colorMap[color]}
  WHY:  Tailwind scans for literal class strings at build time. Interpolated strings
        are not detected and the class never makes it to the CSS output.

RULE 4: Marketing pages can use force-dark; dashboards cannot
  Marketing (ok):   <div className="dark bg-background text-foreground">
  Dashboard (required): must be theme-safe — inherits system or user preference
  WHY:  Dashboard users have a theme preference. Forcing dark overrides their choice.

RULE 5: Use transition-colors for buttons and interactive elements, never transition-all
  BAD:  className="transition-all duration-200"
  GOOD: className="transition-colors duration-150"
  WHY:  transition-all also transitions padding, margin, width, height. On buttons,
        this creates 150-200ms perceived click lag. transition-colors targets only
        color/border-color/background-color — imperceptible.

RULE 6: Avoid scale transforms for button press states
  BAD:  active:scale-[0.98]                // causes layout reflow
  GOOD: active:translate-y-px              // GPU-composited, no reflow
  WHY:  scale triggers layout recalculation. translateY is GPU-only.

SEMANTIC TOKEN REFERENCE (always prefer these):
  bg-background      → page background (switches with theme)
  bg-card            → card/panel surface
  bg-muted           → subtle background, disabled states
  bg-primary         → brand primary (indigo/blue typically)
  bg-secondary       → secondary surface (slightly offset from bg)
  text-foreground    → primary text
  text-muted-foreground → secondary/muted text
  border-border      → default separator/border color
  ring-ring          → focus ring color
```

---

## 21.6 COMMON PAGE-TYPE DESIGN SPECS

```spec
LANDING PAGE (marketing):
  Hero:
    - Eyebrow label: text-xs uppercase tracking-wide text-primary font-medium
    - Headline: text-4xl to text-5xl font-bold tracking-tight (40-60px)
    - Subheadline: text-lg to text-xl text-muted-foreground (max-w-[600px])
    - CTA buttons: large (h-11), primary + secondary pair, glow on primary
    - Background: gradient blob OR grid pattern, not solid flat color
  Features section:
    - Grid: 3 columns on desktop, 1 on mobile
    - Card: icon (32px, primary color) + title (text-lg font-semibold) + body (text-sm)
    - Section gap: py-20 to py-24
  Social proof:
    - Logo bar: 4-6 company logos, muted/grayscale, centered
    - Testimonials: quote card with avatar + name + role

PRICING PAGE:
  Layout: 3-tier column grid (Starter/Pro/Enterprise)
  Recommended tier: scale(1.02) or ring-1 ring-primary visual highlight
  Price display: font-mono text-4xl font-bold + /month suffix
  Feature list: check icons (text-primary for included, muted for excluded)
  CTA: full-width button per tier

DASHBOARD OVERVIEW:
  Stats row: 3-4 metric cards at top (icon + value + label + delta)
  Metric card: p-5 rounded-xl border bg-card, hover:border-foreground/15
  Charts section: below stats, full-width or 2-col grid
  Recent activity: right sidebar or below charts

AUTH PAGES:
  Layout option A: centered card (max-w-sm) with subtle background
  Layout option B: split (left = branding/visual, right = form)
  Card: shadow-md on light, border on dark
  Primary CTA: full-width, prominent
  Highlight any free credit or incentive above the CTA button
```

---

## 21.7 QUALITY REFERENCE SITES BY CATEGORY

```spec
→ When building a new page type, open these BEFORE writing code.

API Platform / Developer Tool:
  fal.ai            https://fal.ai           — AI API platform, dark with glow
  Replicate         https://replicate.com    — simple, clean, developer-first
  Supabase          https://supabase.com     — dark mode excellence, docs structure
  Railway           https://railway.app      — minimal, infrastructure tool

SaaS / Subscription:
  Linear            https://linear.app       — premium minimal, dark mode
  Vercel            https://vercel.com       — design system gold standard
  Notion            https://notion.so        — accessible, high readability
  Loom              https://loom.com         — video SaaS, warm palette

E-commerce / Marketplace:
  Shopify           https://shopify.com      — conversion-optimized
  Gumroad           https://gumroad.com      — creator economy patterns

Documentation:
  Stripe Docs       https://stripe.com/docs  — the benchmark for API docs
  Mintlify          https://mintlify.com     — modern docs platform
  Radix Docs        https://radix-ui.com     — component docs pattern
```
