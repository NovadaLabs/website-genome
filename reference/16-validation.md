# 16 — Validation Checklist (Review Agent)

## PURPOSE

```spec
This file is the REVIEW AGENT's checklist.
After the executor builds the website, a SEPARATE agent reviews against this list.
The review agent has NO PRIOR CONTEXT — it reads this file and the live site, nothing else.
Scoring: each check is PASS/FAIL. Total score = passed / total × 100.
Target: >= 90% to ship. < 90% → feedback loop to executor.
```

---

## REVIEW AGENT INSTRUCTIONS

```spec
ROLE: You are a review agent. You did NOT build this website.
INPUT: Live deployment URL + this checklist.
PROCESS:
  1. Open the URL in a browser (Chrome DevTools MCP or Playwright)
  2. Run through every check below
  3. Score each: PASS or FAIL
  4. Compile results with: total score, pass count, fail count, specific failures
  5. If score >= 90%: APPROVE (note failures as non-blocking improvements)
  6. If score < 90%: REJECT with specific failure list for executor to fix
OUTPUT: Structured report (pass/fail per check, total score, specific failure details)
```

---

## CHECKLIST

### A. VISUAL & LAYOUT (20 checks)

```spec
A01: ☐ Landing page renders without errors at 1440px
A02: ☐ Landing page renders without errors at 375px
A03: ☐ No horizontal scrollbar on any page at any viewport
A04: ☐ Typography hierarchy consistent (h1 > h2 > h3 visually)
A05: ☐ Color scheme consistent across all pages
A06: ☐ Dark mode works (if applicable) — toggle and verify
A07: ☐ Spacing consistent (no misaligned elements, no cramped/sparse areas)
A08: ☐ All images load (no broken image icons)
A09: ☐ Images are properly sized (no stretched/squished images)
A10: ☐ Icons render correctly (no missing/broken icons)
A11: ☐ Cards have consistent styling (borders, shadows, radius)
A12: ☐ Tables are readable (proper column widths, header styling)
A13: ☐ Forms have consistent field styling
A14: ☐ Buttons have consistent sizing and styling per variant
A15: ☐ Loading states are skeleton-shaped (not just spinners)
A16: ☐ Empty states have helpful message + CTA
A17: ☐ Error states display user-friendly message + retry
A18: ☐ 404 page exists and is styled
A19: ☐ Favicon loads
A20: ☐ Logo displays correctly
```

### B. RESPONSIVE (10 checks)

```spec
B01: ☐ Mobile navigation works (hamburger → Sheet/Drawer)
B02: ☐ Desktop navigation shows all items
B03: ☐ Hero section responsive (stacked on mobile, split on desktop)
B04: ☐ Card grids responsive (1 col mobile, 2+ col desktop)
B05: ☐ Tables scrollable or card-ified on mobile
B06: ☐ Forms full-width on mobile
B07: ☐ Modals/dialogs usable on mobile (not overflowing)
B08: ☐ Footer responsive (stacked on mobile, columns on desktop)
B09: ☐ Touch targets >= 44px on mobile
B10: ☐ Text readable without zooming on mobile
```

### C. FUNCTIONALITY (15 checks)

```spec
C01: ☐ All internal links navigate correctly
C02: ☐ All external links open in new tab
C03: ☐ Navigation active state highlights current page
C04: ☐ Forms validate on submit (show errors for invalid input)
C05: ☐ Form submit works (shows success or performs action)
C06: ☐ Buttons have hover/focus states
C07: ☐ Modals open and close correctly (Escape, backdrop, X button)
C08: ☐ Dropdowns open, navigate with keyboard, close properly
C09: ☐ Tabs switch content correctly
C10: ☐ Accordion expand/collapse works
C11: ☐ Search filters results (if search exists)
C12: ☐ Pagination works (if pagination exists)
C13: ☐ Auth flow works: signup → login → dashboard → logout (if auth)
C14: ☐ Protected pages redirect to login when not authenticated
C15: ☐ CRUD operations work: create → read → update → delete (if applicable)
```

### D. PERFORMANCE (8 checks)

```spec
TOOL: Run Lighthouse on live URL (or use Chrome DevTools performance audit)

D01: ☐ Lighthouse Performance score >= 90
D02: ☐ LCP < 2.5s
D03: ☐ CLS < 0.1
D04: ☐ INP < 200ms
D05: ☐ No render-blocking resources (fonts, CSS)
D06: ☐ Images use next/image (not raw <img>)
D07: ☐ Fonts use next/font (not external Google Fonts link)
D08: ☐ No unnecessary client-side JS (check for 'use client' overuse)
```

