# Website Genome OS

An agent operating system for building or replicating any website autonomously.

Give it a URL — it extracts, builds, and deploys a pixel-perfect Next.js replica. Give it a checklist — it builds a production site from scratch.

## Your Job (Human) vs Agent's Job

```
┌─ HUMAN (one-time setup + 2 min per site) ──────────────────────┐
│                                                                 │
│  1. Install prerequisites (see below) ........... one-time      │
│  2. Log into the target site in Chrome .......... 1 min         │
│  3. Launch Chrome with debug port ............... 1 command     │
│  4. Tell the agent: "replicate https://..." ..... 1 sentence    │
│  5. (Optional) Review extraction before build ... 2 min         │
│                                                                 │
│  That's it. Everything below is the agent's job.                │
└─────────────────────────────────────────────────────────────────┘

┌─ AGENT (fully autonomous after human setup) ───────────────────┐
│                                                                 │
│  Crawl every page → Extract HTML/CSS/assets → Build specs →     │
│  Scaffold Next.js → Build all pages → Wire interactions →       │
│  Verify quality gates → Deploy to Vercel → Report with numbers  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Prerequisites (Human Setup)

### Quick Check (can you see all greens?)

```
Run this in your terminal to see what you have:

  claude --version        →  Claude Code ........... Required
  node --version          →  Node.js 22+ .......... Required
  git --version           →  Git .................. Required
  gh auth status          →  GitHub CLI ........... Required
  vercel --version        →  Vercel CLI ........... Optional
  which site-crawler      →  site-crawler ......... Optional
```

If anything required is missing, pick Option A or B below.

### Option A: Let AI do it (recommended for most people)

Paste this one command into Claude Code:

```
Read ~/.claude/skills/website-genome/README.md and check what prerequisites I'm missing. Install everything you can. For things that need my action (accounts, Chrome login), tell me exactly what to do step by step.
```

The agent will check your system, install what's missing, and walk you through the rest.

### Option B: Do it yourself (for people who want full control)

#### Must Have (skill won't work without these)

| Requirement | What | Why | Install |
|------------|------|-----|---------|
| **Claude Code** | Anthropic's CLI agent | Runs the skill, dispatches agents | `npm i -g @anthropic-ai/claude-code` |
| **Node.js 22+** | JavaScript runtime | Builds the Next.js website | `brew install node` or [nodejs.org](https://nodejs.org) |
| **npm** | Package manager | Installs dependencies | Comes with Node.js |
| **Git** | Version control | Commits and pushes code | `brew install git` |
| **GitHub CLI** | `gh` command | Creates repos, manages PRs | `brew install gh` then `gh auth login` |
| **Google Chrome** | Browser | Agent uses your login sessions for extraction | [chrome.com](https://www.google.com/chrome/) |
| **existing-chrome skill** | CDP bridge to your real Chrome | Lets agents connect to your already-logged-in Chrome, no relaunch | Already in `~/.claude/skills/existing-chrome/` on this machine — see setup below |

### Nice to Have (enhances quality but not blocking)

| Requirement | What | Why | Install |
|------------|------|-----|---------|
| **Vercel CLI** | Deployment tool | Auto-deploys to Vercel | `npm i -g vercel` then `vercel login` |
| **Vercel account** | Hosting | Free tier works | [vercel.com/signup](https://vercel.com/signup) |
| **site-crawler** | Automated extraction | Crawls entire sites in one command | `pip install -e .` from NovadaLabs/site-crawler |
| **Playwright** | Headless browser | Backup extraction for public pages | `pip install playwright && playwright install chromium` |
| **opencli skill** | Named-site automation | Fallback for site-specific actions (posting, not just reading) | Already in `~/.claude/skills/opencli/` on this machine |
| **chrome-devtools MCP** | Responsive QA | Resize + screenshot the BUILT REPLICA at 375/768/1440px | Bundled MCP tool, no separate install |

### Chrome Setup — THE Most Important Step

**Why this matters:**

```
Without this step:
  Agent opens a FRESH Chrome → no logins → sees only public pages
  Result: homepage ✅, dashboard ❌, settings ❌, billing ❌

With this step:
  Agent uses YOUR Chrome → your logins → sees EVERYTHING
  Result: homepage ✅, dashboard ✅, settings ✅, billing ✅
```

Most websites have two sides:
- **Before login**: marketing pages, pricing, docs (anyone can see)
- **After login**: dashboard, settings, billing, user data (the REAL product)

The agent CANNOT log in by itself. The ONLY way to give it access to logged-in pages
is the `existing-chrome` skill, which drives YOUR real, already-open Chrome over CDP.

> **History note (fixed 2026-10-14):** an earlier version of this doc described a
> "CDP launcher" that closed your Chrome and relaunched it on a debug port with your
> cookies copied over. That approach broke when Chrome 136+ started blocking direct
> debug access to the default profile outright — the relaunch-with-copied-cookies
> trick doesn't restore it. `existing-chrome` works differently (reads
> `DevToolsActivePort` from your running Chrome, no relaunch) and is what actually
> works today. If you find an older copy of this skill referencing
> `agent-chrome-bridge` / `npm run launch-chrome` / `bb-browser`, it's stale — use
> this version instead.

**How it works:**

```
YOUR Chrome (already open, already logged in)  →  existing-chrome reads its CDP port  →  Agent connects
     ↑                                                      ↑
  You log in here, normally, once                 No relaunch, no cookie copying
