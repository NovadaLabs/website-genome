# 01 — First Principles

## WHAT IS A WEBSITE?

A website is reducible to exactly 8 primitives. Every website ever built is a composition of these 8, no exceptions.

```spec
PRIMITIVE 1: STRUCTURE (HTML)
  DEFINITION: Hierarchical tree of elements defining WHAT exists on the page
  IRREDUCIBLE: yes — without structure, nothing renders
  AGENT_CAPABILITY: full — agents can generate any HTML structure
  ATOMS: element, attribute, text node, comment

PRIMITIVE 2: STYLE (CSS)
  DEFINITION: Visual properties defining HOW elements look
  IRREDUCIBLE: yes — without style, raw HTML is unusable
  AGENT_CAPABILITY: full — agents can generate any CSS
  ATOMS: property, value, selector, media query, keyframe, variable

PRIMITIVE 3: BEHAVIOR (JAVASCRIPT)
  DEFINITION: Logic defining HOW elements respond to events
  IRREDUCIBLE: yes — without behavior, page is static
  AGENT_CAPABILITY: full — agents can generate any JS/TS
  ATOMS: event listener, handler function, state mutation, side effect

PRIMITIVE 4: DATA
  DEFINITION: Content displayed on the page (text, images, numbers)
  IRREDUCIBLE: yes — without data, page is empty
  AGENT_CAPABILITY: partial — agent can generate placeholder/AI content,
    but real business data must come from human or API
  ATOMS: string, number, boolean, array, object, blob (image/video/file)

PRIMITIVE 5: ROUTING
  DEFINITION: Mapping from URL path → which content to serve
  IRREDUCIBLE: yes — without routing, only one page exists
  AGENT_CAPABILITY: full — file-system routing in Next.js is automatic
  ATOMS: path segment, dynamic parameter, catch-all, redirect, rewrite

PRIMITIVE 6: STATE
  DEFINITION: Client-side memory persisting across interactions
  IRREDUCIBLE: yes — without state, every click resets everything
  AGENT_CAPABILITY: full — agents can implement any state pattern
  ATOMS: local state (useState), global state (context/store), URL state (searchParams),
    server state (cache), persistent state (localStorage/cookies/DB)

PRIMITIVE 7: NETWORK
  DEFINITION: Communication between browser and server
  IRREDUCIBLE: conditional — static sites don't need it, dynamic sites do
  AGENT_CAPABILITY: full — agents can implement any API pattern
  ATOMS: request, response, headers, body, status code, WebSocket message

PRIMITIVE 8: ENVIRONMENT
  DEFINITION: Runtime context (browser APIs, server APIs, env vars, secrets)
  IRREDUCIBLE: yes — code behaves differently in different environments
  AGENT_CAPABILITY: partial — agent can write code for any environment,
    but cannot create accounts or provision secrets
  ATOMS: env variable, browser API, server API, file system, database connection
```

## CAN AN AI AGENT BUILD A WEBSITE?

```spec
CAPABILITY AUDIT:

TASK                          | AGENT CAN? | NOTES
------------------------------|------------|------
Write HTML/JSX                | YES        | Full capability
Write CSS/Tailwind            | YES        | Full capability
Write TypeScript              | YES        | Full capability
Write React components        | YES        | Full capability
Configure Next.js             | YES        | Full capability
Set up routing                | YES        | File-system routing = create files
Implement interactions        | YES        | Event handlers, state management
Call APIs                     | YES        | fetch, server actions, route handlers
Set up database schema        | YES        | Drizzle/Prisma migrations
Write tests                   | YES        | Vitest, Playwright
Configure deployment          | YES        | vercel.json / vercel.ts
Git operations                | YES        | commit, push, branch, PR
Run CLI commands              | YES        | npm, npx, vercel, git
Generate content (text)       | YES        | AI-generated copy
Generate content (images)     | YES        | AI image generation via AI Gateway
SEO optimization              | YES        | Meta tags, sitemap, schema.org
Accessibility compliance      | YES        | ARIA, semantic HTML, keyboard nav
Performance optimization      | YES        | Lazy loading, code splitting, caching
Security hardening            | YES        | CSP, CORS, input sanitization
Create accounts               | NO         | Human must create (GitHub, Vercel, etc.)
Provide API keys/secrets      | NO         | Human must provision
Make business decisions       | NO         | Brand name, pricing, target audience
Register domains              | NO         | Human must purchase
Accept terms of service       | NO         | Human must accept
Provide real business data    | NO         | Customer lists, product catalogs, etc.
Verify payment integration    | NO         | Human must test real transactions

CONCLUSION: Agent can do ~85% of website construction autonomously.
The remaining ~15% is account setup, secrets, business decisions, and domain.
All 15% can be front-loaded into a human prep phase (see: human-setup/).
```

## IS DESIGN LOGIC UNIVERSAL ACROSS WEBSITE TYPES?

