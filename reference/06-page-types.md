# 06 — Page Types & Sitemap Patterns

## PURPOSE

```spec
This file catalogs EVERY type of page that exists across all website categories.
For each page: purpose, template used, components needed, auth state, data requirements.
Executor agent uses this to determine the full sitemap for any website project.
```

---

## AUTH STATE TREE

```spec
Every page exists within an auth context. Map pages to states:

STATE 0: PUBLIC (no auth)
  Visible to: everyone (including search engines)
  Examples: landing, pricing, docs, blog, login, signup
  Protection: none

STATE 1: AUTHENTICATED (logged in)
  Visible to: any logged-in user
  Examples: dashboard, settings, profile
  Protection: redirect to /login if not authenticated

STATE 2: ROLE-BASED (specific roles)
  Visible to: users with specific role/permission
  Examples: admin panel, billing (owner only), team management
  Protection: redirect to /dashboard or show 403 if insufficient role

STATE 3: ONBOARDING (authenticated but incomplete setup)
  Visible to: users who haven't completed onboarding
  Examples: welcome wizard, team creation, first-project setup
  Protection: redirect here if onboarding incomplete; redirect away if complete

STATE 4: SUBSCRIPTION-GATED (paid feature)
  Visible to: users on specific plan
  Examples: premium features, advanced analytics
  Protection: show upgrade prompt or paywall if not on required plan

AUTH FLOW:
  Unauthenticated → /login → /signup or /login
  First login (no org) → /onboarding (create org, invite team)
  Authenticated → /dashboard (default landing)
  Expired session → redirect to /login with ?redirect= param
```

---

## PAGE CATALOG BY CATEGORY

### 6.1 PUBLIC / MARKETING PAGES

```spec
PAGE: LANDING PAGE (/)
  TEMPLATE: Marketing Layout
  AUTH: STATE 0 (public)
  ORGANISMS: Hero + Features + SocialProof + CTA + FAQ
  DATA: static or CMS
  SEO: priority — primary keywords in h1, meta description
  VARIANTS:
    product-led    hero with product screenshot/demo
    brand-led      hero with mission statement, team photos
    conversion-led hero with signup form embedded

PAGE: FEATURES PAGE (/features)
  TEMPLATE: Marketing Layout
  AUTH: STATE 0
  ORGANISMS: FeatureHero + DetailedFeatureSections[] + Comparison + CTA
  DATA: static or CMS

PAGE: PRICING PAGE (/pricing)
  TEMPLATE: Marketing Layout
  AUTH: STATE 0
  ORGANISMS: PricingSection + FeatureComparison + FAQ + CTA
  DATA: static (or dynamic if plans come from Stripe)
  INTERACTION: monthly/annual toggle, plan selection → redirect to /signup?plan=X

PAGE: ABOUT PAGE (/about)
  TEMPLATE: Marketing Layout
  AUTH: STATE 0
  ORGANISMS: Mission + Team + Values + Timeline + CTA

PAGE: CONTACT PAGE (/contact)
  TEMPLATE: Marketing Layout
  AUTH: STATE 0
  ORGANISMS: ContactForm + Map + OfficeInfo
  DATA: form submission → email (Resend) or CRM

PAGE: BLOG LISTING (/blog)
  TEMPLATE: Marketing Layout
  AUTH: STATE 0
  ORGANISMS: BlogGrid + CategoryFilter + Pagination + FeaturedPost
  DATA: MDX files, CMS, or database
  SEO: category pages, tag pages, pagination

PAGE: BLOG POST (/blog/[slug])
  TEMPLATE: Blog Layout
  AUTH: STATE 0
  ORGANISMS: ArticleHeader + ArticleContent + AuthorBio + RelatedPosts
  DATA: MDX or CMS content
  SEO: article structured data, OG image

PAGE: CHANGELOG (/changelog)
  TEMPLATE: Marketing Layout
  AUTH: STATE 0
  ORGANISMS: Timeline of updates with dates, versions, descriptions

PAGE: LEGAL PAGES (/privacy, /terms, /cookies)
  TEMPLATE: Marketing Layout
  AUTH: STATE 0
  CONTENT: prose (legal text), last updated date
```

### 6.2 AUTH PAGES

