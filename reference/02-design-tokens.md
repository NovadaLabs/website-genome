# 02 — Design Tokens (DNA)

## PURPOSE

```spec
Design tokens are the single source of truth for ALL visual properties.
Change a token → every component, page, and interaction updates.
Tokens MUST be defined before any component work begins.

IMPLEMENTATION: CSS custom properties (variables) in globals.css
FRAMEWORK: Tailwind CSS 4.x + shadcn/ui theme system
COLOR_SPACE: oklch (perceptually uniform, wide gamut)
```

## TOKEN CATEGORIES

### 2.1 COLOR SYSTEM

```spec
ARCHITECTURE:
  Semantic tokens → reference primitive values
  Components reference ONLY semantic tokens, never raw colors

SEMANTIC TOKENS (what components use):
  --background           [R] page background
  --foreground           [R] default text color
  --card                 [R] card/surface background
  --card-foreground      [R] text on cards
  --popover              [R] popover/dropdown background
  --popover-foreground   [R] text on popovers
  --primary              [R] primary brand color (buttons, links, accents)
  --primary-foreground   [R] text on primary color
  --secondary            [R] secondary actions, subtle backgrounds
  --secondary-foreground [R] text on secondary
  --muted                [R] muted/disabled backgrounds
  --muted-foreground     [R] muted/placeholder text
  --accent               [R] hover states, highlights
  --accent-foreground    [R] text on accent
  --destructive          [R] error, delete, danger
  --destructive-foreground [R] text on destructive
  --border               [R] borders, dividers
  --input                [R] input field borders
  --ring                 [R] focus ring color
  --chart-1 through --chart-5 [O] chart colors
  --sidebar-*            [C] sidebar-specific tokens (if sidebar present)

DARK MODE:
  All tokens have light AND dark variants.
  Implementation: .dark class on <html> → CSS specificity override.
  Toggle: className toggle on document.documentElement.

DEFAULT PALETTE (zinc/neutral — override with brand colors):
  LIGHT:
    --background: oklch(1 0 0)                    // white
    --foreground: oklch(0.145 0 0)                // near-black
    --primary: oklch(0.205 0 0)                   // very dark
    --primary-foreground: oklch(0.985 0 0)        // near-white
    --secondary: oklch(0.965 0 0)                 // light gray
    --muted: oklch(0.965 0 0)                     // light gray
    --border: oklch(0.922 0 0)                    // mid-light gray
    --destructive: oklch(0.577 0.245 27.325)      // red
    --ring: oklch(0.708 0 0)                      // gray

  DARK:
    --background: oklch(0.145 0 0)                // near-black
    --foreground: oklch(0.985 0 0)                // near-white
    --primary: oklch(0.985 0 0)                   // near-white
    --primary-foreground: oklch(0.205 0 0)        // very dark
    --secondary: oklch(0.269 0 0)                 // dark gray
    --muted: oklch(0.269 0 0)                     // dark gray
    --border: oklch(0.269 0 0)                    // dark gray
    --destructive: oklch(0.704 0.191 22.216)      // lighter red
    --ring: oklch(0.556 0 0)                      // gray

VARIANT SETS:
  For sites with marketing + app sections:
    Marketing pages: may override --background, --primary with brand vibrant colors
    App pages: use default neutral palette for readability
    Implement: data-theme="marketing" | data-theme="app" attribute on section wrapper

STATUS COLORS (extend base palette):
  --success: oklch(0.65 0.2 145)          green
  --success-foreground: oklch(1 0 0)      white
  --warning: oklch(0.75 0.15 85)          amber
  --warning-foreground: oklch(0.2 0 0)    dark
  --info: oklch(0.65 0.15 250)            blue
  --info-foreground: oklch(1 0 0)         white
```

### 2.2 TYPOGRAPHY