```spec
ANSWER: YES at the atomic level. NO at the composition level.

UNIVERSAL (same across ALL websites):
  - HTML elements (div, button, input, img, etc.)
  - CSS properties (color, padding, margin, flex, grid, etc.)
  - Interaction patterns (click, hover, scroll, submit, etc.)
  - Responsive breakpoints (mobile, tablet, desktop)
  - Accessibility requirements (ARIA, keyboard nav, contrast)
  - Performance patterns (lazy load, cache, compress)
  - Security patterns (sanitize, validate, CSP)
  - State patterns (local, global, server, URL)

TYPE-DEPENDENT (varies by website category):
  - Page count and hierarchy (landing page: 1-5 pages; SaaS: 20-50+)
  - Auth complexity (blog: none; SaaS: full RBAC)
  - Data patterns (static content vs real-time dashboards)
  - Payment flows (free vs freemium vs enterprise)
  - Content density (marketing: sparse; docs: dense)
  - Interaction density (portfolio: low; dashboard: high)
  - API complexity (brochure: zero; marketplace: dozens)

IMPLICATION: Build the atoms universally, compose them type-specifically.
The genome documents atoms universally (03-atomic-elements.md).
Type-specific composition is in 06-page-types.md.
```

## WEBSITE TYPE TAXONOMY

```spec
CATEGORY 1: MARKETING / LANDING
  PURPOSE: convert visitors → customers
  PAGES: 1-10
  AUTH: none (or minimal for gated content)
  DATA: static or CMS-driven
  EXAMPLES: product pages, startup sites, agency sites
  KEY_COMPONENTS: hero, features, pricing, testimonials, CTA, FAQ
  COMPLEXITY: LOW-MEDIUM

CATEGORY 2: SAAS APPLICATION
  PURPOSE: deliver software functionality via browser
  PAGES: 20-100+
  AUTH: full (signup, login, roles, permissions, org management)
  DATA: dynamic, user-specific, real-time
  EXAMPLES: dashboards, admin panels, project management, CRM
  KEY_COMPONENTS: sidebar, data tables, charts, forms, settings, billing
  COMPLEXITY: HIGH

CATEGORY 3: E-COMMERCE
  PURPOSE: sell physical/digital products
  PAGES: 10-1000+ (product pages scale)
  AUTH: customer accounts + admin
  DATA: product catalog, inventory, orders, reviews
  EXAMPLES: online stores, marketplaces, booking platforms
  KEY_COMPONENTS: product cards, cart, checkout, filters, search, reviews
  COMPLEXITY: HIGH

CATEGORY 4: CONTENT / MEDIA
  PURPOSE: publish and distribute content
  PAGES: 10-10000+ (articles/posts scale)
  AUTH: minimal (for comments/subscriptions)
  DATA: articles, media, categories, tags
  EXAMPLES: blogs, news sites, documentation, wikis
  KEY_COMPONENTS: article layout, sidebar, search, tags, pagination, TOC
  COMPLEXITY: MEDIUM

CATEGORY 5: PORTFOLIO / PERSONAL
  PURPOSE: showcase work or personal brand
  PAGES: 3-10
  AUTH: none
  DATA: static (projects, bio, contact)
  EXAMPLES: developer portfolios, photographer sites, resumes
  KEY_COMPONENTS: project cards, image galleries, contact form, timeline
  COMPLEXITY: LOW

CATEGORY 6: COMMUNITY / SOCIAL
  PURPOSE: connect users with each other
  PAGES: 10-50+
  AUTH: full (profiles, connections, permissions)
  DATA: user-generated content, feeds, messages
  EXAMPLES: forums, social networks, Q&A platforms
  KEY_COMPONENTS: feed, profile, messaging, notifications, reactions
  COMPLEXITY: HIGH

CATEGORY 7: DEVELOPER TOOLS
  PURPOSE: serve developer workflows
  PAGES: 5-30
  AUTH: API key management
  DATA: documentation, API playground, usage metrics
  EXAMPLES: API portals, SDK docs, developer dashboards
  KEY_COMPONENTS: code blocks, API reference, playground, usage charts, docs nav
  COMPLEXITY: MEDIUM-HIGH

CATEGORY 8: INTERNAL TOOLS
  PURPOSE: business operations (not public-facing)
  PAGES: 5-50
  AUTH: SSO/company auth
  DATA: business data, workflows, approvals
  EXAMPLES: admin dashboards, CMS backends, reporting tools
  KEY_COMPONENTS: data tables, forms, workflows, approvals, file uploads
  COMPLEXITY: MEDIUM-HIGH
```

## WHAT DOES THE AGENT NEED TO BUILD ANY OF THESE?

