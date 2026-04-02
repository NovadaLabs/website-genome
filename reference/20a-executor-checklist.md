# 20a — Executor Pre-Flight Checklist

> Scan this before building or fixing any website. Each item takes <1 min.
> Full details: 20-executor-sop.md §[section number]

## BEFORE WRITING ANY CODE

```checklist
[ ] If auth-gated site: navigate to dashboard URL in Chrome DevTools MCP RIGHT NOW
    → Is human logged in? If yes, capture full structure BEFORE anything else
    → THREE agents skipped this. It's Step 0, not optional.
[ ] Read the project checklist / handoff document
[ ] Read the referenced SOP sections (not just the handoff — the actual SOPs)
[ ] If fix-forward: read SOP 20 §FIX-FORWARD (all 5 steps)
[ ] If replication: run 14a-extraction-checklist.md FIRST
[ ] Download key assets (logo, hero images) BEFORE building — 0 images = wireframe
```

## SCAFFOLD (Phase 1)

```checklist
[ ] Next.js 16 + shadcn/ui + Geist + Tailwind
[ ] Design tokens configured (colors, fonts, spacing)
[ ] npm run dev works without errors
```

## LAYOUTS (Phase 2)

```checklist
[ ] Root layout: html + body + providers
[ ] Marketing layout: Navbar + Footer
[ ] Dashboard layout: Sidebar + TopBar (if needed)
[ ] Auth layout: centered card (if needed)
```

## PAGES (Phase 3+)

```checklist
[ ] Build in order: landing → products → pricing → auth → dashboard
[ ] Each page: match original's section count (not just hero + CTA)
[ ] Each page: check interactive elements work
```

## PHASE EXIT (after EVERY phase)

```checklist
[ ] Link audit: 0 broken links
[ ] Screenshot compare (for replication)
[ ] Interactive verify (for replication)
[ ] Navigation test: 5+ user paths
[ ] Content depth audit: >=60% of original's sections per page
[ ] DASHBOARD GATE: every sidebar item → real page (not placeholder)
[ ] ASSET GATE: replica images >= 50% of original's image count
[ ] Commit + push
```

## NEVER DECLARE DONE UNTIL:

```checklist
[ ] All exit criteria above pass
[ ] Report includes: pages built, broken links count, verification results
[ ] Report lists remaining gaps HONESTLY
```
