# 12 — Responsive Design

## PURPOSE

```spec
Every website MUST work at 3 target widths: 375px (mobile), 768px (tablet), 1440px (desktop).
This file specifies exactly what changes at each breakpoint for every component category.
Approach: mobile-first (base styles = mobile, layer on md: lg: xl: overrides).
```

---

## BREAKPOINTS

```spec
  TAILWIND   WIDTH     TARGET DEVICE
  (base)     0-639px   Mobile phones (375px design target)
  sm:        640px+    Large phones landscape
  md:        768px+    Tablets portrait (768px design target)
  lg:        1024px+   Tablets landscape / small laptops
  xl:        1280px+   Laptops / desktops (1440px design target)
  2xl:       1536px+   Large desktops / monitors

DESIGN TARGETS (test at these exact widths):
  375px    iPhone SE / standard mobile
  768px    iPad portrait
  1440px   Standard laptop/desktop
```

## RESPONSIVE PATTERNS BY COMPONENT

### LAYOUT

```spec
CONTAINER:
  mobile:   px-4 (16px horizontal padding)
  tablet:   px-6 (24px)
  desktop:  max-w-7xl mx-auto px-8 (1280px max + 32px padding)

  Implementation: className="container mx-auto px-4 md:px-6 lg:px-8"
  OR define in tailwind config: container: { center: true, padding: { DEFAULT: '1rem', md: '1.5rem', lg: '2rem' } }

GRID:
  mobile:   1 column (grid-cols-1)
  tablet:   2 columns (md:grid-cols-2)
  desktop:  3-4 columns (lg:grid-cols-3 or xl:grid-cols-4)

  Implementation: className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6"

SECTION SPACING:
  mobile:   py-12 (48px vertical)
  tablet:   py-16 (64px)
  desktop:  py-24 (96px)

  Implementation: className="py-12 md:py-16 lg:py-24"
```

### NAVIGATION

```spec
NAVBAR:
  mobile:   logo + hamburger menu icon (Sheet for nav items)
  tablet:   logo + key nav items + hamburger for overflow
  desktop:  logo + all nav items + CTA buttons

  Implementation:
    // Desktop nav (hidden on mobile)
    <nav className="hidden md:flex items-center gap-4">{navItems}</nav>

    // Mobile hamburger (hidden on desktop)
    <Sheet>
      <SheetTrigger asChild className="md:hidden">
        <Button variant="ghost" size="icon"><Menu className="h-5 w-5" /></Button>
      </SheetTrigger>
      <SheetContent side="left">{/* mobile nav */}</SheetContent>
    </Sheet>

SIDEBAR:
  mobile:   hidden (accessible via hamburger → Sheet)
  tablet:   collapsed (icons only, w-16), expand on hover
  desktop:  expanded (icons + labels, w-64)

  Implementation: shadcn Sidebar component handles this automatically
    <SidebarProvider>
      <Sidebar collapsible="icon">{/* auto-collapses on md */}</Sidebar>
    </SidebarProvider>

BREADCRUMB:
  mobile:   truncate middle items → "Home / ... / Current"
  desktop:  show full path
```

### TYPOGRAPHY

```spec
HEADINGS:
  h1:  mobile text-3xl  → desktop text-4xl md:text-5xl
  h2:  mobile text-2xl  → desktop text-3xl
  h3:  mobile text-xl   → desktop text-2xl

  Implementation: className="text-3xl md:text-4xl lg:text-5xl font-bold"

BODY:
  mobile:   text-sm (14px) — more content per screen
  desktop:  text-base (16px) on marketing pages, text-sm on app pages

LEAD TEXT:
  mobile:   text-lg
  desktop:  text-xl
```

### HERO SECTION

```spec
SPLIT HERO:
  mobile:   stacked (image below text), full-width
  desktop:  side-by-side (text left, image right, 50/50)

  Implementation:
    className="flex flex-col md:flex-row items-center gap-8 md:gap-12"

CENTERED HERO:
  mobile:   smaller heading, shorter description
  desktop:  larger heading, full description

  Implementation:
    <h1 className="text-3xl md:text-5xl font-bold text-center">Title</h1>
    <p className="text-lg md:text-xl text-muted-foreground text-center max-w-2xl mx-auto">
```

### CARDS & GRIDS

```spec
CARD GRID:
  mobile:   1 column, full-width cards
  tablet:   2 columns
  desktop:  3 columns (or 4 for product grids)

  Implementation: className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6"

PRICING CARDS:
  mobile:   stacked vertically, full-width
  desktop:  3 side-by-side

STAT CARDS:
  mobile:   2 columns (compact)
  tablet:   2-3 columns
  desktop:  4 columns (one row)

  Implementation: className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4"
```

### TABLES

