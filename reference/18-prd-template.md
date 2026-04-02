# 18 — PRD Template (Product Requirements Document)

## AGENT INSTRUCTIONS

```spec
Copy this template and fill in the [PLACEHOLDERS] for each new website project.
This document defines WHAT to build (not HOW — that's the Tech RD).
Input source: human project-checklist or extraction output.
```

---

# PRD: [PROJECT_NAME]

## 1. Overview

```spec
PROJECT_NAME:     [name]
WEBSITE_TYPE:     [marketing | saas | e-commerce | content | portfolio | community | dev-tools | internal]
TARGET_AUDIENCE:  [one sentence describing who uses this]
VALUE_PROPOSITION:[one sentence — what problem does this solve?]
DOMAIN:           [domain.com or TBD]
BRAND_NAME:       [brand]
```

## 2. Goals

```spec
PRIMARY_GOAL:     [what must this website achieve?]
  Example: "Convert visitors into trial signups"
  Example: "Provide a dashboard for managing projects"
  Example: "Showcase portfolio work to potential clients"

SUCCESS_METRICS:
  - [metric 1, e.g., "Page load < 2s"]
  - [metric 2, e.g., "Lighthouse score > 90 all categories"]
  - [metric 3, e.g., "All CRUD operations functional"]
```

## 3. User Roles

```spec
ROLE_1:
  NAME:           [e.g., "Visitor" (unauthenticated)]
  CAN_DO:         [list of capabilities]
  CANNOT_DO:      [list of restrictions]
  PAGES_VISIBLE:  [list of accessible pages]

ROLE_2:
  NAME:           [e.g., "User" (authenticated)]
  CAN_DO:         [list]
  CANNOT_DO:      [list]
  PAGES_VISIBLE:  [list]

ROLE_3:
  NAME:           [e.g., "Admin"]
  CAN_DO:         [list]
  CANNOT_DO:      [list]
  PAGES_VISIBLE:  [list]

[Add more roles as needed. Delete unused roles.]
```

## 4. Sitemap

```spec
PUBLIC PAGES:
  /                   [landing page — PURPOSE]
  /features           [features — PURPOSE]
  /pricing            [pricing — PURPOSE]
  /blog               [blog listing — PURPOSE]
  /blog/[slug]        [blog post — PURPOSE]
  /docs               [documentation — PURPOSE]
  /about              [about — PURPOSE]
  /contact            [contact — PURPOSE]
  /privacy            [privacy policy]
  /terms              [terms of service]

AUTH PAGES:
  /login              [login form]
  /signup             [signup form]
  /forgot-password    [password reset request]

AUTHENTICATED PAGES:
  /dashboard          [main dashboard — PURPOSE]
  /dashboard/[resource]       [resource listing]
  /dashboard/[resource]/[id]  [resource detail]
  /dashboard/[resource]/new   [create resource]
  /settings           [user settings]
  /settings/billing   [billing management]
  /admin              [admin dashboard] (admin only)

[Customize based on website type. Remove unused pages.]
```

## 5. Page Requirements

```spec
FOR EACH PAGE, DEFINE:

PAGE: [path]
  PURPOSE:        [why does this page exist?]
  TEMPLATE:       [marketing | dashboard | auth | docs | blog | e-commerce | wizard | fullscreen]
  AUTH_STATE:     [public | authenticated | admin | subscription-gated]
  KEY_COMPONENTS: [list of organisms/molecules needed]
  DATA_SOURCE:    [static | CMS | database | API | none]
  USER_STORIES:
    - As a [role], I can [action] so that [benefit]
    - As a [role], I can [action] so that [benefit]
  ACCEPTANCE_CRITERIA:
    - [specific, testable criterion]
    - [specific, testable criterion]

[Repeat for every page in the sitemap.]
```

## 6. Feature Requirements

```spec
FEATURE: [feature name]
  PRIORITY:       [P0 (must have) | P1 (should have) | P2 (nice to have)]
  DESCRIPTION:    [what does this feature do?]
  USER_STORY:     As a [role], I can [action] so that [benefit]
  PAGES_AFFECTED: [list of pages where this feature appears]
  ACCEPTANCE:
    - [criterion 1]
    - [criterion 2]

[List all features. Common features:]
  - Authentication (signup, login, logout, password reset)
  - User profile (view, edit avatar, change password)
  - CRUD for primary resource (create, list, view, edit, delete)
  - Search and filter
  - Pagination
  - File upload
  - Notifications
  - Settings
  - Billing / subscription management
  - Admin panel
  - Dark mode toggle
  - Responsive design
  - SEO optimization
```

## 7. Design Requirements

```spec
COLOR_SCHEME:
  PRIMARY:        [hex or "default zinc"]
  ACCENT:         [hex or "default"]
  MODE:           [dark | light | both]

TYPOGRAPHY:
  SANS:           [font name or "Geist Sans"]
  MONO:           [font name or "Geist Mono"]

STYLE_REFERENCE: [URL of a website whose style to emulate, or "default shadcn/ui"]

BRAND_ASSETS:
  LOGO:           [file path or "generate text logo"]
  FAVICON:        [file path or "generate from brand initial"]
  OG_IMAGE:       [file path or "generate dynamically"]
```

## 8. Integration Requirements

```spec
AUTH:             [clerk | auth0 | descope | none]
DATABASE:         [neon | supabase | none]
CACHE:            [upstash-redis | none]
PAYMENTS:         [stripe | none]
EMAIL:            [resend | none]
AI:               [ai-gateway | none]
CMS:              [sanity | contentful | mdx | none]
ANALYTICS:        [vercel-analytics | none]
FILE_STORAGE:     [vercel-blob | none]
```

## 9. Non-Functional Requirements

```spec
PERFORMANCE:      Lighthouse >= 90 all categories
ACCESSIBILITY:    WCAG 2.1 AA compliance
SEO:              sitemap, robots.txt, OG tags, JSON-LD
SECURITY:         input validation, CSRF, rate limiting, CSP
RESPONSIVE:       375px, 768px, 1440px breakpoints
AGENT_BROWSABLE:  data-agent-* attributes, API mirroring, JSON-LD
DEPLOYMENT:       Vercel, auto-deploy on git push
```