```spec
UNIVERSAL REQUIREMENTS (all website types):

KNOWLEDGE:
  - This document set (genome/*.md) [R]
  - Human-provided project checklist [R]
  - Framework documentation (Next.js, Tailwind, shadcn/ui) [available via Context7]

TOOLS:
  - Code editor (built-in to agent) [R]
  - Terminal/shell (Bash tool) [R]
  - File system (Read/Write/Edit tools) [R]
  - Web browser (for verification) [O]
  - Git CLI [R]
  - Node.js + pnpm [R]
  - Vercel CLI [R]

ENVIRONMENT:
  - Node.js >= 22 installed [R]
  - pnpm installed [R]
  - Git configured with auth [R]
  - Vercel CLI installed + authenticated [R]
  - GitHub repo created + accessible [R]
  - Environment variables provisioned [C]

CONDITIONAL REQUIREMENTS (type-dependent):
  - Auth provider (Clerk) — when website has user accounts
  - Database (Neon Postgres) — when website has persistent data
  - Cache (Upstash Redis) — when website needs caching
  - Payment processor (Stripe) — when website handles payments
  - Email service (Resend) — when website sends emails
  - AI Gateway — when website has AI features
  - CMS — when website has editor-managed content
  - File storage (Vercel Blob) — when website handles file uploads
```

## FIRST PRINCIPLES DECOMPOSITION

```
Q: What is the minimum needed to display something on screen?
A: 1 HTML file with 1 element. Everything else is composition.

Q: What is the minimum needed for a multi-page website?
A: A router mapping URLs to HTML. Next.js provides this via file system.

Q: What is the minimum needed for interactivity?
A: JavaScript event listeners. React abstracts this into component state + JSX.

Q: What is the minimum needed for styling?
A: CSS. Tailwind abstracts this into utility classes.

Q: What is the minimum needed for deployment?
A: Files on a server. Vercel provides this via git push.

Q: What is the minimum needed for production-readiness?
A: HTTPS + error handling + performance + accessibility + SEO.
   Vercel provides HTTPS. The rest is code-level implementation.

THEREFORE:
  Next.js + Tailwind + shadcn/ui + Vercel =
    minimum stack to build ANY production-ready website.
  Everything else (auth, db, payments) is additive based on type.
```

## DESIGN CONSISTENCY PRINCIPLE

```spec
RULE: All elements on a page share the same design tokens.
RULE: All pages on a site share the same component library.
RULE: All interactions on a site follow the same behavior patterns.

IMPLICATION:
  Define tokens ONCE → components inherit → pages inherit → site is consistent.
  Change a token → entire site updates.
  This is why 02-design-tokens.md is read BEFORE any component work.

EXCEPTION:
  Marketing pages may use different density/spacing than app pages.
  Solve with: two token sets (marketing + app) within the same system.
  → see: 02-design-tokens.md#variant-sets
```

## WHAT MAKES A WEBSITE "PRODUCTION-READY"?

```spec
CHECKLIST (all must be true):

FUNCTIONALITY:
  ☐ All pages render without errors
  ☐ All links navigate correctly
  ☐ All forms submit and validate
  ☐ All interactive elements respond to input
  ☐ Auth flow works (if applicable): signup → login → logout → password reset
  ☐ Payment flow works (if applicable): add to cart → checkout → confirm

VISUAL:
  ☐ Responsive at 375px (mobile), 768px (tablet), 1440px (desktop)
  ☐ Dark mode supported (if specified)
  ☐ No layout shifts (CLS < 0.1)
  ☐ No text overflow or truncation issues
  ☐ Consistent spacing, colors, typography across all pages

PERFORMANCE:
  ☐ Lighthouse Performance score >= 90
  ☐ LCP < 2.5s
  ☐ FID/INP < 200ms
  ☐ Images optimized (next/image, WebP/AVIF)
  ☐ Fonts optimized (next/font, preloaded)
  ☐ Bundle size reasonable (no unnecessary dependencies)

ACCESSIBILITY:
  ☐ Lighthouse Accessibility score >= 90
  ☐ All images have alt text
  ☐ All form inputs have labels
  ☐ Color contrast ratio >= 4.5:1 (AA)
  ☐ Keyboard navigable (tab order, focus indicators)
  ☐ Screen reader compatible (semantic HTML, ARIA)

SEO:
  ☐ Unique <title> and <meta description> per page
  ☐ Open Graph meta tags for social sharing
  ☐ sitemap.xml generated
  ☐ robots.txt configured
  ☐ Canonical URLs set
  ☐ Structured data (JSON-LD) where applicable

SECURITY:
  ☐ No secrets in client-side code
  ☐ Input validation on all forms (client + server)
  ☐ CSRF protection on mutations
  ☐ Rate limiting on API routes
  ☐ Content Security Policy headers
  ☐ HTTPS enforced (automatic on Vercel)

AGENT-BROWSABLE (unique requirement):
  ☐ Semantic data-* attributes on interactive elements
  ☐ JSON-LD structured data on all pages
  ☐ API endpoints mirror page data (headless access)
  ☐ Accessibility tree is meaningful (agent's primary interface)
  → see: 10-agent-browsable.md for full spec

DEPLOYMENT:
  ☐ Builds without errors
  ☐ No TypeScript errors
  ☐ No ESLint errors (warnings acceptable)
  ☐ Environment variables documented
  ☐ Committed to GitHub
  ☐ Auto-deploys on push
  ☐ Live URL accessible
```
