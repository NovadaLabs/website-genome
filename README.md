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
| **Chrome debug launcher** | Script to launch Chrome with CDP port | Lets agents connect to your logged-in Chrome | See setup below |

### Nice to Have (enhances quality but not blocking)

| Requirement | What | Why | Install |
|------------|------|-----|---------|
| **Vercel CLI** | Deployment tool | Auto-deploys to Vercel | `npm i -g vercel` then `vercel login` |
| **Vercel account** | Hosting | Free tier works | [vercel.com/signup](https://vercel.com/signup) |
| **site-crawler** | Automated extraction | Crawls entire sites in one command | `pip install -e .` from NovadaLabs/site-crawler |
| **Playwright** | Headless browser | Backup extraction for public pages | `pip install playwright && playwright install chromium` |
| **bb-browser skill** | Browser automation | Primary extraction tool (agent uses your Chrome) | Copy to `~/.claude/skills/bb-browser/` |
| **gstack skill** | QA testing | Responsive testing at 375/768/1440px | Copy to `~/.claude/skills/gstack/` |

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

The agent CANNOT log in by itself. It always opens a fresh browser with zero sessions. The ONLY way to give the agent access to logged-in pages is to share YOUR Chrome profile — with YOUR cookies and sessions — via the CDP (Chrome DevTools Protocol) pipeline.

**How it works:**

```
YOUR Chrome (logged in)  →  CDP pipeline copies cookies  →  Debug Chrome (logged in + agent-accessible)
     ↑                              ↑                              ↑
  You log in here             One command does this         Agent connects here
```

**Step-by-step:**

```
STEP 1: Log into the target website in your NORMAL Chrome
  → Open Chrome as you normally do
  → Go to the website you want to replicate (e.g. https://brightdata.com)
  → Log in with your account
  → Navigate to the dashboard — confirm you can see your logged-in content
  → Leave Chrome open (don't close it yet)

STEP 2: Run the CDP launcher (ONE command)
  → Open your terminal and run:

    cd ~/Projects/agent-chrome-bridge && npm run launch-chrome

  → What this does:
    1. Closes your current Chrome
    2. Copies your cookies and sessions to a temporary profile
    3. Relaunches Chrome with a debug port (9222) using those cookies
    4. The new Chrome window has ALL your login sessions

  → This is the bridge between "human is logged in" and "agent can access logged-in pages"

STEP 3: Verify your logins survived
  → Chrome reopens automatically
  → Go to the target website's dashboard
  → Are you still logged in?
    YES → You're ready. The agent can now see everything you can see.
    NO  → Log in again in THIS Chrome window. Your session will be available to the agent.

STEP 4: Tell the agent to start
  → The agent connects to this Chrome on port 9222
  → It can browse both public pages AND your logged-in dashboard
  → You can WATCH the agent work in your Chrome in real-time
  → Each agent opens its own tab — you'll see tabs appearing and pages loading
```

**Important notes:**
- You need to run `npm run launch-chrome` EVERY TIME you start a new replication session (cookies expire)
- If you need to replicate a site you haven't logged into yet, log in FIRST in normal Chrome, THEN run the launcher
- The agent never sees your passwords — it only gets the session cookies (same as "remember me" on a website)
- This works because Chrome 146+ blocks direct debug access to your default profile, so the pipeline copies cookies to a temp profile that allows debug access

**Don't have the CDP launcher?**

```bash
# First time setup (one-time)
# agent-chrome-bridge is a separate tool from site-crawler — clone it directly:
git clone https://github.com/NovadaLabs/agent-chrome-bridge ~/Projects/agent-chrome-bridge
cd ~/Projects/agent-chrome-bridge && npm install

# Then every time you need it:
cd ~/Projects/agent-chrome-bridge && npm run launch-chrome
```

**Only replicating public pages (no login needed)?**
Skip this entire section. The agent will use headless Playwright for public pages. But you won't get any dashboard or logged-in pages.

**What if you only want to replicate public pages?**
Skip Steps 1-4. The agent will use headless Playwright for public pages. No Chrome needed. But you won't get dashboard pages.

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

The genome is a 534-line process document that agents follow step-by-step:

```
LAYER 0: MISSION         → Route to COPY / BUILD / FIX mode
LAYER 1: TOOLS           → bb-browser, site-crawler, Chrome CDP
§COPY PIPELINE           → CONNECT → CRAWL → EXTRACT → COMPONENTS → HUMAN GATE → BUILD → VERIFY
§BUILD PIPELINE          → CHECKLIST → SPECS → SCAFFOLD → BUILD (8 phases) → VERIFY
§FIX PIPELINE            → DASHBOARD FIRST → COMPARE → FIX → VERIFY
LAYER 3: QUALITY GATES   → Hard gates (must-pass) + soft gates (target)
LAYER 4: REFERENCE       → 24 deep reference files, read on demand
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
# 1. Human launches Chrome with login sessions (the ONLY manual step)
cd ~/Projects/agent-chrome-bridge && npm run launch-chrome

# 2. Agent takes over
"Replicate https://example.com — follow the website-genome skill"
```

The agent will:
1. Connect to Chrome via bb-browser
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
├── reference/        # 24 deep reference files — read on demand during BUILD
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
| bb-browser | Browser automation via user's Chrome (login sessions) | Claude Code skill |
| gstack | Responsive QA testing at 375/768/1440px | Claude Code skill |

## Version History

| Version | Lines | Validated On | Key Addition |
|---------|-------|-------------|-------------|
| v1.0 | 24 files (~210KB) | novada.com | Full knowledge base |
| v2.0 | 400 | — | Single file, 5 layers, 7 principles |
| v2.1 | 476 | iploop.io | Chrome step 0, human gate, quality system mindset |
| v2.2 | 534 | brightdata.com | Component extraction, visual comparison, 10 principles |

## Video Script Outline (for internal recording)

1. **Intro (30s):** What is the genome? One-line pitch.
2. **Demo: Copy Mode (3-5 min):**
   - Show Chrome launch command
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
