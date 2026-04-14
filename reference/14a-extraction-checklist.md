# 14a — Extraction Pre-Flight Checklist

> Scan this before ANY extraction or fix-forward work. Each item takes <1 min.
> Full details: 14-extraction-sop.md §[section number]
> PRIMARY TOOL: bb-browser (user's real Chrome with login sessions)
> BACKUP TOOLS: Chrome CDP pipeline → Chrome DevTools MCP → Playwright headless

## CONNECT + DASHBOARD FIRST (§0) — DO THIS BEFORE ANYTHING ELSE

```checklist
[ ] bb-browser open <target-url> — does it open in user's Chrome?
    → If bb-browser not working: fallback to CDP (human runs: cd ~/Projects/agent-chrome-bridge && npm run launch-chrome)
[ ] Navigate to target site's LOGIN page — is human's session active?
[ ] If auth-gated pages exist: bb-browser open <dashboard-url> RIGHT NOW
    → Can you see logged-in content? If yes, capture FULL structure immediately
    → bb-browser snapshot -i → click every @ref sidebar item → capture each
    → This is Step 0, not Step 10. THREE agents skipped this. Don't be the fourth.
[ ] If session expired: tell human to re-login in their Chrome
```

## STRUCTURED EXTRACTION (not screenshots!) (§capture)

```checklist
AI understands structured data, not pixels. Capture in this order:
[ ] bb-browser snapshot -i → element tree with @refs (structure)
[ ] bb-browser snapshot --json → machine-parseable JSON (for handoff)
[ ] bb-browser eval "document.querySelector('nav').outerHTML" → exact nav HTML
[ ] bb-browser eval "document.querySelector('main').outerHTML" → exact page HTML
[ ] bb-browser eval "<css extraction script>" → design tokens (colors, fonts, spacing)
[ ] Screenshots are ONLY for human QA — not the primary extraction artifact
```

## CRAWL (§0.5)

```checklist
[ ] Run automated link crawl from homepage (collect all internal + subdomain URLs)
    → bb-browser eval "[...document.querySelectorAll('a[href]')].map(a=>a.href).filter(h=>h.includes(location.hostname))"
[ ] Classify each URL: INTERNAL / PRODUCT-SUBDOMAIN / EXTERNAL
[ ] Total pages discovered: ___
```

## DISCOVER (§1)

```checklist
[ ] Captured all top-level nav items and their destinations?
[ ] Captured all sidebar items (for dashboard/app pages)?
    → bb-browser snapshot -i → list all sidebar @refs → click each → capture
[ ] Captured all footer links?
[ ] Checked for sub-tabs on each page?
```

## INTERACTIVE CAPTURE (§1.5) — MOST COMMONLY SKIPPED

```checklist
[ ] Hovered EVERY navbar dropdown → bb-browser hover @ref → snapshot -i each
[ ] Clicked EVERY sidebar item → bb-browser click @ref → captured each destination
[ ] Clicked EVERY tab → bb-browser click @ref → captured each tab's content
[ ] Clicked EVERY button that opens a modal → captured modal content
[ ] Recorded layout type for each dropdown (simple list vs mega-menu vs multi-column)
[ ] For each interactive state: captured the HTML (eval outerHTML), not just screenshot
```

## ASSET COLLECTION (§2.7) — DO THIS BEFORE BUILDING

```checklist
[ ] bb-browser eval to collect ALL <img> src URLs from every page?
    → bb-browser eval "[...document.querySelectorAll('img')].map(i=>({src:i.src,alt:i.alt}))"
[ ] Collected all inline SVGs (logo, icons)?
    → bb-browser eval "document.querySelector('.logo svg')?.outerHTML"
[ ] Downloaded assets to /public/images/?
[ ] Count: original has N images, I have M downloaded. M/N >= 80%?
[ ] Logo is real brand SVG/PNG, not text placeholder?
[ ] Hero images downloaded (not represented as colored divs)?
Zero images = wireframe, not replica. This is the #1 visual gap.
Do NOT start building until key assets are downloaded.
```

## SPEC FILES GATE (§5) — NO CODE UNTIL THESE EXIST

```checklist
[ ] specs/research.md — what is this site, tech stack, audience?
[ ] specs/prd.md — filled from genome/18-prd-template.md
[ ] specs/tech-rd.md — filled from genome/19-tech-rd-template.md
[ ] specs/sitemap.json — every URL classified
[ ] specs/design-tokens.json — colors, fonts, spacing from original
[ ] specs/interactions.json — every interactive element mapped
[ ] specs/assets-needed.json — every image URL listed
[ ] specs/assets/ — downloaded images, SVGs, fonts
No code until specs exist. The specs ARE the product of extraction.
```

## VERIFY (§6)

```checklist
[ ] Link audit: 0 broken internal links?
[ ] Screenshot compare: replica vs original for each page built?
    → Use gstack skill for responsive testing at 375px, 768px, 1440px
[ ] Interactive verify: every dropdown/tab/form works same as original?
[ ] Navigation test: clicked through 5+ user paths end-to-end?
[ ] External link scan: 0 links to original product domains?
[ ] Content depth: replica pages have >=60% of original's sections?
[ ] DASHBOARD GATE: every sidebar item → real page (not placeholder)
[ ] ASSET GATE: replica images >= 50% of original's image count
```