```spec
FONT FAMILIES:
  --font-sans: "Geist Sans", system-ui, -apple-system, sans-serif [D]
  --font-mono: "Geist Mono", ui-monospace, monospace [D]

  INSTALLATION:
    import { GeistSans } from 'geist/font/sans'
    import { GeistMono } from 'geist/font/mono'
    Apply: <body className={`${GeistSans.variable} ${GeistMono.variable}`}>

  OVERRIDE: Replace with brand fonts via next/font/google or next/font/local

FONT SIZE SCALE (tailwind defaults, rem-based):
  text-xs:    0.75rem  / 1rem     (12px / 16px line-height)
  text-sm:    0.875rem / 1.25rem  (14px / 20px)
  text-base:  1rem     / 1.5rem   (16px / 24px)
  text-lg:    1.125rem / 1.75rem  (18px / 28px)
  text-xl:    1.25rem  / 1.75rem  (20px / 28px)
  text-2xl:   1.5rem   / 2rem     (24px / 32px)
  text-3xl:   1.875rem / 2.25rem  (30px / 36px)
  text-4xl:   2.25rem  / 2.5rem   (36px / 40px)
  text-5xl:   3rem     / 1        (48px / 1)
  text-6xl:   3.75rem  / 1        (60px / 1)

FONT WEIGHT:
  font-light:     300
  font-normal:    400 [D]
  font-medium:    500
  font-semibold:  600
  font-bold:      700

USAGE RULES:
  h1: text-4xl font-bold (or text-5xl on marketing pages)
  h2: text-3xl font-semibold
  h3: text-2xl font-semibold
  h4: text-xl font-semibold
  h5: text-lg font-medium
  h6: text-base font-medium
  body: text-sm or text-base font-normal
  caption/label: text-xs or text-sm font-medium text-muted-foreground
  code: font-mono text-sm
  metric/stat: font-mono text-2xl font-bold tabular-nums

TRACKING (letter-spacing):
  tracking-tighter: -0.05em  (large headings)
  tracking-tight:   -0.025em (headings)
  tracking-normal:  0        (body) [D]
  tracking-wide:    0.025em  (uppercase labels)
```

### 2.3 SPACING

```spec
BASE UNIT: 4px (0.25rem)
SCALE: multiples of 4px

  0:    0px
  0.5:  2px
  1:    4px
  1.5:  6px
  2:    8px
  2.5:  10px
  3:    12px
  3.5:  14px
  4:    16px
  5:    20px
  6:    24px
  7:    28px
  8:    32px
  9:    36px
  10:   40px
  11:   44px
  12:   48px
  14:   56px
  16:   64px
  20:   80px
  24:   96px
  28:   112px
  32:   128px
  36:   144px
  40:   160px

USAGE PATTERNS:
  Inline element gap (icon + text):     gap-1.5 to gap-2 (6-8px)
  Form field gap (label + input):       gap-2 (8px)
  Card internal padding:                p-4 to p-6 (16-24px)
  Section padding (vertical):           py-12 to py-24 (48-96px)
  Section padding (horizontal):         px-4 (mobile) px-6 (tablet) px-8 (desktop)
  Page max-width container:             max-w-7xl mx-auto (1280px)
  Grid gap:                             gap-4 to gap-8 (16-32px)
  Sidebar width:                        w-64 (256px) or w-72 (288px)
  Navbar height:                        h-14 (56px) or h-16 (64px)
  Footer padding:                       py-8 to py-16 (32-64px)
```

### 2.4 BORDERS & RADII

```spec
BORDER WIDTH:
  border:     1px [D]
  border-2:   2px (emphasis borders)

BORDER RADIUS:
  --radius: 0.625rem [D] (10px — shadcn default)

  rounded-none: 0
  rounded-sm:   calc(var(--radius) - 4px)    ~6px
  rounded-md:   calc(var(--radius) - 2px)    ~8px
  rounded-lg:   var(--radius)                ~10px [D for cards]
  rounded-xl:   calc(var(--radius) + 4px)    ~14px
  rounded-2xl:  calc(var(--radius) + 8px)    ~18px
  rounded-full: 9999px                       (pills, avatars)

USAGE:
  Buttons:     rounded-md
  Cards:       rounded-lg
  Inputs:      rounded-md
  Badges:      rounded-md or rounded-full
  Avatars:     rounded-full
  Modals:      rounded-lg
  Tooltips:    rounded-md
  Full-width:  rounded-none
```

