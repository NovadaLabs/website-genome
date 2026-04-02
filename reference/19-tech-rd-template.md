# 19 — Tech RD Template (Technical Design Document)

## AGENT INSTRUCTIONS

```spec
Fill this template AFTER the PRD (18-prd-template.md) is complete.
This document defines HOW to build what the PRD specifies.
Output: architecture decisions, data models, component tree, API design.
```

---

# Tech RD: [PROJECT_NAME]

## 1. Technology Stack

```spec
RUNTIME:          Node.js 22 LTS
LANGUAGE:         TypeScript 5.x (strict mode)
FRAMEWORK:        Next.js 16 (App Router)
STYLING:          Tailwind CSS 4.x
COMPONENTS:       shadcn/ui
FONTS:            [Geist Sans + Geist Mono | custom]
ICONS:            lucide-react
PACKAGE_MANAGER:  pnpm
DEPLOYMENT:       Vercel

CONDITIONAL:
  AUTH:           [@clerk/nextjs | none]
  ORM:            [drizzle-orm + @neondatabase/serverless | none]
  CACHE:          [@upstash/redis | none]
  PAYMENTS:       [stripe | none]
  EMAIL:          [resend | none]
  AI:             [ai + @ai-sdk/react + ai-gateway | none]
  FORMS:          [react-hook-form + zod + @hookform/resolvers]
  CHARTS:         [recharts | none]
  TABLES:         [@tanstack/react-table | none]
  THEME:          [next-themes]
  DATES:          [date-fns | none]
```

## 2. Project Structure

```spec
project-name/
├── src/
│   ├── app/
│   │   ├── (marketing)/         # Public marketing pages
│   │   │   ├── layout.tsx       # Navbar + Footer
│   │   │   ├── page.tsx         # Landing page (/)
│   │   │   ├── features/page.tsx
│   │   │   ├── pricing/page.tsx
│   │   │   ├── about/page.tsx
│   │   │   └── blog/
│   │   │       ├── page.tsx     # Blog listing
│   │   │       └── [slug]/page.tsx
│   │   │
│   │   ├── (auth)/              # Auth pages
│   │   │   ├── layout.tsx       # Centered card layout
│   │   │   ├── login/[[...login]]/page.tsx    # or sign-in for Clerk
│   │   │   └── signup/[[...signup]]/page.tsx  # or sign-up for Clerk
│   │   │
│   │   ├── (dashboard)/         # Authenticated app pages
│   │   │   ├── layout.tsx       # Sidebar + TopBar
│   │   │   ├── dashboard/page.tsx
│   │   │   ├── [resource]/
│   │   │   │   ├── page.tsx     # List
│   │   │   │   ├── new/page.tsx # Create
│   │   │   │   └── [id]/
│   │   │   │       ├── page.tsx # Detail
│   │   │   │       └── edit/page.tsx
│   │   │   └── settings/page.tsx
│   │   │
│   │   ├── api/                 # API routes
│   │   │   ├── route.ts         # API discovery endpoint
│   │   │   ├── [resource]/route.ts
│   │   │   └── webhooks/
│   │   │       └── [provider]/route.ts
│   │   │
│   │   ├── layout.tsx           # Root layout
│   │   ├── not-found.tsx        # 404
│   │   ├── error.tsx            # Error boundary
│   │   ├── global-error.tsx     # Root error boundary
│   │   ├── sitemap.ts           # Dynamic sitemap
│   │   ├── robots.ts            # Robots.txt
│   │   └── icon.tsx             # Dynamic favicon
│   │
│   ├── components/
│   │   ├── ui/                  # shadcn/ui components (auto-generated)
│   │   ├── navbar.tsx
│   │   ├── footer.tsx
│   │   ├── sidebar-nav.tsx
│   │   ├── dashboard-shell.tsx
│   │   ├── [feature-specific components]
│   │   └── json-ld.tsx
│   │
│   ├── lib/
│   │   ├── utils.ts             # cn() utility
│   │   └── [feature-specific utilities]
│   │
│   ├── db/                      # Database layer [C]
│   │   ├── schema.ts            # Drizzle schema
│   │   ├── index.ts             # DB client
│   │   └── seed.ts              # Seed data [O]
│   │
│   ├── actions/                 # Server Actions
│   │   └── [resource].ts
│   │
│   ├── proxy.ts                 # Next.js 16 proxy (was middleware.ts)
│   │
│   └── env.ts                   # Environment variable validation
│
├── public/
│   ├── [static assets: images, fonts, etc.]
│   └── [brand assets: logo.svg, etc.]
│
├── .env.local                   # Local env vars (git-ignored)
├── .gitignore
├── next.config.ts
├── package.json
├── tsconfig.json
├── drizzle.config.ts            # [C] if database
├── components.json              # shadcn/ui config
└── README.md

[Customize: add/remove directories based on PRD requirements.]
```

## 3. Data Model

```spec
[Define database schema for each resource in the PRD.]

TABLE: users
  id          UUID        PK, default random
  email       TEXT        NOT NULL, UNIQUE
  name        TEXT
  avatar_url  TEXT
  role        TEXT        NOT NULL, DEFAULT 'user'  -- user | admin
  plan        TEXT        NOT NULL, DEFAULT 'free'  -- free | pro | enterprise
  created_at  TIMESTAMP   NOT NULL, DEFAULT now()
  updated_at  TIMESTAMP   NOT NULL, DEFAULT now()

TABLE: [resource_name]
  id          UUID        PK, default random
  user_id     UUID        FK → users.id, NOT NULL
  title       TEXT        NOT NULL
  description TEXT
  status      TEXT        NOT NULL, DEFAULT 'active'  -- [define statuses]
  [additional fields per PRD]
  created_at  TIMESTAMP   NOT NULL, DEFAULT now()
  updated_at  TIMESTAMP   NOT NULL, DEFAULT now()

RELATIONSHIPS:
  users 1 → N [resources]
  [define additional relationships]

INDEXES:
  [resource].user_id  (fast lookup by user)
  [resource].status   (fast filtering)
  [resource].created_at DESC (fast sorting)

[Customize based on PRD. Delete if no database needed.]
```