### E. ACCESSIBILITY (10 checks)

```spec
TOOL: Run Lighthouse accessibility audit

E01: ☐ Lighthouse Accessibility score >= 90
E02: ☐ All images have alt text
E03: ☐ All form inputs have labels
E04: ☐ Color contrast >= 4.5:1 (normal text)
E05: ☐ Skip-to-content link present
E06: ☐ Keyboard navigation works (Tab through all interactive elements)
E07: ☐ Focus indicators visible
E08: ☐ Headings follow hierarchy (no skipped levels)
E09: ☐ ARIA labels on icon-only buttons
E10: ☐ Page language set (<html lang="en">)
```

### F. SEO (8 checks)

```spec
F01: ☐ Every page has unique <title>
F02: ☐ Every page has <meta description>
F03: ☐ OG tags present (og:title, og:description, og:image)
F04: ☐ sitemap.xml accessible at /sitemap.xml
F05: ☐ robots.txt accessible at /robots.txt
F06: ☐ Canonical URLs set
F07: ☐ JSON-LD structured data on key pages
F08: ☐ No broken links (all internal links resolve)
```

### G. SECURITY (6 checks)

```spec
G01: ☐ No secrets in client-side code (check browser Sources panel)
G02: ☐ All form inputs validated server-side
G03: ☐ Auth routes protected (unauthorized → redirect to login)
G04: ☐ API routes return 401 for unauthenticated requests
G05: ☐ No console.log statements in production
G06: ☐ HTTPS enforced (automatic on Vercel)
```

### H. AGENT-BROWSABLE (7 checks)

```spec
H01: ☐ data-agent-action attributes on interactive elements
H02: ☐ data-agent-resource attributes on CRUD elements
H03: ☐ JSON-LD structured data on public pages
H04: ☐ API endpoints mirror page data
H05: ☐ Accessibility tree meaningful (snapshot readable)
H06: ☐ Status conveyed via text, not just color
H07: ☐ Descriptive link text (no "click here")
```

### I. CODE QUALITY (6 checks)

```spec
I01: ☐ TypeScript strict mode — no type errors
I02: ☐ ESLint passes (warnings OK, errors not OK)
I03: ☐ No unused imports or variables
I04: ☐ Components follow file naming convention (PascalCase)
I05: ☐ Environment variables documented (which ones are needed)
I06: ☐ Build succeeds without errors (npm run build)
```

---

## SCORING

```spec
TOTAL CHECKS: 90
PASS THRESHOLD: 81/90 (90%)

SCORING:
  90-100%  (81-90 pass)  → APPROVE — ship it
  80-89%   (72-80 pass)  → CONDITIONAL — fix critical failures, then approve
  70-79%   (63-71 pass)  → REVISE — significant issues, send back to executor
  <70%     (<63 pass)    → REBUILD — fundamental problems

CRITICAL FAILURES (auto-reject regardless of score):
  - Build does not compile
  - Landing page does not render
  - Console errors on page load
  - Authentication broken (if auth is a feature)
  - Security: secrets exposed in client code
```

## REPORT FORMAT

```spec
# Website Validation Report

**URL:** https://project.vercel.app
**Date:** YYYY-MM-DD
**Score:** XX/90 (XX%)
**Status:** APPROVE | CONDITIONAL | REVISE | REBUILD

## Summary
- Visual & Layout: XX/20
- Responsive: XX/10
- Functionality: XX/15
- Performance: XX/8
- Accessibility: XX/10
- SEO: XX/8
- Security: XX/6
- Agent-Browsable: XX/7
- Code Quality: XX/6

## Failures
| Check | Status | Details |
|-------|--------|---------|
| A03   | FAIL   | Horizontal scroll on /pricing at 375px |
| C13   | FAIL   | Signup form returns 500 error |
| ...   | ...    | ... |

## Recommendations
1. [CRITICAL] Fix signup form server error
2. [HIGH] Fix horizontal overflow on pricing page mobile
3. [MEDIUM] Add alt text to 3 hero images
4. [LOW] Improve LCP on /dashboard (currently 2.8s)
```
