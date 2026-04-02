# 15 — Generation SOP (Atoms → Website)

## PURPOSE

```spec
Given a specification (from extraction or from scratch), BUILD the website.
This is the FORWARD ENGINEERING pipeline.
Input: PRD + Tech RD + atom specifications (or human project-checklist)
Output: Production-ready website deployed on Vercel.
```

---

## GENERATION PIPELINE

```spec
PHASE 1: SCAFFOLD ──→ PHASE 2: TOKENS ──→ PHASE 3: ATOMS ──→ PHASE 4: COMPOSE
(project setup)       (design system)     (install components)  (build pages)
     ──→ PHASE 5: WIRE ──→ PHASE 6: INVISIBLE ──→ PHASE 7: DEPLOY
         (state+data)       (SEO, a11y, perf)      (git+vercel)
```

### PHASE 1: SCAFFOLD

```bash
# 1.1 Create Next.js project
npx create-next-app@latest project-name \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --src-dir \
  --turbopack \
  --import-alias "@/*"

cd project-name

# 1.2 Install shadcn/ui
npx shadcn@latest init -d

# 1.3 Install Geist fonts
npm install geist

# 1.4 Install core dependencies
npm install lucide-react

# 1.5 Install conditional dependencies (based on project requirements)
# Auth:
npm install @clerk/nextjs
# Database:
npm install drizzle-orm @neondatabase/serverless
npm install -D drizzle-kit
# Forms:
npm install react-hook-form @hookform/resolvers zod
# Date handling:
npm install date-fns
# Charts:
npm install recharts
# Tables:
npm install @tanstack/react-table
# AI features:
npm install ai @ai-sdk/react
# Theme:
npm install next-themes

# 1.6 Initialize git
git init
git add -A
git commit -m "chore: scaffold project with Next.js 16 + shadcn/ui"

# 1.7 Connect to GitHub
gh repo create owner/project-name --private --source=. --remote=origin
git push -u origin main

# 1.8 Connect to Vercel
vercel link
vercel env pull  # pulls OIDC + any marketplace env vars
```

### PHASE 2: DESIGN TOKENS

```spec
PROCESS:
  2.1 Configure fonts in app/layout.tsx:
      import { GeistSans } from 'geist/font/sans'
      import { GeistMono } from 'geist/font/mono'
      // OR brand fonts via next/font

  2.2 Update globals.css with design tokens (→ 02-design-tokens.md)
      If replicating: use extracted colors from 14-extraction-sop.md output
      If from scratch: use defaults or brand colors from human checklist

  2.3 Configure tailwind.config if custom extensions needed

  2.4 Set up dark mode:
      npm install next-themes
      // app/layout.tsx: <ThemeProvider attribute="class" defaultTheme="dark">
      // Add theme toggle component

  2.5 Commit: "feat: configure design tokens and theme"
```

### PHASE 3: INSTALL ATOMS

```spec
PROCESS:
  3.1 Install ALL shadcn components that will be needed:
      npx shadcn@latest add button input label textarea select checkbox
      npx shadcn@latest add radio-group switch slider badge avatar separator
      npx shadcn@latest add skeleton progress scroll-area tooltip
      npx shadcn@latest add dialog alert-dialog sheet popover dropdown-menu
      npx shadcn@latest add tabs accordion card alert breadcrumb pagination
      npx shadcn@latest add command navigation-menu form calendar table
      npx shadcn@latest add sonner sidebar collapsible aspect-ratio

  3.2 Set up Toaster in layout:
      // app/layout.tsx
      import { Toaster } from "@/components/ui/sonner"
      <Toaster />

  3.3 Set up TooltipProvider in layout:
      import { TooltipProvider } from "@/components/ui/tooltip"
      <TooltipProvider>{children}</TooltipProvider>

  3.4 Create utility function (should already exist from shadcn init):
      // lib/utils.ts
      import { type ClassValue, clsx } from "clsx"
      import { twMerge } from "tailwind-merge"
      export function cn(...inputs: ClassValue[]) { return twMerge(clsx(inputs)) }

  3.5 Commit: "feat: install shadcn/ui components"
```

### PHASE 4: COMPOSE (build pages bottom-up)

```spec
ORDER: layouts → shared components → pages

  4.1 ROOT LAYOUT (app/layout.tsx):
      - HTML lang, body className (fonts)
      - ClerkProvider (if auth)
      - ThemeProvider (if dark mode)
      - TooltipProvider
      - Toaster
      - Analytics (if enabled)

  4.2 ROUTE GROUP LAYOUTS:
      - app/(marketing)/layout.tsx → Navbar + Footer
      - app/(auth)/layout.tsx → Centered card
      - app/(dashboard)/layout.tsx → Sidebar + TopBar
      - app/(docs)/layout.tsx → DocsNav + TOC

  4.3 SHARED COMPONENTS (components/ directory):
      Build in dependency order:
        a. Simple molecules: SearchBar, FormField, NavLink, StatCard
        b. Complex molecules: AuthForm, PricingCard, UserMenu, EmptyState
        c. Organisms: Navbar, Footer, Sidebar, DashboardShell

  4.4 PAGES (in priority order):
      Build the most important pages first:
        a. Landing page (/) — first impression
        b. Auth pages (/login, /signup) — if auth needed
        c. Dashboard (/dashboard) — primary app page
        d. Key feature pages
        e. Settings
        f. Admin (if applicable)
        g. Marketing pages (features, pricing, about)
        h. Legal pages (privacy, terms)
        i. Error pages (404, error)

  4.5 LOADING & ERROR FILES:
      For each route group:
        - loading.tsx (skeleton matching page layout)
        - error.tsx (error boundary with retry)
      Global:
        - not-found.tsx (404)
        - global-error.tsx (root error boundary)

  4.6 Commit after each major section:
      "feat: add marketing layout + landing page"
      "feat: add auth pages with Clerk"
      "feat: add dashboard layout + overview page"
      etc.
```