```spec
PAGE: LOGIN (/login)
  TEMPLATE: Auth Layout
  AUTH: STATE 0 (redirect to /dashboard if already logged in)
  MOLECULES: AuthForm(login variant)
  INTERACTION: form submit → authenticate → redirect to ?redirect= or /dashboard
  CLERK: <SignIn /> component if using Clerk

PAGE: SIGNUP (/signup)
  TEMPLATE: Auth Layout
  AUTH: STATE 0
  MOLECULES: AuthForm(signup variant)
  INTERACTION: form submit → create account → redirect to /onboarding
  URL_PARAMS: ?plan=pro (if coming from pricing page)
  CLERK: <SignUp /> component

PAGE: FORGOT PASSWORD (/forgot-password)
  TEMPLATE: Auth Layout
  AUTH: STATE 0
  MOLECULES: AuthForm(forgot variant)
  INTERACTION: submit email → send reset link → show confirmation

PAGE: RESET PASSWORD (/reset-password)
  TEMPLATE: Auth Layout
  AUTH: STATE 0 (requires valid reset token)
  MOLECULES: AuthForm(reset variant)
  URL_PARAMS: ?token=xxx

PAGE: VERIFY EMAIL (/verify-email)
  TEMPLATE: Auth Layout
  AUTH: STATE 0
  CONTENT: verification status message, resend link
  URL_PARAMS: ?token=xxx

PAGE: SSO CALLBACK (/auth/callback)
  TEMPLATE: none (redirect-only)
  PURPOSE: OAuth callback handler, exchanges code for session, redirects
```

### 6.3 ONBOARDING PAGES

```spec
PAGE: WELCOME (/onboarding or /welcome)
  TEMPLATE: Wizard Layout
  AUTH: STATE 3
  STEPS:
    1. Welcome message + user profile (name, avatar)
    2. Create organization/team
    3. Invite team members (optional, skippable)
    4. Choose plan / start trial
    5. First resource creation (project, workspace, etc.)
  INTERACTION: step-by-step wizard, progress indicator, skip options
  EXIT: redirect to /dashboard on completion, set onboarding_complete flag

PAGE: ORG CREATION (/create-org)
  TEMPLATE: Auth Layout (centered)
  AUTH: STATE 1 (no org yet)
  MOLECULES: Form (org name, slug, logo upload)
  ⚠️ CLERK: <CreateOrganization /> component
  ⚠️ Handle case where user has no org → redirect here, not loop to landing
```

### 6.4 DASHBOARD / APP PAGES

```spec
PAGE: DASHBOARD HOME (/dashboard)
  TEMPLATE: Dashboard Layout
  AUTH: STATE 1
  ORGANISMS: StatCards + RecentActivity + QuickActions + Charts
  DATA: aggregated metrics, recent items
  PURPOSE: overview/summary of everything

PAGE: RESOURCE LIST (/dashboard/[resource])
  TEMPLATE: Dashboard Layout
  AUTH: STATE 1
  ORGANISMS: PageHeader(title + create button) + Filters + DataTable + Pagination
  RESOURCES: varies by app (projects, users, orders, tickets, etc.)
  INTERACTION: filter, sort, search, bulk actions, row click → detail

PAGE: RESOURCE DETAIL (/dashboard/[resource]/[id])
  TEMPLATE: Dashboard Layout
  AUTH: STATE 1
  ORGANISMS: PageHeader(breadcrumb + actions) + DetailCard + Tabs(info, history, settings)
  INTERACTION: edit inline or via modal, delete with confirmation

PAGE: RESOURCE CREATE (/dashboard/[resource]/new)
  TEMPLATE: Dashboard Layout
  AUTH: STATE 1
  ORGANISMS: PageHeader + Form(creation fields) + Preview(optional)
  INTERACTION: form submit → create → redirect to detail page

PAGE: RESOURCE EDIT (/dashboard/[resource]/[id]/edit)
  TEMPLATE: Dashboard Layout
  AUTH: STATE 1
  ORGANISMS: same as create but pre-filled with existing data

PAGE: ANALYTICS (/dashboard/analytics)
  TEMPLATE: Dashboard Layout
  AUTH: STATE 1 or STATE 4 (may be premium)
  ORGANISMS: DateRangePicker + Charts[] + DataTable(detailed)
  DATA: time-series metrics, aggregations

PAGE: SETTINGS (/settings or /dashboard/settings)
  TEMPLATE: Settings Layout (inside Dashboard)
  AUTH: STATE 1
  TABS:
    General:       profile, display preferences
    Security:      password change, 2FA, sessions
    Notifications: email/push preferences
    Billing:       plan, payment method, invoices [STATE 4 relevant]
    Team:          members, roles, invitations [STATE 2 for admin]
    API:           API keys, webhooks, usage
    Integrations:  connected services
    Danger Zone:   delete account, export data

PAGE: PROFILE (/profile or /dashboard/profile)
  TEMPLATE: Dashboard Layout
  AUTH: STATE 1
  ORGANISMS: AvatarUpload + ProfileForm + ActivityFeed

PAGE: NOTIFICATIONS (/notifications)
  TEMPLATE: Dashboard Layout
  AUTH: STATE 1
  ORGANISMS: NotificationList(filterable) + MarkAllRead
```

