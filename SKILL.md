---
name: website-genome
description: Agent OS for building or replicating any website. Provides the full pipeline (extract → spec → build → verify) plus web pattern vocabulary for detecting interaction types. Triggers on Next.js project files and website-related commands.
metadata:
  filePattern:
    - "**/page.tsx"
    - "**/layout.tsx"
    - "**/next.config.*"
    - "**/globals.css"
    - "**/GENOME.md"
    - "**/specs/**"
  bashPattern:
    - "create-next-app"
    - "npx shadcn"
    - "site-crawler"
    - "existing-chrome"
    - "npm run dev"
    - "npm run build"
    - "next start"
  priority: 90
---

# Website Genome OS v2.2

Agent operating system for building or replicating any website.
Input: URL (to copy) or checklist (to build from scratch).
Output: Production-ready Next.js website deployed on Vercel.

## Quick Start

```
COPY mode:  I have a URL to replicate    → read GENOME.md §COPY
BUILD mode: I have a checklist           → read GENOME.md §BUILD
FIX mode:   I have a replica to improve  → read GENOME.md §FIX
```

## Files in This Skill

| File | Purpose | When to Read |
|------|---------|--------------|
| `GENOME.md` | The process — steps, gates, principles | ALWAYS read first |
| `vocabulary.md` | Web pattern detection — what to look for | Read before EXTRACT (Step 3) |
| `reference/` | Deep component/template/token specs | Read on demand during BUILD |

## How to Use

1. Read `GENOME.md` — your operating system. Follow it exactly.
2. Before Step 3 (EXTRACT), read `vocabulary.md` — it tells you what interaction patterns to detect on the target site.
3. During BUILD, pull `reference/` files on demand for specific component patterns.

## Human Setup (the ONLY manual step — auth-gated sites only)

The `existing-chrome` skill drives your REAL, already-logged-in Chrome via CDP — no
relaunch needed. First use in a session: Chrome will show an "Allow remote debugging"
prompt — click Allow. Everything after that is autonomous.

(Public-only sites skip this entirely — site-crawler + Playwright need no browser login.)

## 10 Principles (burned into this OS from 4 site replications)

1. EXTRACT > IMAGINE — every pixel traces to observed data
2. SPECS BEFORE CODE — no React until spec files exist
3. DASHBOARD FIRST — auth-gated pages are the product
4. ASSETS > CODE — real images are the #1 quality lever
5. VERIFY THEN REPORT — run all gates before telling the human
6. CLICK, DON'T SCREENSHOT — clicking tests behavior, not just rendering
7. PRODUCTION BUILD FOR VERIFICATION — npm run build && npx next start
8. QUALITY SYSTEM, NOT CHECKLIST — "I did something" ≠ "I did it completely"
9. MEGA-MENUS ARE COMPONENTS, NOT LINK LISTS — extract as visual units
10. COMPARE BOTH SITES FOR EVERY CHECK — never evaluate replica alone
