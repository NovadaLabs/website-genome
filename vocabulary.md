# Web Pattern Vocabulary

> Read this BEFORE extraction (GENOME.md Step 3).
> For each page, scan this list and identify which patterns exist.
> Record detected patterns in specs/interactions.json.
> If you don't check for a pattern, you won't extract it. If you don't extract it, you'll invent it.

---

## NAVIGATION PATTERNS — "How do users move between pages?"

```
PATTERN              DETECT BY                                    EXTRACT METHOD
─────────────────────────────────────────────────────────────────────────────────
simple-links         <nav> with plain <a> tags, no sub-menus      snapshot link text + href
dropdown-list        hover nav item → single-column list appears  hover → screenshot + outerHTML
mega-menu            hover → full-width panel, multiple columns   hover → screenshot + outerHTML + column structure
flyout               hover → cascading sub-menu to the side       hover → screenshot each level
tabbed-nav           tabs above content (Products | Solutions)    click each tab → capture content change
search-nav           search input or Cmd+K trigger in header      snapshot search UI + results panel
breadcrumb           "Home > Products > Proxies" path trail       snapshot text + links
sidebar-nav          vertical nav panel (dashboard apps)          click every item → capture destination
sidebar-popup        hover sidebar icon → floating sub-menu       hover each icon → screenshot popup
sidebar-collapse     sidebar toggles between wide/icon-only       click toggle → capture both states
mobile-hamburger     ☰ icon → slide-out or overlay menu           click → capture open state
```

## CONTENT PATTERNS — "What types of sections exist on pages?"

```
PATTERN              DETECT BY                                    EXTRACT METHOD
─────────────────────────────────────────────────────────────────────────────────
hero-section         large heading + subtext + CTA at page top    screenshot + outerHTML
hero-with-image      hero split: text left, image/screenshot right  capture both halves
hero-with-video      hero with embedded video or animation        capture thumbnail + video source
feature-grid         3-4 column card grid with icons              count cards + extract each card structure
feature-alternating  text left/image right alternating rows       capture each row pair
bento-grid           asymmetric card layout (different sizes)     screenshot + record grid dimensions
stats-bar            row of numbers (100M+, 99.99%, etc.)         extract exact numbers + labels
logo-carousel        partner/client logo strip (may auto-scroll)  extract all logo images
testimonial-cards    quote + avatar + name + company              extract each card
pricing-table        plan comparison grid with prices             extract ALL plans + features + prices
pricing-toggle       monthly/annual switch changes prices         click toggle → capture both states
code-sample          code block with language tabs                capture code + all language variants
CTA-section          colored banner with headline + button        screenshot + text + button targets
FAQ-accordion        expandable question/answer pairs             click each → capture answers
timeline             vertical sequence of events/steps            capture all steps
comparison-table     feature comparison matrix with checkmarks    extract full table structure
tab-content          tabs that switch visible content             click EVERY tab → capture each
```

## INTERACTIVE PATTERNS — "What happens when the user interacts?"

```
PATTERN              DETECT BY                                    EXTRACT METHOD
─────────────────────────────────────────────────────────────────────────────────
hover-color          element changes bg/text color on hover       hover → note color change
hover-shadow         element gains shadow on hover                hover → note shadow
hover-scale          element slightly grows on hover              hover → note scale
hover-reveal         hidden icons/buttons appear on hover         hover → screenshot revealed content
hover-underline      text gets underline on hover                 hover → note
hover-preview        card/image preview appears on hover          hover → screenshot preview
click-navigate       click → go to new URL                        click → record destination
click-modal          click → dialog/modal overlay appears         click → screenshot + capture modal HTML
click-sheet          click → slide-out panel from side            click → screenshot + capture panel HTML
click-dropdown       click → dropdown menu appears below          click → screenshot + capture menu HTML
click-accordion      click → section expands to show content      click → capture expanded content
click-tab            click → content area switches                click each → capture each state
click-copy           click → copies text to clipboard + toast     click → verify toast appears
click-toggle         click → switches state (on/off, theme)       click → capture both states
scroll-lazy          new content loads as user scrolls down       scroll full page before capturing
scroll-sticky        element sticks to top on scroll              scroll → note which elements stick
scroll-parallax      background moves at different speed          note (hard to replicate, document)
scroll-animate       elements animate in as they enter viewport   scroll → note which elements animate
form-validation      submit empty form → error messages appear    submit → capture error states
form-autocomplete    typing → suggestions appear below input      type → capture suggestion dropdown
form-multi-step      form has steps/wizard (step 1 → 2 → 3)      navigate each step → capture all
drag-drop            items can be dragged to reorder              note (document for later implementation)
infinite-scroll      scroll to bottom → more items load           scroll → count total items loaded
carousel-manual      arrows to slide content left/right           click arrows → capture all slides
carousel-auto        content auto-scrolls on timer                note interval + capture all slides
filter-sort          filter/sort controls change visible items    apply each → capture result
```