## 4. API Design

```spec
[Define API routes for CRUD operations and data access.]

ENDPOINT: GET /api
  PURPOSE: API discovery
  AUTH: none
  RESPONSE: { resources: { [name]: { url, actions } } }

ENDPOINT: GET /api/[resource]
  PURPOSE: List resources (paginated, filterable)
  AUTH: required
  PARAMS: ?page=1&limit=20&sort=created_at&order=desc&status=active&q=search
  RESPONSE: { data: [...], meta: { page, totalPages, totalItems } }

ENDPOINT: GET /api/[resource]/[id]
  PURPOSE: Get single resource
  AUTH: required (owner or admin)
  RESPONSE: { data: { ... } }

ENDPOINT: POST /api/[resource]
  PURPOSE: Create resource
  AUTH: required
  BODY: { [fields per schema] }
  VALIDATION: zod schema
  RESPONSE: 201 { data: { ... } }

ENDPOINT: PATCH /api/[resource]/[id]
  PURPOSE: Update resource
  AUTH: required (owner or admin)
  BODY: { [partial fields] }
  RESPONSE: { data: { ... } }

ENDPOINT: DELETE /api/[resource]/[id]
  PURPOSE: Delete resource
  AUTH: required (owner or admin)
  RESPONSE: 204

[Customize. Most mutations use Server Actions, not API routes.]
[API routes only needed for: webhooks, public API, external integrations.]
```

## 5. Component Tree

```spec
[Map the component hierarchy for each major page.]

LANDING PAGE (/):
  MarketingLayout
  ├── Navbar
  │   ├── Logo
  │   ├── NavLinks [Features, Pricing, Docs, Blog]
  │   └── AuthButtons [Sign In, Get Started]
  ├── HeroSection
  │   ├── Badge "New"
  │   ├── Heading h1
  │   ├── Description p
  │   ├── CTAButtons [Primary, Secondary]
  │   └── HeroImage
  ├── FeatureSection
  │   ├── SectionHeading
  │   └── FeatureCards × 3-6
  ├── TestimonialsSection
  │   └── TestimonialCards × 3
  ├── PricingSection (or link to /pricing)
  ├── FAQSection
  │   └── Accordion
  ├── CTASection
  └── Footer

DASHBOARD (/dashboard):
  DashboardLayout
  ├── Sidebar
  │   ├── Logo
  │   ├── NavGroups
  │   │   └── NavItems × N
  │   └── UserMenu
  ├── TopBar
  │   ├── SidebarTrigger
  │   ├── Breadcrumb
  │   ├── SearchBar
  │   ├── NotificationBell
  │   └── UserMenu
  └── MainContent
      ├── PageHeader [title + actions]
      ├── StatCards × 4
      ├── RecentActivityTable
      └── Chart

[Map all pages from the PRD sitemap.]
```

## 6. Auth Architecture

```spec
PROVIDER:         [Clerk | Auth0 | none]
PROTECTED_ROUTES: [/dashboard/*, /settings/*, /admin/*]
ADMIN_ROUTES:     [/admin/*]
PUBLIC_ROUTES:    [/, /features, /pricing, /blog/*, /docs/*, /login, /signup]

PROXY CONFIG (src/proxy.ts):
  - clerkMiddleware()
  - Protect /dashboard/* and /api/* (except webhooks)
  - Admin routes: require role 'admin'
  - Redirect authenticated users from /login to /dashboard
  - Handle org-not-found → redirect to /create-org

SESSION DATA USED:
  - userId (all protected pages)
  - orgId (if org-based)
  - role (admin pages)
  - email (settings, display)
```

## 7. Environment Variables

```spec
REQUIRED:
  DATABASE_URL            Neon connection string [C]
  CLERK_SECRET_KEY        Clerk server key [C]
  NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY  Clerk client key [C]
  NEXT_PUBLIC_CLERK_SIGN_IN_URL      /sign-in [C]
  NEXT_PUBLIC_CLERK_SIGN_UP_URL      /sign-up [C]

OPTIONAL:
  STRIPE_SECRET_KEY       Stripe API key [C]
  STRIPE_WEBHOOK_SECRET   Stripe webhook secret [C]
  RESEND_API_KEY          Resend email key [C]
  UPSTASH_REDIS_REST_URL  Upstash Redis URL [C]
  UPSTASH_REDIS_REST_TOKEN Upstash Redis token [C]

AUTO-PROVISIONED (via vercel env pull):
  VERCEL_OIDC_TOKEN       AI Gateway auth [C]
  VERCEL_URL              Deployment URL

[List only what the project actually needs. Delete unused.]
```

## 8. Deployment Configuration

```spec
// next.config.ts
import type { NextConfig } from 'next'

const config: NextConfig = {
  images: {
    remotePatterns: [
      // Add external image domains here
    ],
  },
  // Add headers, redirects, rewrites as needed
}

export default config

// OR vercel.ts for Vercel-specific config
import { type VercelConfig } from '@vercel/config/v1'

export const config: VercelConfig = {
  framework: 'nextjs',
  // crons, redirects, headers, etc.
}
```