```spec
APPROACHES (choose based on data complexity):

  1. HORIZONTAL SCROLL (simplest, works for most tables):
     <div className="overflow-x-auto -mx-4 px-4 md:mx-0 md:px-0">
       <Table className="min-w-[600px]">{/* full table */}</Table>
     </div>

  2. CARD VIEW (best for complex data):
     mobile:   each row becomes a card
     desktop:  standard table

     <div className="hidden md:block"><Table>{/* standard */}</Table></div>
     <div className="md:hidden space-y-4">
       {data.map(item => <Card>{/* row as card */}</Card>)}
     </div>

  3. COLUMN HIDING (middle ground):
     Hide non-essential columns on mobile, show all on desktop
     <TableHead className="hidden lg:table-cell">Created</TableHead>
     <TableCell className="hidden lg:table-cell">{item.createdAt}</TableCell>
```

### FORMS

```spec
FORM LAYOUT:
  mobile:   single column, full-width fields
  desktop:  two-column for related fields (first name + last name)

  Implementation:
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
      <FormField name="firstName" />
      <FormField name="lastName" />
    </div>
    <FormField name="email" />  {/* full width */}

FORM ACTIONS:
  mobile:   full-width buttons, stacked
  desktop:  inline buttons, right-aligned

  Implementation:
    <div className="flex flex-col-reverse sm:flex-row sm:justify-end gap-2">
      <Button variant="outline">Cancel</Button>
      <Button type="submit">Save</Button>
    </div>
```

### MODALS & OVERLAYS

```spec
DIALOG:
  mobile:   full-screen or near-full (inset-4)
  desktop:  centered with max-width

  Implementation: shadcn Dialog handles responsive automatically
  For full-screen mobile: add className to DialogContent
    className="sm:max-w-md" // centered on desktop, edge-to-edge mobile

SHEET:
  mobile:   full-width from bottom (side="bottom") for action sheets
  desktop:  standard side panel (side="right")

DROPDOWN:
  mobile:   may overflow viewport — use align="end" + sideOffset
  desktop:  standard positioning
```

### IMAGES

```spec
HERO IMAGE:
  mobile:   full-width, aspect-ratio 16/9 or 4/3
  desktop:  contained or side-by-side with text

  Implementation:
    <div className="relative w-full aspect-video md:aspect-auto md:h-[500px]">
      <Image src="/hero.jpg" alt="Hero" fill className="object-cover"
        sizes="100vw" priority />
    </div>

CARD THUMBNAILS:
  mobile:   full-width at top of card
  desktop:  fixed aspect ratio

GALLERY:
  mobile:   1 column or horizontal scroll
  tablet:   2 columns
  desktop:  3-4 columns masonry or grid
```

### FOOTER

```spec
COLUMNS:
  mobile:   stacked vertically (1 column), accordion optional
  tablet:   2 columns
  desktop:  4 columns

  Implementation: className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8"

BOTTOM BAR:
  mobile:   stacked (copyright above, links below)
  desktop:  horizontal (copyright left, links right)

  Implementation: className="flex flex-col md:flex-row md:justify-between gap-4"
```

---

## RESPONSIVE TESTING CHECKLIST

```spec
FOR EACH PAGE, TEST AT:
  ☐ 375px width (iPhone SE — primary mobile target)
  ☐ 390px width (iPhone 14/15 — most common mobile)
  ☐ 768px width (iPad portrait — tablet target)
  ☐ 1024px width (iPad landscape — sidebar breakpoint)
  ☐ 1440px width (standard laptop — desktop target)
  ☐ 1920px width (full HD — large desktop, ensure no excessive white space)

VERIFY:
  ☐ No horizontal scrollbar on any viewport (except intentional scroll areas)
  ☐ No text overflow or truncation loss
  ☐ All interactive elements reachable (not hidden off-screen)
  ☐ Touch targets >= 44x44px on mobile
  ☐ Text readable without zooming
  ☐ Images not stretched or cropped incorrectly
  ☐ Navigation accessible at all sizes
  ☐ Forms usable (labels visible, inputs full-width on mobile)
  ☐ Modals/dialogs don't overflow viewport
  ☐ Tables scrollable or converted to cards on mobile
```

## RESPONSIVE CSS UTILITIES

```spec
VISIBILITY:
  hidden md:block        hide on mobile, show on tablet+
  md:hidden              show on mobile only, hide on tablet+
  hidden lg:block        show only on desktop+

FLEX DIRECTION:
  flex-col md:flex-row   stack mobile, horizontal desktop

SPACING OVERRIDE:
  p-4 md:p-6 lg:p-8     progressive padding
  gap-4 md:gap-6         progressive gaps
  space-y-4 md:space-y-6 progressive vertical spacing

WIDTH:
  w-full md:w-1/2 lg:w-1/3   responsive column sizing
  max-w-sm md:max-w-md        responsive max-width

TEXT SIZE:
  text-sm md:text-base   responsive text sizing
```