```

**Step-by-step:**

```
STEP 1: Log into the target website in your NORMAL Chrome (the one you already have open)
  → Go to the website you want to replicate (e.g. https://brightdata.com)
  → Log in with your account
  → Navigate to the dashboard — confirm you can see your logged-in content
  → Leave Chrome open

STEP 2: Let the agent connect (no manual command needed — the agent does this)
  → The agent runs the existing-chrome skill's daemon in the background
  → First time this session: Chrome shows an "Allow remote debugging" popup
    → Click Allow (you only do this once per Chrome restart, not once per site)
  → The agent verifies it can see your real tabs before proceeding

STEP 3: Tell the agent to start
  → It can browse both public pages AND your logged-in dashboard, in YOUR Chrome
  → You can WATCH it work in real-time — each agent opens its own tab
```

**Important notes:**
- No relaunch, no temp profile, no cookie-copying — it reads your Chrome as-is.
- You only click "Allow remote debugging" once per Chrome restart (the daemon holds
  one connection open and reuses it — repeated connections would re-trigger the prompt).
- The agent never sees your passwords — same trust boundary as before (session access,
  not credentials).

**Only replicating public pages (no login needed)?**
Skip this entire section. The agent uses `site-crawler` + headless Playwright for public
pages — no Chrome, no login, nothing to set up. You won't get dashboard/logged-in pages this way.

### Account Setup (one-time, human only)

These require human action — agents cannot do them:

1. **GitHub:** Create account at github.com, then run `gh auth login` in terminal
2. **Vercel:** Create account at vercel.com, then run `vercel login` in terminal
3. **Target site:** Log into the website you want to replicate (Step 1 above)

### Quick Verification

Run this to check your setup:

```bash
claude --version          # Should show Claude Code version
node --version            # Should be 22+
git --version             # Should be installed
gh auth status            # Should show logged in
vercel --version          # Optional but recommended
```

## How It Works

The genome is a ~480-line process document that agents follow step-by-step:

```
LAYER 0: MISSION         → Route to COPY / BUILD / FIX mode
LAYER 1: TOOLS           → existing-chrome, site-crawler, opencli
§COPY PIPELINE           → CONNECT → CRAWL → EXTRACT → COMPONENTS → HUMAN GATE → BUILD → VERIFY
§BUILD PIPELINE          → CHECKLIST → SPECS → SCAFFOLD → BUILD (8 phases) → VERIFY
§FIX PIPELINE            → DASHBOARD FIRST → COMPARE → FIX → VERIFY
LAYER 3: QUALITY GATES   → Hard gates (must-pass) + soft gates (target)
LAYER 4: REFERENCE       → 25 deep reference files, read on demand
```

The VERIFY step runs a **VERIFY → REFLECT → ACT** loop (max 3 iterations) — the agent self-corrects before presenting results.

## Installation

### As a Claude Code Skill (recommended)

Copy the skill folder to your Claude Code skills directory:

```bash
cp -r website-genome ~/.claude/skills/
```

The skill auto-triggers when agents touch website files (`page.tsx`, `next.config.*`, `globals.css`, etc.).

### As a Standalone Agent

Copy the agent definition:

```bash
cp website-builder.md ~/.claude/agents/
```

Then dispatch it:
```
Agent(subagent_type="website-builder", prompt="replicate https://example.com")
```

## Usage

### Copy Mode — Replicate a website

```
# 1. Human: log into the target site in your normal Chrome, leave it open
#    (the agent connects to it via the existing-chrome skill — click "Allow
#    remote debugging" if Chrome prompts for it, that's the only manual step)

# 2. Agent takes over
"Replicate https://example.com — follow the website-genome skill"
```

The agent will:
1. Connect to Chrome via the existing-chrome skill
2. Crawl every URL on the site
3. Extract HTML, CSS, screenshots, assets, component structures per page
4. Present extraction results for approval (complex sites only)
5. Build the Next.js replica from extracted data
6. Run VERIFY → REFLECT → ACT loop until quality gates pass
7. Deploy to Vercel

### Build Mode — Create from scratch

```
# Fill the project checklist
"Build a marketing website for [brand] — follow the website-genome skill"
```

### Fix Mode — Improve an existing replica

```
"Fix ~/Projects/my-replica/ — compare against https://original.com"
```

## File Structure

```
website-genome/
├── SKILL.md          # Skill entry point — auto-triggers, 10 principles
├── GENOME.md         # The process (534 lines) — the agent's operating system
├── vocabulary.md     # Web pattern vocabulary (60+ patterns) — what to look for
├── reference/        # 25 deep reference files — read on demand during BUILD
│   ├── 01-first-principles.md
│   ├── 02-design-tokens.md
│   ├── 03-atomic-elements.md     (43 UI atoms)
│   ├── 04-components.md          (22 molecules + organisms)
│   ├── 05-page-templates.md      (10 layout skeletons)
│   ├── 06-page-types.md          (page catalog + sitemap patterns)
│   ├── 07-interactions.md        (interaction patterns)
│   ├── 08-state-data.md          (state management + data layer)
│   ├── 09-invisible-layer.md     (SEO, a11y, performance, security)
│   ├── 10-agent-browsable.md     (agent-first web design)
│   ├── 11-error-edge-cases.md    (loading, error, empty states)
│   ├── 12-responsive.md          (breakpoint specs)
│   ├── 13-content-strategy.md    (text, images, icons sourcing)
│   ├── 16-validation.md          (90-point review checklist)
│   └── ...
└── README.md         # This file
```

## Web Pattern Vocabulary

The vocabulary gives agents "web literacy" — the ability to recognize what they're looking at before extraction. Categories:

| Category | Patterns | Examples |
|----------|----------|---------|
| Navigation | 11 patterns | simple-links, mega-menu, flyout, sidebar-popup, mobile-hamburger |
| Content | 17 patterns | hero-with-image, feature-grid, pricing-toggle, FAQ-accordion, code-sample |
| Interactive | 23 patterns | hover-reveal, click-modal, scroll-lazy, carousel-auto, form-multi-step |
| Dashboard | 14 patterns | stat-cards, data-table, sidebar-popup, settings-tabs, empty-state |
| Page Types | 14 signatures | marketing-landing, product-page, dashboard-home, blog-post, auth-page |

Agents scan this before extraction to know what patterns to detect and how to extract each one.

## 10 Principles

Burned into the OS from 4 real site replications (novada.com, iploop.io, brightdata.com):

1. **EXTRACT > IMAGINE** — every pixel traces to observed data
2. **SPECS BEFORE CODE** — no React until spec files exist
3. **DASHBOARD FIRST** — auth-gated pages are the product
4. **ASSETS > CODE** — real images are the #1 quality lever
5. **VERIFY THEN REPORT** — run all gates before telling the human
6. **CLICK, DON'T SCREENSHOT** — clicking tests behavior, not just rendering
7. **PRODUCTION BUILD FOR VERIFICATION** — `npm run build && npx next start`
8. **QUALITY SYSTEM, NOT CHECKLIST** — "I did something" != "I did it completely"
9. **MEGA-MENUS ARE COMPONENTS, NOT LINK LISTS** — extract as visual units
10. **COMPARE BOTH SITES FOR EVERY CHECK** — never evaluate replica alone

## Tech Stack

Output websites use:
- Next.js 16 (App Router, Server Components)
- Tailwind CSS 4 + shadcn/ui
- Geist Sans + Geist Mono
- Vercel (deployment)

## Companion Tools

| Tool | Purpose | Repo |
|------|---------|------|
| site-crawler | Automated extraction (HTML, CSS, assets, Markdown per page) | NovadaLabs/site-crawler |
| existing-chrome | Browser automation via user's real Chrome (CDP, login sessions) | Claude Code skill |
| opencli | Named-site adapters (X, LinkedIn, Bilibili, etc.) | Claude Code skill |
| chrome-devtools MCP | Responsive QA (resize + screenshot) on the built replica | Bundled MCP tool |

## Version History

| Version | Lines | Validated On | Key Addition |
|---------|-------|-------------|-------------|
| v1.0 | 24 files (~210KB) | novada.com | Full knowledge base |
| v2.0 | 400 | — | Single file, 5 layers, 7 principles |
| v2.1 | 476 | iploop.io | Chrome step 0, human gate, quality system mindset |
| v2.2 | 534 | brightdata.com | Component extraction, visual comparison, 10 principles |
| v2.3 | ~480 | — (maintenance pass) | Fixed dead `reference/` symlink + stale Chrome tooling (bb-browser/agent-chrome-bridge/gstack → existing-chrome/opencli/chrome-devtools MCP); added stack-migration override to §COPY |

## Video Script Outline (for internal recording)

1. **Intro (30s):** What is the genome? One-line pitch.
2. **Demo: Copy Mode (3-5 min):**
   - Show Chrome "Allow remote debugging" prompt (one-time per session)
   - Agent reads GENOME.md
   - Extraction: crawl → specs folder populated
   - Build: pages appearing one by one
   - Verify: side-by-side comparison
   - Deploy: live URL
3. **How it works (2 min):**
   - Walk through the 5 layers
   - Show vocabulary.md — "web literacy"
   - Show a quality gate check
4. **Results (1 min):**
   - 3 sites replicated, quality scores
   - Before/after: 24 files nobody reads → 1 file agents follow
5. **Next steps (30s):**
   - BUILD mode validation
   - MCP tool integration
   - Team rollout

Total: ~8 minutes