### 2.5 SHADOWS

```spec
shadow-none:   none
shadow-xs:     0 1px 2px 0 rgb(0 0 0 / 0.05)
shadow-sm:     0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1)
shadow-md:     0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)
shadow-lg:     0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)
shadow-xl:     0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)
shadow-2xl:    0 25px 50px -12px rgb(0 0 0 / 0.25)

USAGE:
  Cards (default):  shadow-none + border  [D for dark mode]
  Cards (elevated): shadow-sm             [D for light mode]
  Dropdowns:        shadow-md
  Modals:           shadow-lg
  Popovers:         shadow-md
  Toast:            shadow-lg
  ⚠️ In dark mode, prefer border over shadow (shadows invisible on dark bg)
```

### 2.6 Z-INDEX LAYERS

```spec
z-0:    0       base content
z-10:   10      sticky elements (within content)
z-20:   20      dropdowns, popovers
z-30:   30      fixed navbar, sticky headers
z-40:   40      drawer/sheet overlay
z-50:   50      modal overlay + modal content
z-[60]: 60      toast/notification (above modals)
z-[70]: 70      tooltip (above everything)

RULE: Never use arbitrary z-index values outside this scale.
RULE: Overlays (modal, drawer) need a backdrop at z-[N-1].
```

### 2.7 ANIMATION & TRANSITION

```spec
DURATION:
  duration-75:   75ms   (micro interactions: opacity)
  duration-100:  100ms  (hover states)
  duration-150:  150ms  [D] (most transitions)
  duration-200:  200ms  (panel opens)
  duration-300:  300ms  (page transitions, complex animations)
  duration-500:  500ms  (long animations)

EASING:
  ease-linear:      linear
  ease-in:          cubic-bezier(0.4, 0, 1, 1)
  ease-out:         cubic-bezier(0, 0, 0.2, 1)       [D for enter]
  ease-in-out:      cubic-bezier(0.4, 0, 0.2, 1)     [D for transitions]

DEFAULT TRANSITION:
  transition-all duration-150 ease-in-out

COMMON ANIMATIONS:
  FADE_IN:       opacity 0→1, duration-150
  FADE_OUT:      opacity 1→0, duration-100
  SLIDE_DOWN:    translateY(-8px)→0 + opacity 0→1, duration-200
  SLIDE_UP:      translateY(8px)→0 + opacity 0→1, duration-200
  SCALE_IN:      scale(0.95)→1 + opacity 0→1, duration-200
  SPIN:          rotate 0→360, duration-500, infinite
  PULSE:         opacity 1→0.5→1, duration-2000, infinite
  BOUNCE:        translateY(0→-25%→0), duration-1000, infinite

SHADCN ANIMATIONS (pre-configured):
  animate-accordion-down   (accordion open)
  animate-accordion-up     (accordion close)

KEYFRAME DEFINITIONS (add to tailwind config if needed):
  @keyframes fade-in { from { opacity: 0 } to { opacity: 1 } }
  @keyframes slide-down { from { opacity: 0; transform: translateY(-8px) } to { opacity: 1; transform: translateY(0) } }
  @keyframes slide-up { from { opacity: 0; transform: translateY(8px) } to { opacity: 1; transform: translateY(0) } }

REDUCED MOTION:
  Always wrap animations with prefers-reduced-motion:
  motion-safe:animate-fade-in (Tailwind) or @media (prefers-reduced-motion: no-preference)
```

### 2.8 BREAKPOINTS

```spec
→ Full specification in 12-responsive.md. Summary here for token reference.

  sm:   640px    (large phone landscape / small tablet)
  md:   768px    (tablet portrait)
  lg:   1024px   (tablet landscape / small laptop)
  xl:   1280px   (laptop / desktop)
  2xl:  1536px   (large desktop)

DESIGN TARGETS:
  MOBILE:   375px width  (iPhone SE / standard)
  TABLET:   768px width  (iPad portrait)
  DESKTOP:  1440px width (standard monitor)

APPROACH: mobile-first (base styles = mobile, then add md: lg: xl: overrides)
```