### 6.5 ADMIN PAGES

```spec
PAGE: ADMIN DASHBOARD (/admin)
  TEMPLATE: Dashboard Layout (admin variant)
  AUTH: STATE 2 (admin role required)
  ORGANISMS: SystemStats + UserGrowthChart + RecentSignups + SystemHealth

PAGE: USER MANAGEMENT (/admin/users)
  TEMPLATE: Dashboard Layout
  AUTH: STATE 2
  ORGANISMS: DataTable(users) + InviteButton + BulkActions(ban, delete, change role)

PAGE: CONTENT MODERATION (/admin/moderation)
  TEMPLATE: Dashboard Layout
  AUTH: STATE 2
  ORGANISMS: FlaggedContentList + ApproveRejectActions

PAGE: SYSTEM SETTINGS (/admin/settings)
  TEMPLATE: Settings Layout
  AUTH: STATE 2
  TABS: General, Email, Integrations, Feature Flags, Maintenance Mode
```

### 6.6 E-COMMERCE PAGES

```spec
PAGE: PRODUCT LISTING (/products or /shop)
  TEMPLATE: E-Commerce Layout
  AUTH: STATE 0
  ORGANISMS: FilterSidebar + SortDropdown + ProductGrid + Pagination
  DATA: products from database/CMS with images, prices, ratings

PAGE: PRODUCT DETAIL (/products/[slug])
  TEMPLATE: E-Commerce Layout (detail variant)
  AUTH: STATE 0
  ORGANISMS: ImageGallery + ProductInfo + VariantSelector + AddToCart + Reviews + Related
  SEO: Product structured data (JSON-LD)

PAGE: CART (/cart)
  TEMPLATE: Marketing Layout (or minimal)
  AUTH: STATE 0 (guest checkout) or STATE 1
  ORGANISMS: CartItemList + OrderSummary + PromoCode + CheckoutButton

PAGE: CHECKOUT (/checkout)
  TEMPLATE: Wizard Layout
  AUTH: STATE 0 or STATE 1
  STEPS:
    1. Shipping address
    2. Shipping method
    3. Payment (Stripe Elements)
    4. Review + confirm
  ⚠️ Payment step: human must handle Stripe test/live mode verification

PAGE: ORDER CONFIRMATION (/orders/[id]/confirmation)
  TEMPLATE: Marketing Layout (minimal)
  AUTH: STATE 1
  ORGANISMS: OrderSummary + EstimatedDelivery + ContinueShopping

PAGE: ORDER HISTORY (/orders)
  TEMPLATE: Dashboard Layout
  AUTH: STATE 1
  ORGANISMS: OrderTable + StatusBadges + OrderDetail
```

### 6.7 DOCUMENTATION PAGES

```spec
PAGE: DOCS HOME (/docs)
  TEMPLATE: Docs Layout
  AUTH: STATE 0
  ORGANISMS: SearchBar + CategoryCards + GettingStartedGuide

PAGE: DOCS ARTICLE (/docs/[...slug])
  TEMPLATE: Docs Layout
  AUTH: STATE 0
  CONTENT: MDX with code blocks, callouts, tables, step-by-step guides
  NAV: sidebar tree (auto-generated from file structure)
  TOC: auto-generated from h2/h3 headings

PAGE: API REFERENCE (/docs/api or /api-reference)
  TEMPLATE: Docs Layout
  AUTH: STATE 0
  ORGANISMS: EndpointList + RequestBuilder + ResponseViewer + CodeExamples
  SPECIAL: OpenAPI/Swagger integration possible
```

