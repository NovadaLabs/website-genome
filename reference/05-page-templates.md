# 05 — Page Templates (Level 4)

## PURPOSE

```spec
Templates = reusable page layout skeletons.
A template defines WHERE content zones live, not WHAT content is in them.
Every page in every website maps to one of these templates (or a hybrid).
Implementation: Next.js layout.tsx files + page-level wrappers.
```

---

## TEMPLATE CATALOG

### 5.1 MARKETING LAYOUT

```spec
USE: Landing pages, product pages, pricing pages, about pages
STRUCTURE:
  ┌──────────────────────────────────────┐
  │            NAVBAR (sticky)            │
  ├──────────────────────────────────────┤
  │                                      │
  │          FULL-WIDTH CONTENT          │
  │     (sections stack vertically)      │
  │                                      │
  ├──────────────────────────────────────┤
  │              FOOTER                  │
  └──────────────────────────────────────┘

CONTENT ZONES:
  - Hero section (above fold)
  - Feature sections
  - Social proof / testimonials
  - Pricing
  - CTA
  - FAQ

IMPLEMENTATION:
  app/(marketing)/layout.tsx:
    <Navbar />
    <main>{children}</main>
    <Footer />

RESPONSIVE:
  - Container: max-w-7xl mx-auto px-4 md:px-6 lg:px-8
  - Sections stack vertically at all breakpoints
  - Navbar collapses to hamburger on mobile
```

### 5.2 DASHBOARD LAYOUT

```spec
USE: SaaS apps, admin panels, internal tools (post-login)
STRUCTURE:
  ┌──────┬───────────────────────────────┐
  │      │         TOP BAR               │
  │      ├───────────────────────────────┤
  │ SIDE │                               │
  │ BAR  │       MAIN CONTENT            │
  │      │   (scrollable, padded)        │
  │      │                               │
  └──────┴───────────────────────────────┘

SIDEBAR:
  Width: w-64 (expanded), w-16 (collapsed)
  Content: logo, nav groups, user menu at bottom
  Collapsible: toggle button or auto-collapse on resize

TOP BAR:
  Content: sidebar trigger, breadcrumb, search, notifications, user menu
  Height: h-14
  Sticky: yes

MAIN CONTENT:
  Padding: p-6
  Max width: none (fills available space) or max-w-6xl for readability

IMPLEMENTATION:
  app/(dashboard)/layout.tsx:
    <SidebarProvider>
      <Sidebar>{/* nav */}</Sidebar>
      <main className="flex-1 flex flex-col">
        <TopBar />
        <div className="flex-1 overflow-auto p-6">{children}</div>
      </main>
    </SidebarProvider>

RESPONSIVE:
  desktop (lg+):  sidebar visible, main content beside
  tablet (md):    sidebar collapsed (icons only), expand on hover
  mobile (<md):   sidebar hidden, accessible via hamburger → Sheet
```

### 5.3 AUTH LAYOUT

```spec
USE: Login, signup, forgot password, reset password pages
STRUCTURE:
  ┌──────────────────────────────────────┐
  │                                      │
  │            CENTERED CARD             │
  │      (vertically & horizontally)     │
  │                                      │
  └──────────────────────────────────────┘

VARIANTS:
  simple       centered card only, minimal branding
  split        left: brand/illustration, right: form
  branded      background gradient/image + centered card

IMPLEMENTATION:
  app/(auth)/layout.tsx:
    <div className="flex min-h-svh items-center justify-center p-4">
      <div className="w-full max-w-sm">{children}</div>
    </div>

  // Split variant:
    <div className="flex min-h-svh">
      <div className="hidden md:flex flex-1 bg-muted items-center justify-center">
        {/* brand content */}
      </div>
      <div className="flex flex-1 items-center justify-center p-4">
        <div className="w-full max-w-sm">{children}</div>
      </div>
    </div>

RESPONSIVE:
  mobile:  full-width card, no split
  desktop: split view (if variant = split)
```

### 5.4 DOCS LAYOUT

