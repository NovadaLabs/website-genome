# 17 — Industry Research

## PURPOSE

```spec
Competitive landscape, tools, and trends for automated website building.
Context for the executor agent to understand what exists and what patterns to follow.
```

---

## WEBSITE BUILDER LANDSCAPE

```spec
CATEGORY 1: NO-CODE BUILDERS (human-operated)
  Webflow         visual design → production HTML/CSS
  Framer          design + code hybrid, React-based
  Squarespace     template-based, consumer focused
  Wix             drag-drop, widest audience
  WordPress       CMS + themes, 40%+ of web

  RELEVANCE: These are what we're REPLACING with agent-operated automation.
  They solve the same problem (build websites) but require human operation.

CATEGORY 2: AI WEBSITE GENERATORS (emerging)
  v0.dev          Vercel's AI → React/Next.js code
  bolt.new        StackBlitz's AI → full-stack apps
  lovable.dev     AI → full-stack web apps
  Replit Agent    AI → any app in Replit environment
  Cursor          AI-powered IDE (not website-specific)
  Claude Code     Anthropic's AI coding agent (this tool)

  RELEVANCE: These are peers/competitors to the Website Factory.
  Key difference: they build ONE thing at a time interactively.
  Our approach: documented genome → automated pipeline → batch production.

CATEGORY 3: WEBSITE CLONERS / SCRAPERS
  HTTrack         download entire websites (offline)
  SingleFile      save page as single HTML file
  Screaming Frog  SEO crawler, extracts site structure
  Firecrawl       API for web scraping
  Novada          our own API (search, extract, crawl)

  RELEVANCE: These are TOOLS we use in the extraction phase.
  They solve part of the problem (capture) but not generation.
```

## TECHNOLOGY TRENDS

```spec
TREND 1: SERVER-FIRST RENDERING
  React Server Components are the default in Next.js 16.
  Most code runs on the server. Client JS is minimal.
  IMPLICATION: Our generated websites are fast by default.

TREND 2: DESIGN SYSTEM AS CODE
  shadcn/ui popularized "copy components into your project."
  Design tokens + component source code = fully customizable.
  IMPLICATION: Our genome uses this pattern (atoms → compositions).

TREND 3: AI-NATIVE INTERFACES
  Websites increasingly serve agents, not just humans.
  Structured data (JSON-LD, APIs, MCP) is as important as visual design.
  IMPLICATION: Our agent-browsable layer (10-agent-browsable.md) is forward-looking.

TREND 4: EDGE COMPUTING
  Vercel Fluid Compute, Cloudflare Workers, Deno Deploy.
  Code runs closer to users, reducing latency.
  IMPLICATION: Our default stack (Next.js + Vercel) optimizes for this.

TREND 5: FULLSTACK TYPESCRIPT
  Same language (TypeScript) for frontend, backend, database schemas, validation.
  Drizzle ORM, Zod, tRPC — end-to-end type safety.
  IMPLICATION: Our genome uses TypeScript throughout.
```

## COMPONENT LIBRARY COMPARISON

```spec
LIBRARY          | APPROACH           | CUSTOMIZABLE | BUNDLE SIZE | ACCESSIBILITY
-----------------|--------------------|--------------|-------------|---------------
shadcn/ui [D]    | source code copy   | FULL         | minimal     | Radix (excellent)
Radix UI         | headless primitives| styling only | minimal     | EXCELLENT
Headless UI      | headless primitives| styling only | minimal     | good
Material UI      | opinionated design | theme only   | LARGE       | good
Chakra UI        | styled components  | theme + props| medium      | good
Ant Design       | opinionated design | theme only   | LARGE       | fair
Mantine          | full-featured      | props + CSS  | medium      | good

DECISION: shadcn/ui is the optimal choice because:
  1. Full customization (it's YOUR source code)
  2. Built on Radix (best accessibility)
  3. Tailwind CSS (consistent with our token system)
  4. Tree-shakeable (only import what you use)
  5. Active maintenance and community
  6. v0.dev outputs shadcn/ui components
```

## CSS FRAMEWORK COMPARISON

```spec
FRAMEWORK        | APPROACH           | BUNDLE SIZE  | DX          | VERDICT
-----------------|--------------------|--------------|-------------|--------
Tailwind CSS [D] | utility-first      | purged tiny  | excellent   | DEFAULT
CSS Modules      | scoped classes     | minimal      | good        | alternative
Styled Components| CSS-in-JS          | medium       | good        | avoid (SSR issues)
Emotion          | CSS-in-JS          | medium       | good        | avoid (SSR issues)
Vanilla CSS      | raw CSS            | varies       | poor at scale| avoid
Sass/SCSS        | preprocessor       | varies       | good        | unnecessary with Tailwind

DECISION: Tailwind CSS because:
  1. Design tokens map directly to utility classes
  2. Purges unused CSS (tiny bundle)
  3. shadcn/ui is built on it
  4. Responsive utilities (md:, lg:) are intuitive
  5. Dark mode built-in (dark: prefix)
  6. Next.js 16 + Turbopack has first-class Tailwind support
```

## DEPLOYMENT PLATFORM COMPARISON

```spec
PLATFORM         | STRENGTHS          | WEAKNESSES       | VERDICT
-----------------|--------------------|------------------|--------
Vercel [D]       | Next.js native,    | vendor-specific  | DEFAULT
                 | edge, preview URLs | optimizations    |
Netlify          | good DX, functions | slower builds    | alternative
Cloudflare Pages | edge-first, cheap  | limited runtime  | alternative
AWS Amplify      | AWS ecosystem      | complex setup    | avoid
Railway          | full-stack hosting | no edge network  | for backends
Render           | simple deployment  | no edge, slower  | avoid
Self-hosted      | full control       | ops overhead     | avoid for MVP

DECISION: Vercel because:
  1. Zero-config Next.js deployment
  2. Preview URLs for every PR
  3. Edge network (300ms global propagation)
  4. Marketplace integrations (Neon, Clerk, Upstash)
  5. Built-in analytics + monitoring
  6. Vercel CLI for agent-operated deployment
```