## DASHBOARD PATTERNS — "What does the app look like after login?"

```
PATTERN              DETECT BY                                    EXTRACT METHOD
─────────────────────────────────────────────────────────────────────────────────
stat-cards           grid of KPI cards (number + label + trend)   extract each: number, label, trend, icon
data-table           sortable/filterable table with rows          extract headers + sample rows + controls
chart-panel          line/bar/pie chart with controls             screenshot + extract data if visible
date-picker          date range selector for filtering data       click → capture calendar UI
activity-feed        chronological list of events                 extract recent items
quick-actions        prominent buttons for common tasks           extract button text + destinations
settings-tabs        tabbed settings (General, Security, etc.)    click EVERY tab → capture each panel
profile-card         user avatar + name + email + edit            screenshot + extract fields
notification-panel   bell icon → dropdown of notifications        click → capture panel
billing-page         plan display + payment + invoices            capture plan details + invoice table
API-keys             key list with copy/reveal/delete             capture key format + actions
usage-meter          progress bar or chart showing usage/limits   extract numbers + limits
empty-state          no-data view with message + CTA              capture (often missed — check empty pages)
onboarding-wizard    multi-step setup flow for new users          navigate each step → capture all
api-playground       form + submit + code panel + output          intercept API calls, capture endpoint/params/response, code per language
endpoint-generator   form → generates connection config           capture all dropdown options + code templates per language
proxy-config         address/port/username/password display       extract all values + code samples for all languages
```

## PAGE TYPE SIGNATURES — "What type of page am I looking at?"

```
PAGE TYPE            SIGNATURE (what makes it recognizable)       KEY THINGS TO EXTRACT
─────────────────────────────────────────────────────────────────────────────────
marketing-landing    hero + features + social-proof + CTA         every section in order
product-page         hero + feature-detail + pricing + code       inline pricing table is often missed
pricing-page         plan grid + feature comparison + FAQ         ALL plan tiers + toggle states
about-page           mission + team + values + timeline           team photos, company stats
blog-listing         card grid + categories + pagination          card structure + pagination
blog-post            article header + prose + author + related    full article HTML (don't summarize)
docs-page            sidebar-nav + prose + TOC                    nav tree + content + heading structure
legal-page           long prose (privacy, terms)                  full text (don't abbreviate)
auth-page            centered card with form                      form fields + social login buttons
dashboard-home       stat-cards + activity + quick-actions        every widget
dashboard-list       data-table + filters + pagination            table structure + filter options
dashboard-detail     header + tabs + detail content               every tab's content
dashboard-settings   tabs + form per tab                          every tab + every form field
error-page           centered message + CTA                       message text + link destination
```

---

## HOW TO USE THIS VOCABULARY

**During EXTRACT (Step 3):**
1. Open the page
2. Scan this vocabulary — which patterns do you see?
3. For each detected pattern, follow the EXTRACT METHOD column
4. Record findings in specs/interactions.json:
   ```json
   {
     "page": "/",
     "patterns_detected": ["mega-menu", "hero-with-image", "logo-carousel", "stats-bar", "pricing-toggle", "FAQ-accordion"],
     "nav_type": "mega-menu",
     "dashboard_type": "sidebar-popup"
   }
   ```

**During VERIFY (Step 5):**
1. For each pattern you detected during extraction
2. Trigger it on the ORIGINAL → trigger it on the REPLICA
3. Do they look and behave the same?
4. If not → that's a fix item

**If a pattern isn't in this list:** Document it. New patterns get added to the vocabulary after validation.