## IMPLEMENTATION TEMPLATE

```css
/* globals.css — place at the top of the file */

@import "tailwindcss";
@import "tw-animate-css";

@custom-variant dark (&:is(.dark *));

@theme inline {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --color-card: var(--card);
  --color-card-foreground: var(--card-foreground);
  --color-popover: var(--popover);
  --color-popover-foreground: var(--popover-foreground);
  --color-primary: var(--primary);
  --color-primary-foreground: var(--primary-foreground);
  --color-secondary: var(--secondary);
  --color-secondary-foreground: var(--secondary-foreground);
  --color-muted: var(--muted);
  --color-muted-foreground: var(--muted-foreground);
  --color-accent: var(--accent);
  --color-accent-foreground: var(--accent-foreground);
  --color-destructive: var(--destructive);
  --color-destructive-foreground: var(--destructive-foreground);
  --color-border: var(--border);
  --color-input: var(--input);
  --color-ring: var(--ring);
  --radius-sm: calc(var(--radius) - 4px);
  --radius-md: calc(var(--radius) - 2px);
  --radius-lg: var(--radius);
  --radius-xl: calc(var(--radius) + 4px);
  --font-sans: var(--font-geist-sans);
  --font-mono: var(--font-geist-mono);
}

:root {
  --radius: 0.625rem;
  --background: oklch(1 0 0);
  --foreground: oklch(0.145 0 0);
  --card: oklch(1 0 0);
  --card-foreground: oklch(0.145 0 0);
  --popover: oklch(1 0 0);
  --popover-foreground: oklch(0.145 0 0);
  --primary: oklch(0.205 0 0);
  --primary-foreground: oklch(0.985 0 0);
  --secondary: oklch(0.965 0 0);
  --secondary-foreground: oklch(0.205 0 0);
  --muted: oklch(0.965 0 0);
  --muted-foreground: oklch(0.556 0 0);
  --accent: oklch(0.965 0 0);
  --accent-foreground: oklch(0.205 0 0);
  --destructive: oklch(0.577 0.245 27.325);
  --destructive-foreground: oklch(0.985 0 0);
  --border: oklch(0.922 0 0);
  --input: oklch(0.922 0 0);
  --ring: oklch(0.708 0 0);
}

.dark {
  --background: oklch(0.145 0 0);
  --foreground: oklch(0.985 0 0);
  --card: oklch(0.205 0 0);
  --card-foreground: oklch(0.985 0 0);
  --popover: oklch(0.205 0 0);
  --popover-foreground: oklch(0.985 0 0);
  --primary: oklch(0.985 0 0);
  --primary-foreground: oklch(0.205 0 0);
  --secondary: oklch(0.269 0 0);
  --secondary-foreground: oklch(0.985 0 0);
  --muted: oklch(0.269 0 0);
  --muted-foreground: oklch(0.708 0 0);
  --accent: oklch(0.269 0 0);
  --accent-foreground: oklch(0.985 0 0);
  --destructive: oklch(0.704 0.191 22.216);
  --destructive-foreground: oklch(0.985 0 0);
  --border: oklch(0.269 0 0);
  --input: oklch(0.269 0 0);
  --ring: oklch(0.556 0 0);
}
```

## CUSTOMIZATION PROTOCOL

```spec
WHEN HUMAN PROVIDES BRAND COLORS:
  1. Replace --primary with brand primary color (convert to oklch)
  2. Calculate --primary-foreground (white or black based on contrast)
  3. Optionally replace --accent, --destructive
  4. Keep all other tokens as defaults
  5. Test contrast ratios: primary/primary-foreground >= 4.5:1

WHEN HUMAN PROVIDES BRAND FONTS:
  1. Install via next/font/google or next/font/local
  2. Replace --font-sans variable
  3. Keep --font-mono as Geist Mono (for code/metrics)
  4. Verify font loads in < 100ms (next/font handles this)

WHEN HUMAN PROVIDES NO BRAND DIRECTION:
  Use defaults above. Zinc/neutral palette is professional and universal.
  Default to dark mode for dashboards/tools, light mode for marketing/content.
```