```spec
USE: Documentation, knowledge base, help center
STRUCTURE:
  ┌──────────────────────────────────────┐
  │            NAVBAR (sticky)            │
  ├──────┬────────────────┬──────────────┤
  │      │                │              │
  │ SIDE │    CONTENT     │    TOC       │
  │ NAV  │  (prose area)  │  (on this   │
  │      │                │   page)     │
  │      │                │              │
  └──────┴────────────────┴──────────────┘

SIDEBAR NAV:
  Width: w-64
  Content: hierarchical page tree (collapsible sections)
  Sticky: yes (scrolls independently)
  Search: at top

CONTENT:
  Width: max-w-3xl
  Typography: prose styling (larger text, wider line-height)
  Features: code blocks with copy, headings with anchors, tables

TOC (Table of Contents):
  Width: w-48
  Content: auto-generated from h2/h3 headings
  Sticky: yes, highlight current section on scroll
  Hidden on: tablet and mobile (show as dropdown instead)

IMPLEMENTATION:
  app/docs/layout.tsx:
    <Navbar />
    <div className="container flex gap-8">
      <aside className="hidden md:block w-64 shrink-0 sticky top-14 h-[calc(100svh-3.5rem)] overflow-auto">
        <DocsNav />
      </aside>
      <main className="flex-1 min-w-0 py-8 prose dark:prose-invert">
        {children}
      </main>
      <aside className="hidden xl:block w-48 shrink-0 sticky top-14 h-[calc(100svh-3.5rem)]">
        <TableOfContents />
      </aside>
    </div>

RESPONSIVE:
  desktop (xl+):  sidebar + content + TOC (3-column)
  tablet (md-xl): sidebar + content (2-column), TOC hidden
  mobile (<md):   content only, sidebar via hamburger, TOC via dropdown
```

### 5.5 BLOG LAYOUT

```spec
USE: Blog posts, articles, news
STRUCTURE:
  ┌──────────────────────────────────────┐
  │              NAVBAR                  │
  ├──────────────────────────────────────┤
  │           ARTICLE HEADER             │
  │   (title, author, date, image)       │
  ├──────────────────────────────────────┤
  │          ARTICLE CONTENT             │
  │    (prose, max-w-3xl, centered)      │
  ├──────────────────────────────────────┤
  │          RELATED ARTICLES            │
  ├──────────────────────────────────────┤
  │              FOOTER                  │
  └──────────────────────────────────────┘

ARTICLE HEADER:
  - Title: text-4xl font-bold
  - Meta: author avatar + name + date + reading time + tags
  - Cover image: full-width or contained, aspect-ratio 16/9

CONTENT:
  - Max width: max-w-3xl mx-auto
  - Typography: prose dark:prose-invert prose-lg
  - Code blocks: syntax highlighted with copy button
  - Images: full-bleed option (break out of max-width)

IMPLEMENTATION:
  app/blog/[slug]/page.tsx (dynamic route)
  Content from: MDX, CMS, or database
```

### 5.6 E-COMMERCE LAYOUT

```spec
USE: Product listings, product detail, cart, checkout
STRUCTURE (listing):
  ┌──────────────────────────────────────┐
  │              NAVBAR                  │
  ├──────┬───────────────────────────────┤
  │      │                               │
  │FILTER│      PRODUCT GRID             │
  │ SIDE │    (card grid, paginated)     │
  │ BAR  │                               │
  │      │                               │
  └──────┴───────────────────────────────┘

STRUCTURE (product detail):
  ┌──────────────────────────────────────┐
  │              NAVBAR                  │
  ├──────────────────────────────────────┤
  │  IMAGE GALLERY  │  PRODUCT INFO     │
  │  (left 50%)     │  (right 50%)      │
  │                 │  name, price,      │
  │                 │  options, add to   │
  │                 │  cart button       │
  ├──────────────────────────────────────┤
  │         PRODUCT TABS                 │
  │  (description, reviews, specs)       │
  ├──────────────────────────────────────┤
  │       RELATED PRODUCTS               │
  └──────────────────────────────────────┘

RESPONSIVE:
  Product grid: 1 col (mobile), 2 col (tablet), 3-4 col (desktop)
  Product detail: stacked (mobile), side-by-side (desktop)
  Filters: Sheet/drawer on mobile, sidebar on desktop
```

### 5.7 SETTINGS LAYOUT

```spec
USE: User settings, account settings, admin settings
STRUCTURE:
  ┌──────────────────────────────────────┐
  │           DASHBOARD SHELL            │
  ├──────────────────────────────────────┤
  │  TABS NAV  │    SETTINGS FORM       │
  │  (vertical │    (Card with form)    │
  │   on lg+)  │                        │
  └────────────┴────────────────────────┘

VARIANTS:
  tabs-top      horizontal tabs above content (simple settings)
  tabs-side     vertical tabs left, content right (many categories)
  nav-side      sidebar nav within settings (like GitHub settings)

RESPONSIVE:
  desktop:  side tabs + form
  mobile:   top tabs (horizontal scroll) or select dropdown + form
```