### PHASE 5: WIRE (state, data, interactions)

```spec
  5.1 DATABASE (if needed):
      - Create db/schema.ts (→ 08-state-data.md#database)
      - Create db/index.ts (connection)
      - Run npx drizzle-kit push
      - Seed initial data if applicable

  5.2 SERVER ACTIONS:
      - Create app/actions/ directory
      - Implement CRUD actions per resource
      - Add revalidation (revalidateTag/revalidatePath)
      - Connect forms to actions (useActionState)

  5.3 API ROUTES (for webhooks, external API):
      - Create app/api/ routes
      - Add auth checks
      - Add rate limiting
      - Add input validation (zod)

  5.4 PROXY / MIDDLEWARE:
      - Create src/proxy.ts (Next.js 16) or middleware.ts
      - Configure Clerk protection for dashboard routes
      - Add redirects for auth state
      - Handle org-not-found edge case

  5.5 CLIENT INTERACTIONS:
      - Wire all button onClick handlers
      - Wire all form submissions
      - Wire navigation (Link, router.push)
      - Wire modals/dialogs (open/close state)
      - Wire filters/sort (URL searchParams)
      - Wire pagination

  5.6 Commit: "feat: wire data layer + interactions"
```

### PHASE 6: INVISIBLE LAYER

```spec
  6.1 SEO:
      - Add metadata to every page (title, description)
      - Add generateMetadata for dynamic pages
      - Create app/sitemap.ts
      - Create app/robots.ts
      - Add JSON-LD structured data to public pages
      - Create OG image generator (app/opengraph-image.tsx or API route)

  6.2 ACCESSIBILITY:
      - Run Lighthouse audit, fix any issues below 90
      - Verify keyboard navigation on all interactive elements
      - Add skip-to-content link
      - Verify all images have alt text
      - Verify all form inputs have labels
      - Verify color contrast ratios

  6.3 PERFORMANCE:
      - Add priority to above-fold images
      - Add sizes prop to responsive images
      - Verify no unnecessary client-side JS
      - Lazy load below-fold components
      - Check bundle size: npx @next/bundle-analyzer

  6.4 SECURITY:
      - Verify no secrets in client code
      - Add CSP headers in next.config.ts
      - Validate all form inputs server-side
      - Add rate limiting to API routes

  6.5 AGENT-BROWSABLE:
      - Add data-agent-* attributes to interactive elements
      - Add JSON-LD to all public pages
      - Create API discovery endpoint (/api)
      - Mirror page data in API routes

  6.6 Commit: "feat: add SEO, accessibility, performance, security layers"
```

### PHASE 7: DEPLOY

```spec
  7.1 ENVIRONMENT VARIABLES:
      Verify all required env vars are set:
        vercel env ls
      Add any missing:
        vercel env add VARIABLE_NAME production preview development

  7.2 BUILD TEST:
      npm run build  # must succeed with zero errors
      # Fix any TypeScript or build errors

  7.3 FINAL COMMIT:
      git add -A
      git commit -m "feat: production-ready website"
      git push origin main

  7.4 VERIFY DEPLOYMENT:
      # Vercel auto-deploys on push
      # Wait for deployment to complete
      vercel inspect --wait
      # Or check the deployment URL

  7.5 POST-DEPLOY VERIFICATION:
      - Visit live URL
      - Check all pages load
      - Check responsive (mobile + desktop)
      - Check dark mode toggle
      - Check auth flow (if applicable)
      - Run Lighthouse on live URL
      - Check console for errors

  7.6 REPORT:
      Output to human:
        - Deployment URL: https://project-name.vercel.app
        - Pages built: N
        - Components used: N
        - Lighthouse scores: Performance/Accessibility/SEO/Best Practices
        - Known issues: list any unresolved items
```

---

## GENERATION FROM SCRATCH vs FROM EXTRACTION

```spec
FROM SCRATCH (human gives description):
  1. Generate PRD (→ 18-prd-template.md)
  2. Generate Tech RD (→ 19-tech-rd-template.md)
  3. Follow Phases 1-7 above
  4. Use AI-generated content (→ 13-content-strategy.md)

FROM EXTRACTION (URL replication):
  1. Run 14-extraction-sop.md on target URL
  2. Use extraction output as specification
  3. Map extracted design tokens → Phase 2
  4. Map extracted atoms → Phase 3-4
  5. Replicate interactions → Phase 5
  6. Add invisible layer → Phase 6
  7. Deploy → Phase 7
  8. Compare: screenshot of original vs screenshot of replica
     Target: 90%+ visual similarity
```