### 6.8 ERROR PAGES

```spec
PAGE: 404 NOT FOUND
  TEMPLATE: Empty Layout
  AUTH: any
  FILE: app/not-found.tsx
  CONTENT: "Page not found" + home link + search

PAGE: 500 SERVER ERROR
  TEMPLATE: Empty Layout
  AUTH: any
  FILE: app/error.tsx (or app/global-error.tsx)
  CONTENT: "Something went wrong" + retry button + home link
  ⚠️ error.tsx must be a Client Component ('use client')

PAGE: 403 FORBIDDEN
  TEMPLATE: Empty Layout
  AUTH: STATE 1 (authenticated but wrong role)
  CONTENT: "Access denied" + contact admin + home link

PAGE: MAINTENANCE
  TEMPLATE: Empty Layout
  AUTH: any
  CONTENT: "Under maintenance" + estimated return time
```

---

## SITEMAP PATTERNS BY WEBSITE TYPE

```spec
MARKETING SITE (5-10 pages):
  /                   landing
  /features           features
  /pricing            pricing
  /about              about
  /contact            contact
  /blog               blog listing
  /blog/[slug]        blog post
  /privacy            privacy policy
  /terms              terms of service
  /login              login (→ external app)

SAAS APPLICATION (20-50 pages):
  /                   landing (marketing)
  /features           features
  /pricing            pricing
  /blog               blog
  /blog/[slug]        blog post
  /docs               documentation
  /docs/[...slug]     doc article
  /login              login
  /signup             signup
  /forgot-password    forgot password
  /onboarding         onboarding wizard
  /dashboard          dashboard home
  /dashboard/[resource]          resource list (multiple)
  /dashboard/[resource]/[id]     resource detail
  /dashboard/[resource]/new      resource create
  /dashboard/analytics           analytics
  /settings           settings (tabs)
  /settings/billing   billing
  /settings/team      team management
  /admin              admin dashboard (admin role)
  /admin/users        user management
  /privacy            privacy
  /terms              terms

E-COMMERCE (30-100+ pages):
  /                   landing
  /products           product listing
  /products/[slug]    product detail
  /categories/[slug]  category listing
  /cart               shopping cart
  /checkout           checkout wizard
  /orders             order history
  /orders/[id]        order detail
  /account            account settings
  /wishlist           saved items
  /search             search results
  /blog               blog
  + all marketing + auth pages

DOCUMENTATION SITE (10-500+ pages):
  /                   landing (minimal)
  /docs               docs home
  /docs/[...slug]     doc articles (many)
  /api-reference      API reference
  /blog               blog/changelog
  /search             search
  + auth if gated docs

PORTFOLIO (3-7 pages):
  /                   home/intro
  /projects           project grid
  /projects/[slug]    project detail
  /about              about/bio
  /contact            contact
  /blog               blog (optional)
```

---

## PAGE DATA REQUIREMENTS MATRIX

```spec
PAGE                    | DATA SOURCE        | CACHE STRATEGY      | RENDERING
------------------------|--------------------|--------------------|----------
Landing                 | static/CMS         | SSG + revalidate   | Server Component
Features                | static/CMS         | SSG                | Server Component
Pricing                 | static/Stripe API  | SSG + revalidate   | Server Component
Blog listing            | MDX/CMS/DB         | SSG + revalidate   | Server Component
Blog post               | MDX/CMS/DB         | SSG + revalidate   | Server Component
Login/signup            | none               | SSG                | Client Component
Dashboard               | API/DB             | SSR (per-request)  | Server + Client
Resource list           | API/DB + filters   | SSR + cache tag    | Server + Client
Resource detail         | API/DB             | SSR + cache tag    | Server + Client
Settings                | API/DB             | SSR                | Client Component
Analytics               | API/DB + aggregation | SSR              | Client Component
Product listing         | DB + filters       | SSR + revalidate   | Server + Client
Product detail          | DB                 | SSG + revalidate   | Server Component
Cart                    | client state       | none               | Client Component
Checkout                | client + Stripe    | none               | Client Component
Docs                    | MDX/files          | SSG                | Server Component
404/500                 | none               | SSG                | Server Component
```