### 5.8 WIZARD / STEPPER LAYOUT

```spec
USE: Onboarding, multi-step forms, checkout flow
STRUCTURE:
  ┌──────────────────────────────────────┐
  │           STEP INDICATOR             │
  │     (1 ── 2 ── 3 ── 4)             │
  ├──────────────────────────────────────┤
  │                                      │
  │          STEP CONTENT                │
  │     (centered, max-w-lg)            │
  │                                      │
  ├──────────────────────────────────────┤
  │     BACK          NEXT/SUBMIT       │
  └──────────────────────────────────────┘

STEP INDICATOR:
  - Numbered circles connected by lines
  - States: completed (check icon), current (filled), upcoming (outline)
  - Clickable: allow jumping back to completed steps

IMPLEMENTATION:
  - Use URL searchParams for step state (?step=2)
  - Or use React state with animated transitions
  - Validate each step before allowing next
```

### 5.9 FULL-SCREEN LAYOUT

```spec
USE: Chat apps, editors, maps, presentations, focus modes
STRUCTURE:
  ┌──────────────────────────────────────┐
  │  THIN TOOLBAR (h-10, optional)       │
  ├──────────────────────────────────────┤
  │                                      │
  │        FULL-SCREEN CONTENT           │
  │      (no padding, no scroll)         │
  │                                      │
  └──────────────────────────────────────┘

CHARACTERISTICS:
  - No navbar, no footer, no sidebar
  - Content fills entire viewport: h-svh w-full
  - Optional thin toolbar at top
  - Escape route: logo link or close button back to main app
```

### 5.10 EMPTY / COMING SOON LAYOUT

```spec
USE: Placeholder pages, maintenance, coming soon, 404, 500
STRUCTURE:
  ┌──────────────────────────────────────┐
  │                                      │
  │         CENTERED MESSAGE             │
  │    (icon + heading + text + CTA)     │
  │                                      │
  └──────────────────────────────────────┘

VARIANTS:
  404:          "Page not found" + link to home
  500:          "Something went wrong" + retry button
  coming-soon:  brand + "Coming soon" + email signup
  maintenance:  "Under maintenance" + estimated return time
```

---

## TEMPLATE DECISION MATRIX

```spec
PAGE TYPE               → TEMPLATE
────────────────────────────────────
Landing page            → Marketing Layout
Product/feature page    → Marketing Layout
Pricing page            → Marketing Layout
About/team page         → Marketing Layout
Login/signup            → Auth Layout
Dashboard               → Dashboard Layout
Settings                → Settings Layout (inside Dashboard)
Data list/table         → Dashboard Layout
Detail view             → Dashboard Layout
Onboarding              → Wizard Layout
Documentation           → Docs Layout
Blog post               → Blog Layout
Blog listing            → Marketing Layout (with card grid)
Product listing         → E-Commerce Layout
Product detail          → E-Commerce Layout
Cart/checkout           → Wizard Layout or E-Commerce
Chat/messaging          → Full-Screen Layout
Editor                  → Full-Screen Layout
404/500                 → Empty Layout
Coming soon             → Empty Layout
```

## NEXT.JS ROUTE GROUP PATTERN

```spec
Route groups organize pages by layout without affecting URL:

app/
├── (marketing)/           → Marketing Layout
│   ├── layout.tsx         Navbar + Footer
│   ├── page.tsx           Landing page (/)
│   ├── pricing/page.tsx   /pricing
│   ├── about/page.tsx     /about
│   └── blog/
│       ├── page.tsx       /blog (listing)
│       └── [slug]/page.tsx /blog/:slug (article)
│
├── (auth)/                → Auth Layout
│   ├── layout.tsx         Centered card
│   ├── login/page.tsx     /login
│   ├── signup/page.tsx    /signup
│   └── forgot/page.tsx    /forgot
│
├── (dashboard)/           → Dashboard Layout
│   ├── layout.tsx         Sidebar + TopBar
│   ├── dashboard/page.tsx /dashboard
│   ├── settings/page.tsx  /settings
│   └── [resource]/        /[resource] (dynamic)
│       ├── page.tsx       listing
│       └── [id]/page.tsx  detail
│
├── (docs)/                → Docs Layout
│   ├── layout.tsx         Sidebar nav + TOC
│   └── docs/
│       └── [...slug]/page.tsx /docs/:path
│
├── layout.tsx             Root layout (html, body, fonts, providers)
├── not-found.tsx          404 page
└── error.tsx              500 page
```
