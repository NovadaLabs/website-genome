# 03 — Atomic Elements (Level 1)

## PURPOSE

```spec
This file catalogs EVERY indivisible UI element (atom).
Each atom is specified with: variants, sizes, states, accessibility, and code template.
Atoms are the building blocks. They compose into molecules → organisms → templates → pages.
Implementation: shadcn/ui components where available, custom atoms where not.
```

## ATOM CATALOG

---

### 3.1 BUTTON

```spec
DESCRIPTION: Clickable element that triggers an action
SHADCN: yes — `npx shadcn@latest add button`
HTML_ELEMENT: <button> (action) | <a> (navigation) | <Link> (client navigation)

VARIANTS:
  default      bg-primary text-primary-foreground hover:bg-primary/90
  destructive  bg-destructive text-destructive-foreground hover:bg-destructive/90
  outline      border border-input bg-background hover:bg-accent hover:text-accent-foreground
  secondary    bg-secondary text-secondary-foreground hover:bg-secondary/80
  ghost        hover:bg-accent hover:text-accent-foreground
  link         text-primary underline-offset-4 hover:underline

SIZES:
  sm    h-8  px-3   text-xs   rounded-md   gap-1.5
  md    h-9  px-4   text-sm   rounded-md   gap-2     [D]
  lg    h-10 px-6   text-sm   rounded-md   gap-2
  xl    h-11 px-8   text-base rounded-md   gap-2
  icon  h-9  w-9    rounded-md (square, icon only)

STATES:
  default     normal appearance
  hover       variant-specific hover style
  active      scale(0.98) or opacity change
  focus       ring-2 ring-ring ring-offset-2 outline-none
  disabled    opacity-50 pointer-events-none
  loading     spinner replaces content or appears alongside

ANATOMY:
  [icon?] [text] [icon?]
  Icon position: left (default) or right
  Loading: replace left icon with Loader2 animate-spin

ACCESSIBILITY:
  - MUST have accessible name (text content, aria-label, or aria-labelledby)
  - disabled buttons: use disabled attribute, NOT aria-disabled
  - Icon-only buttons: MUST have aria-label
  - Loading state: add aria-busy="true"

CODE:
  import { Button } from "@/components/ui/button"
  <Button variant="default" size="md" disabled={false}>
    Click me
  </Button>

  // With icon
  import { Plus } from "lucide-react"
  <Button><Plus className="h-4 w-4" /> Add item</Button>

  // Icon only
  <Button variant="ghost" size="icon" aria-label="Settings">
    <Settings className="h-4 w-4" />
  </Button>

  // Loading
  <Button disabled>
    <Loader2 className="h-4 w-4 animate-spin" /> Please wait
  </Button>

  // As link
  import Link from "next/link"
  <Button asChild><Link href="/dashboard">Go</Link></Button>
```

---

### 3.2 INPUT

```spec
DESCRIPTION: Text entry field
SHADCN: yes — `npx shadcn@latest add input`
HTML_ELEMENT: <input>

TYPES:
  text       standard text input [D]
  email      email validation
  password   masked input + show/hide toggle
  number     numeric input + stepper
  search     search with clear button
  url        URL validation
  tel        telephone
  date       date picker (native or custom)
  time       time picker
  file       file upload (→ see: 03#file-input)
  hidden     not visible, carries data

SIZES:
  sm    h-8  px-3 text-xs
  md    h-9  px-3 text-sm   [D]
  lg    h-10 px-4 text-base

STATES:
  default     border-input bg-background
  focus       ring-2 ring-ring border-ring
  disabled    opacity-50 cursor-not-allowed
  error       border-destructive ring-destructive
  readonly    bg-muted cursor-default

ANATOMY:
  [prefix-icon?] [input-field] [suffix-icon?] [clear-button?]

ACCESSIBILITY:
  - MUST have associated <Label> (htmlFor={id}) or aria-label
  - Error state: aria-invalid="true" + aria-describedby={errorId}
  - Required: aria-required="true" + required attribute
  - Placeholder: supplement, NOT replacement for label

CODE:
  import { Input } from "@/components/ui/input"
  import { Label } from "@/components/ui/label"

  <div className="grid gap-2">
    <Label htmlFor="email">Email</Label>
    <Input id="email" type="email" placeholder="name@example.com" />
  </div>

  // With error
  <div className="grid gap-2">
    <Label htmlFor="email">Email</Label>
    <Input id="email" type="email" aria-invalid="true" aria-describedby="email-error"
      className="border-destructive" />
    <p id="email-error" className="text-sm text-destructive">Invalid email</p>
  </div>
```

---

### 3.3 LABEL

```spec
DESCRIPTION: Text label associated with a form control
SHADCN: yes — `npx shadcn@latest add label`
HTML_ELEMENT: <label>

STYLE: text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70

STATES:
  default     normal
  disabled    opacity-70 cursor-not-allowed (via peer-disabled)
  error       text-destructive

ACCESSIBILITY:
  - MUST use htmlFor pointing to input id
  - Required indicator: append <span className="text-destructive">*</span>

CODE:
  import { Label } from "@/components/ui/label"
  <Label htmlFor="name">Name <span className="text-destructive">*</span></Label>
```

---

### 3.4 TEXTAREA

```spec
DESCRIPTION: Multi-line text input
SHADCN: yes — `npx shadcn@latest add textarea`
HTML_ELEMENT: <textarea>

SIZES:
  sm    min-h-16 text-xs
  md    min-h-20 text-sm   [D]
  lg    min-h-32 text-base

PROPERTIES:
  resize: vertical (default), none, or both
  rows: default 3
  maxLength: optional character limit
  auto-resize: optional (grow with content)

STATES: same as INPUT
ACCESSIBILITY: same as INPUT

CODE:
  import { Textarea } from "@/components/ui/textarea"
  <Textarea placeholder="Type your message here." rows={4} />
```

---

### 3.5 SELECT / DROPDOWN

```spec
DESCRIPTION: Choose one option from a list
SHADCN: yes — `npx shadcn@latest add select`
HTML_ELEMENT: custom (Radix Select)

SIZES:
  sm    h-8  text-xs
  md    h-9  text-sm   [D]
  lg    h-10 text-base

ANATOMY:
  [trigger: selected-value + chevron-down] → [content: option-list]
  Option groups: SelectGroup + SelectLabel
  Separator between groups: SelectSeparator

STATES:
  default     border-input
  open        ring-2 ring-ring
  disabled    opacity-50
  placeholder text-muted-foreground

ACCESSIBILITY:
  - Keyboard: Space/Enter opens, Arrow keys navigate, Escape closes
  - MUST have label

CODE:
  import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue }
    from "@/components/ui/select"

  <Select>
    <SelectTrigger className="w-[180px]">
      <SelectValue placeholder="Select option" />
    </SelectTrigger>
    <SelectContent>
      <SelectItem value="opt1">Option 1</SelectItem>
      <SelectItem value="opt2">Option 2</SelectItem>
    </SelectContent>
  </Select>
```

---

### 3.6 CHECKBOX

```spec
DESCRIPTION: Toggle boolean value
SHADCN: yes — `npx shadcn@latest add checkbox`
HTML_ELEMENT: custom (Radix Checkbox)

STATES:
  unchecked   border-primary
  checked     bg-primary text-primary-foreground + check icon
  indeterminate  bg-primary + minus icon (for "select all" patterns)
  disabled    opacity-50

ACCESSIBILITY:
  - MUST have label (via Label component or aria-label)
  - Indeterminate: aria-checked="mixed"

CODE:
  import { Checkbox } from "@/components/ui/checkbox"
  import { Label } from "@/components/ui/label"

  <div className="flex items-center gap-2">
    <Checkbox id="terms" />
    <Label htmlFor="terms">Accept terms</Label>
  </div>
```

---

### 3.7 RADIO GROUP

```spec
DESCRIPTION: Choose exactly one option from a set
SHADCN: yes — `npx shadcn@latest add radio-group`

ANATOMY: RadioGroup → RadioGroupItem + Label (for each option)

STATES:
  unselected   border-primary, empty circle
  selected     border-primary, filled inner circle
  disabled     opacity-50

CODE:
  import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group"

  <RadioGroup defaultValue="opt1">
    <div className="flex items-center gap-2">
      <RadioGroupItem value="opt1" id="opt1" />
      <Label htmlFor="opt1">Option 1</Label>
    </div>
    <div className="flex items-center gap-2">
      <RadioGroupItem value="opt2" id="opt2" />
      <Label htmlFor="opt2">Option 2</Label>
    </div>
  </RadioGroup>
```

---

### 3.8 SWITCH / TOGGLE

```spec
DESCRIPTION: Binary on/off toggle
SHADCN: yes — `npx shadcn@latest add switch`

STATES:
  off     bg-input, thumb left
  on      bg-primary, thumb right
  disabled opacity-50

ACCESSIBILITY:
  - role="switch"
  - aria-checked: true/false
  - MUST have label

CODE:
  import { Switch } from "@/components/ui/switch"
  <div className="flex items-center gap-2">
    <Switch id="dark-mode" />
    <Label htmlFor="dark-mode">Dark mode</Label>
  </div>
```

---

### 3.9 SLIDER

```spec
DESCRIPTION: Select a numeric value within a range
SHADCN: yes — `npx shadcn@latest add slider`

PROPERTIES:
  min, max, step, defaultValue, value, onValueChange
  orientation: horizontal [D] | vertical

STATES:
  default   track bg-primary/20, thumb bg-primary
  disabled  opacity-50
  dragging  thumb scale(1.1)

CODE:
  import { Slider } from "@/components/ui/slider"
  <Slider defaultValue={[50]} max={100} step={1} />
```

---

### 3.10 BADGE

```spec
DESCRIPTION: Small status indicator or label
SHADCN: yes — `npx shadcn@latest add badge`

VARIANTS:
  default       bg-primary text-primary-foreground
  secondary     bg-secondary text-secondary-foreground
  destructive   bg-destructive text-destructive-foreground
  outline       border text-foreground

SIZES:
  sm    px-2 py-0.5 text-[10px]
  md    px-2.5 py-0.5 text-xs    [D]

SHAPES:
  rounded-md    [D] (pill-like with default radius)
  rounded-full  (circular pill)

CODE:
  import { Badge } from "@/components/ui/badge"
  <Badge variant="default">Active</Badge>
  <Badge variant="destructive">Error</Badge>
```

---

### 3.11 AVATAR

```spec
DESCRIPTION: User profile image with fallback
SHADCN: yes — `npx shadcn@latest add avatar`

SIZES:
  xs    h-6 w-6
  sm    h-8 w-8
  md    h-10 w-10   [D]
  lg    h-12 w-12
  xl    h-16 w-16

ANATOMY: AvatarImage (src) + AvatarFallback (initials or icon)
SHAPE: rounded-full [D]

STATES:
  loaded     shows image
  loading    shows fallback (initials or skeleton)
  error      shows fallback permanently

CODE:
  import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
  <Avatar>
    <AvatarImage src="/avatar.jpg" alt="User" />
    <AvatarFallback>JD</AvatarFallback>
  </Avatar>
```

---

### 3.12 ICON

```spec
DESCRIPTION: SVG icon
LIBRARY: lucide-react [D]
INSTALL: npm install lucide-react

SIZES (match parent text or explicit):
  xs    h-3 w-3    (with text-xs)
  sm    h-4 w-4    (with text-sm) [D]
  md    h-5 w-5    (with text-base)
  lg    h-6 w-6    (standalone)
  xl    h-8 w-8    (hero icons)

COLOR: inherits current text color (currentColor)

COMMON ICONS:
  Navigation:   Menu, X, ChevronDown, ChevronRight, ArrowLeft, ArrowRight, ExternalLink
  Actions:      Plus, Minus, Edit, Trash2, Copy, Download, Upload, Share2, MoreHorizontal
  Status:       Check, X, AlertCircle, AlertTriangle, Info, Clock, Loader2
  User:         User, Users, LogIn, LogOut, Settings, Key, Shield
  Content:      Search, Filter, SortAsc, SortDesc, Eye, EyeOff, Star, Heart, Bookmark
  Media:        Image, FileText, Film, Music, Paperclip, Link2
  Commerce:     ShoppingCart, CreditCard, Package, Truck, Receipt
  Social:       Github, Twitter, Linkedin, Mail, Phone, Globe
  Dev:          Code, Terminal, Database, Server, Cpu, Zap, Bug
  Misc:         Sun, Moon, Palette, Bell, Calendar, MapPin, Home

ACCESSIBILITY:
  Decorative icons: aria-hidden="true" (default in lucide-react)
  Meaningful icons: add aria-label to parent button/link
  Never use icon alone without accessible name on container

CODE:
  import { Plus, Search, Settings } from "lucide-react"
  <Plus className="h-4 w-4" />
  <Search className="h-4 w-4 text-muted-foreground" />
```

---

### 3.13 SEPARATOR / DIVIDER

```spec
DESCRIPTION: Visual divider between content sections
SHADCN: yes — `npx shadcn@latest add separator`

ORIENTATION:
  horizontal    w-full h-[1px] [D]
  vertical      h-full w-[1px]

STYLE: bg-border (inherits --border token)

CODE:
  import { Separator } from "@/components/ui/separator"
  <Separator />                          // horizontal
  <Separator orientation="vertical" />   // vertical
```

---

### 3.14 SKELETON

```spec
DESCRIPTION: Loading placeholder mimicking content shape
SHADCN: yes — `npx shadcn@latest add skeleton`

STYLE: bg-muted animate-pulse rounded-md

USAGE: Create skeleton matching the shape of the content it replaces
  Text line:   <Skeleton className="h-4 w-[200px]" />
  Avatar:      <Skeleton className="h-10 w-10 rounded-full" />
  Card:        <Skeleton className="h-[200px] w-full rounded-lg" />
  Button:      <Skeleton className="h-9 w-[100px]" />

CODE:
  import { Skeleton } from "@/components/ui/skeleton"
  <div className="flex items-center gap-4">
    <Skeleton className="h-12 w-12 rounded-full" />
    <div className="space-y-2">
      <Skeleton className="h-4 w-[250px]" />
      <Skeleton className="h-4 w-[200px]" />
    </div>
  </div>
```

---

### 3.15 PROGRESS BAR

```spec
DESCRIPTION: Visual indicator of completion percentage
SHADCN: yes — `npx shadcn@latest add progress`

PROPERTIES: value (0-100)

STATES:
  determinate    filled to percentage
  indeterminate  animated continuous motion (when value unknown)

CODE:
  import { Progress } from "@/components/ui/progress"
  <Progress value={66} />
```

---

### 3.16 SCROLL AREA

```spec
DESCRIPTION: Custom scrollable container with styled scrollbar
SHADCN: yes — `npx shadcn@latest add scroll-area`

PROPERTIES:
  orientation: vertical [D] | horizontal | both
  className: set height constraint (h-[300px], h-full, etc.)

CODE:
  import { ScrollArea } from "@/components/ui/scroll-area"
  <ScrollArea className="h-[300px] rounded-md border p-4">
    {/* scrollable content */}
  </ScrollArea>
```

---

### 3.17 TOOLTIP

```spec
DESCRIPTION: Small text popup on hover/focus
SHADCN: yes — `npx shadcn@latest add tooltip`

PROPERTIES:
  side: top [D] | bottom | left | right
  delayDuration: 200ms [D]

⚠️ REQUIRES: <TooltipProvider> at layout root (app/layout.tsx)

ACCESSIBILITY:
  - Content announced by screen readers
  - Visible on keyboard focus (not just hover)

CODE:
  import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip"

  <Tooltip>
    <TooltipTrigger asChild>
      <Button variant="ghost" size="icon" aria-label="Settings">
        <Settings className="h-4 w-4" />
      </Button>
    </TooltipTrigger>
    <TooltipContent>
      <p>Settings</p>
    </TooltipContent>
  </Tooltip>
```

---

### 3.18 IMAGE (next/image)

```spec
DESCRIPTION: Optimized image with automatic format, sizing, lazy loading
ELEMENT: next/image (NOT raw <img>)

PROPERTIES:
  src:        string [R] (path or URL)
  alt:        string [R] (accessibility, NEVER empty for meaningful images)
  width:      number [R for static] (intrinsic width)
  height:     number [R for static] (intrinsic height)
  fill:       boolean (fills parent container — use instead of width/height)
  priority:   boolean (above-the-fold images: hero, LCP)
  placeholder: "blur" | "empty" (blur-up effect)
  sizes:      string (responsive size hints: "(max-width: 768px) 100vw, 50vw")

PATTERNS:
  Hero image:       fill + priority + sizes="100vw"
  Card thumbnail:   width/height + rounded-md
  Avatar:           width/height + rounded-full
  Background:       fill + object-cover + -z-10
  Gallery:          fill + object-contain

CODE:
  import Image from "next/image"

  // Fixed size
  <Image src="/hero.jpg" alt="Hero" width={1200} height={600} priority />

  // Fill container
  <div className="relative h-[400px] w-full">
    <Image src="/hero.jpg" alt="Hero" fill className="object-cover" priority
      sizes="100vw" />
  </div>

  // Remote images: configure next.config.ts
  images: { remotePatterns: [{ hostname: 'images.unsplash.com' }] }
```

---

### 3.19 LINK

```spec
DESCRIPTION: Navigation element
ELEMENT: next/link (client-side) | <a> (external)

PATTERNS:
  Internal:    <Link href="/about">About</Link>
  External:    <a href="https://..." target="_blank" rel="noopener noreferrer">
  Styled:      <Link href="/" className="text-primary hover:underline">
  As button:   <Button asChild><Link href="/signup">Sign Up</Link></Button>

ACCESSIBILITY:
  - External links: add screen-reader-only "(opens in new tab)" or ExternalLink icon
  - Current page: aria-current="page"
  - Skip link: first element in body for keyboard users

CODE:
  import Link from "next/link"
  <Link href="/dashboard" className="text-sm font-medium hover:text-primary">
    Dashboard
  </Link>
```

---

### 3.20 HEADING (h1-h6)

```spec
DESCRIPTION: Section titles establishing content hierarchy

HIERARCHY RULES:
  - ONE h1 per page (page title)
  - h2 for major sections
  - h3 for subsections
  - h4-h6 for deeper nesting
  - NEVER skip levels (h1 → h3 without h2)

STYLES (defaults):
  h1: text-4xl font-bold tracking-tight
  h2: text-3xl font-semibold tracking-tight
  h3: text-2xl font-semibold
  h4: text-xl font-semibold
  h5: text-lg font-medium
  h6: text-base font-medium

CODE:
  <h1 className="text-4xl font-bold tracking-tight">Page Title</h1>
  <h2 className="text-3xl font-semibold tracking-tight">Section</h2>
```

---

### 3.21 PARAGRAPH / TEXT

```spec
DESCRIPTION: Body text block

VARIANTS:
  body:      text-sm text-foreground                    [D for app]
  body-lg:   text-base text-foreground                  [D for marketing]
  lead:      text-xl text-muted-foreground              (intro paragraphs)
  muted:     text-sm text-muted-foreground              (secondary info)
  small:     text-xs text-muted-foreground              (captions, timestamps)
  code:      font-mono text-sm bg-muted px-1 py-0.5 rounded (inline code)
  metric:    font-mono text-2xl font-bold tabular-nums  (numbers, stats)

CODE:
  <p className="text-sm text-muted-foreground">Secondary text</p>
  <p className="text-xl text-muted-foreground">Lead paragraph intro</p>
  <code className="font-mono text-sm bg-muted px-1 py-0.5 rounded">code</code>
```

---

### 3.22 LIST

```spec
DESCRIPTION: Ordered or unordered list of items

TYPES:
  ul:     bullet points (list-disc)
  ol:     numbered list (list-decimal)
  dl:     definition list (term + description)
  custom: icon + text per item (feature lists, check lists)

STYLES:
  ul: list-disc list-inside space-y-1 text-sm
  ol: list-decimal list-inside space-y-1 text-sm
  custom: space-y-2 (each item: flex items-start gap-2)

CODE:
  // Check list (feature lists, pricing)
  <ul className="space-y-2">
    <li className="flex items-center gap-2">
      <Check className="h-4 w-4 text-primary" />
      <span className="text-sm">Feature description</span>
    </li>
  </ul>
```

---

### 3.23 TABLE ELEMENTS

```spec
DESCRIPTION: Data display in rows and columns
SHADCN: yes — `npx shadcn@latest add table`

ANATOMY:
  Table → TableHeader → TableRow → TableHead (th)
  Table → TableBody → TableRow → TableCell (td)
  Table → TableFooter → TableRow → TableCell

STATES:
  default     even/odd row striping optional
  hover       bg-muted/50 on row hover
  selected    bg-muted on selected row
  sortable    header with sort icon (ChevronDown/Up)

CODE:
  import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow }
    from "@/components/ui/table"

  <Table>
    <TableHeader>
      <TableRow>
        <TableHead>Name</TableHead>
        <TableHead>Status</TableHead>
      </TableRow>
    </TableHeader>
    <TableBody>
      <TableRow>
        <TableCell>Item 1</TableCell>
        <TableCell><Badge>Active</Badge></TableCell>
      </TableRow>
    </TableBody>
  </Table>
```

---

### 3.24 CARD

```spec
DESCRIPTION: Container for grouped content
SHADCN: yes — `npx shadcn@latest add card`

ANATOMY:
  Card → CardHeader → CardTitle + CardDescription
  Card → CardContent
  Card → CardFooter

STYLE: bg-card text-card-foreground rounded-lg border shadow-sm

VARIANTS (custom):
  default     border + shadow-sm [D]
  outline     border only, no shadow
  filled      bg-muted, no border
  elevated    shadow-md, no border
  interactive hover:shadow-md transition-shadow cursor-pointer

CODE:
  import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle }
    from "@/components/ui/card"

  <Card>
    <CardHeader>
      <CardTitle>Card Title</CardTitle>
      <CardDescription>Card description</CardDescription>
    </CardHeader>
    <CardContent>
      <p>Card content</p>
    </CardContent>
    <CardFooter>
      <Button>Action</Button>
    </CardFooter>
  </Card>
```

---

### 3.25 DIALOG / MODAL

```spec
DESCRIPTION: Overlay window requiring user attention
SHADCN: yes — `npx shadcn@latest add dialog`

ANATOMY:
  Dialog → DialogTrigger (button that opens)
  Dialog → DialogContent → DialogHeader → DialogTitle + DialogDescription
  Dialog → DialogContent → [body content]
  Dialog → DialogContent → DialogFooter (action buttons)

SIZES (via className on DialogContent):
  sm    max-w-sm
  md    max-w-md     [D]
  lg    max-w-lg
  xl    max-w-xl
  full  max-w-[90vw] (near-fullscreen)

BEHAVIOR:
  - Opens with backdrop overlay (bg-black/80)
  - Closes on: Escape key, backdrop click, close button
  - Focus trapped inside modal
  - Scroll locked on body

ACCESSIBILITY:
  - role="dialog"
  - aria-modal="true"
  - DialogTitle is REQUIRED (aria-labelledby)
  - DialogDescription is REQUIRED (aria-describedby)
  - If no visible title needed: use VisuallyHidden

CODE:
  import { Dialog, DialogContent, DialogDescription, DialogFooter,
    DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog"

  <Dialog>
    <DialogTrigger asChild>
      <Button>Open Dialog</Button>
    </DialogTrigger>
    <DialogContent>
      <DialogHeader>
        <DialogTitle>Are you sure?</DialogTitle>
        <DialogDescription>This action cannot be undone.</DialogDescription>
      </DialogHeader>
      <DialogFooter>
        <Button variant="outline">Cancel</Button>
        <Button variant="destructive">Delete</Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
```

---

### 3.26 ALERT DIALOG

```spec
DESCRIPTION: Destructive confirmation dialog (requires explicit action)
SHADCN: yes — `npx shadcn@latest add alert-dialog`
DIFFERENCE FROM DIALOG: Cannot be dismissed by clicking backdrop or pressing Escape
USE WHEN: Irreversible actions (delete, cancel subscription, etc.)

ANATOMY: Same as Dialog but with AlertDialog* prefix
CODE: Same pattern, replace Dialog* → AlertDialog*
```

---

### 3.27 SHEET / DRAWER

```spec
DESCRIPTION: Slide-in panel from edge of screen
SHADCN: yes — `npx shadcn@latest add sheet`

SIDES: top | right [D] | bottom | left

USE CASES:
  right:  detail panels, settings, filters
  left:   mobile navigation sidebar
  bottom: mobile action sheets
  top:    announcements, banners

CODE:
  import { Sheet, SheetContent, SheetDescription, SheetHeader,
    SheetTitle, SheetTrigger } from "@/components/ui/sheet"

  <Sheet>
    <SheetTrigger asChild>
      <Button variant="ghost" size="icon"><Menu className="h-4 w-4" /></Button>
    </SheetTrigger>
    <SheetContent side="left">
      <SheetHeader>
        <SheetTitle>Navigation</SheetTitle>
      </SheetHeader>
      {/* nav content */}
    </SheetContent>
  </Sheet>
```

---

### 3.28 POPOVER

```spec
DESCRIPTION: Floating content panel anchored to trigger
SHADCN: yes — `npx shadcn@latest add popover`

USE CASES: Rich tooltips, date pickers, color pickers, filter panels
DIFFERENCE FROM TOOLTIP: Popover is interactive (has clickable content)
DIFFERENCE FROM DROPDOWN: Popover has free-form content (not just menu items)

CODE:
  import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
  <Popover>
    <PopoverTrigger asChild><Button variant="outline">Open</Button></PopoverTrigger>
    <PopoverContent className="w-80">{/* content */}</PopoverContent>
  </Popover>
```

---

### 3.29 DROPDOWN MENU

```spec
DESCRIPTION: List of actions triggered from a button
SHADCN: yes — `npx shadcn@latest add dropdown-menu`

ANATOMY:
  DropdownMenu → DropdownMenuTrigger
  DropdownMenu → DropdownMenuContent →
    DropdownMenuItem (action)
    DropdownMenuCheckboxItem (toggle)
    DropdownMenuRadioGroup → DropdownMenuRadioItem (select one)
    DropdownMenuSeparator
    DropdownMenuLabel
    DropdownMenuSub → DropdownMenuSubTrigger + DropdownMenuSubContent (nested)

KEYBOARD: Arrow keys navigate, Enter selects, Escape closes

CODE:
  import { DropdownMenu, DropdownMenuContent, DropdownMenuItem,
    DropdownMenuSeparator, DropdownMenuTrigger } from "@/components/ui/dropdown-menu"

  <DropdownMenu>
    <DropdownMenuTrigger asChild>
      <Button variant="ghost" size="icon"><MoreHorizontal className="h-4 w-4" /></Button>
    </DropdownMenuTrigger>
    <DropdownMenuContent align="end">
      <DropdownMenuItem>Edit</DropdownMenuItem>
      <DropdownMenuItem>Duplicate</DropdownMenuItem>
      <DropdownMenuSeparator />
      <DropdownMenuItem className="text-destructive">Delete</DropdownMenuItem>
    </DropdownMenuContent>
  </DropdownMenu>
```

---

### 3.30 TABS

```spec
DESCRIPTION: Switch between content panels
SHADCN: yes — `npx shadcn@latest add tabs`

ANATOMY:
  Tabs → TabsList → TabsTrigger (one per tab)
  Tabs → TabsContent (one per tab, matched by value)

VARIANTS (custom):
  default     underline style (border-b on active tab)
  pills       bg-muted rounded-md on active tab
  segment     bg-background on active within bg-muted container

CODE:
  import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
  <Tabs defaultValue="tab1">
    <TabsList>
      <TabsTrigger value="tab1">Tab 1</TabsTrigger>
      <TabsTrigger value="tab2">Tab 2</TabsTrigger>
    </TabsList>
    <TabsContent value="tab1">Content 1</TabsContent>
    <TabsContent value="tab2">Content 2</TabsContent>
  </Tabs>
```

---

### 3.31 ACCORDION

```spec
DESCRIPTION: Collapsible content sections
SHADCN: yes — `npx shadcn@latest add accordion`

TYPES:
  single     only one item open at a time [D]
  multiple   multiple items can be open simultaneously

ANATOMY:
  Accordion → AccordionItem → AccordionTrigger + AccordionContent

CODE:
  import { Accordion, AccordionContent, AccordionItem, AccordionTrigger }
    from "@/components/ui/accordion"
  <Accordion type="single" collapsible>
    <AccordionItem value="item-1">
      <AccordionTrigger>Question 1</AccordionTrigger>
      <AccordionContent>Answer 1</AccordionContent>
    </AccordionItem>
  </Accordion>
```

---

### 3.32 TOAST / NOTIFICATION

```spec
DESCRIPTION: Temporary notification message
SHADCN: yes — `npx shadcn@latest add sonner` (uses sonner library)

VARIANTS:
  default     neutral message
  success     green check icon
  error       red X icon
  warning     amber warning icon
  info        blue info icon
  loading     spinner icon
  action      includes action button

POSITION: bottom-right [D] (configurable)
DURATION: 4000ms [D] (auto-dismiss)

SETUP: Add <Toaster /> to app/layout.tsx

CODE:
  import { toast } from "sonner"

  toast("Event created")
  toast.success("Saved successfully")
  toast.error("Something went wrong")
  toast.loading("Processing...")
  toast("Event created", {
    action: { label: "Undo", onClick: () => handleUndo() }
  })
```

---

### 3.33 ALERT / BANNER

```spec
DESCRIPTION: Persistent inline notification
SHADCN: yes — `npx shadcn@latest add alert`

VARIANTS:
  default       border + foreground (neutral info)
  destructive   border-destructive text-destructive (error/warning)

ANATOMY: Alert → AlertTitle + AlertDescription
OPTIONAL: Icon at start (Info, AlertTriangle, CheckCircle, etc.)

CODE:
  import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert"
  import { AlertTriangle } from "lucide-react"

  <Alert variant="destructive">
    <AlertTriangle className="h-4 w-4" />
    <AlertTitle>Error</AlertTitle>
    <AlertDescription>Something went wrong.</AlertDescription>
  </Alert>
```

---

### 3.34 BREADCRUMB

```spec
DESCRIPTION: Navigation path showing current location in hierarchy
SHADCN: yes — `npx shadcn@latest add breadcrumb`

ANATOMY:
  Breadcrumb → BreadcrumbList → BreadcrumbItem →
    BreadcrumbLink (clickable) | BreadcrumbPage (current, not clickable)
  BreadcrumbSeparator between items (default: /)

CODE:
  import { Breadcrumb, BreadcrumbItem, BreadcrumbLink, BreadcrumbList,
    BreadcrumbPage, BreadcrumbSeparator } from "@/components/ui/breadcrumb"

  <Breadcrumb>
    <BreadcrumbList>
      <BreadcrumbItem><BreadcrumbLink href="/">Home</BreadcrumbLink></BreadcrumbItem>
      <BreadcrumbSeparator />
      <BreadcrumbItem><BreadcrumbLink href="/products">Products</BreadcrumbLink></BreadcrumbItem>
      <BreadcrumbSeparator />
      <BreadcrumbItem><BreadcrumbPage>Current Page</BreadcrumbPage></BreadcrumbItem>
    </BreadcrumbList>
  </Breadcrumb>
```

---

### 3.35 PAGINATION

```spec
DESCRIPTION: Navigate between pages of results
SHADCN: yes — `npx shadcn@latest add pagination`

ANATOMY:
  Pagination → PaginationContent →
    PaginationPrevious | PaginationNext
    PaginationItem → PaginationLink (page number)
    PaginationEllipsis (... for gaps)

CODE:
  import { Pagination, PaginationContent, PaginationEllipsis,
    PaginationItem, PaginationLink, PaginationNext, PaginationPrevious }
    from "@/components/ui/pagination"

  <Pagination>
    <PaginationContent>
      <PaginationItem><PaginationPrevious href="#" /></PaginationItem>
      <PaginationItem><PaginationLink href="#">1</PaginationLink></PaginationItem>
      <PaginationItem><PaginationLink href="#" isActive>2</PaginationLink></PaginationItem>
      <PaginationItem><PaginationLink href="#">3</PaginationLink></PaginationItem>
      <PaginationItem><PaginationEllipsis /></PaginationItem>
      <PaginationItem><PaginationNext href="#" /></PaginationItem>
    </PaginationContent>
  </Pagination>
```

---

### 3.36 COMMAND PALETTE

```spec
DESCRIPTION: Searchable command/action list (Cmd+K pattern)
SHADCN: yes — `npx shadcn@latest add command`

USE CASES: Quick search, app-wide navigation, action launcher

ANATOMY:
  CommandDialog → Command → CommandInput
  Command → CommandList → CommandEmpty (no results)
  CommandList → CommandGroup → CommandItem
  CommandSeparator between groups

KEYBOARD: Cmd+K opens, type to filter, arrows navigate, Enter selects

CODE:
  import { Command, CommandDialog, CommandEmpty, CommandGroup,
    CommandInput, CommandItem, CommandList } from "@/components/ui/command"

  // Triggered by Cmd+K
  <CommandDialog open={open} onOpenChange={setOpen}>
    <CommandInput placeholder="Type a command or search..." />
    <CommandList>
      <CommandEmpty>No results found.</CommandEmpty>
      <CommandGroup heading="Navigation">
        <CommandItem>Dashboard</CommandItem>
        <CommandItem>Settings</CommandItem>
      </CommandGroup>
    </CommandList>
  </CommandDialog>
```

---

### 3.37 NAVIGATION MENU

```spec
DESCRIPTION: Top-level site navigation with dropdowns
SHADCN: yes — `npx shadcn@latest add navigation-menu`

USE CASES: Main site navbar with mega-menu dropdowns

ANATOMY:
  NavigationMenu → NavigationMenuList → NavigationMenuItem →
    NavigationMenuTrigger (opens dropdown) + NavigationMenuContent (dropdown panel)
    OR NavigationMenuLink (direct link, no dropdown)

CODE:
  import { NavigationMenu, NavigationMenuContent, NavigationMenuItem,
    NavigationMenuLink, NavigationMenuList, NavigationMenuTrigger }
    from "@/components/ui/navigation-menu"

  <NavigationMenu>
    <NavigationMenuList>
      <NavigationMenuItem>
        <NavigationMenuTrigger>Products</NavigationMenuTrigger>
        <NavigationMenuContent>
          {/* mega menu grid */}
        </NavigationMenuContent>
      </NavigationMenuItem>
      <NavigationMenuItem>
        <NavigationMenuLink href="/pricing">Pricing</NavigationMenuLink>
      </NavigationMenuItem>
    </NavigationMenuList>
  </NavigationMenu>
```

---

### 3.38 FORM (react-hook-form + zod)

```spec
DESCRIPTION: Form handling with validation
SHADCN: yes — `npx shadcn@latest add form`
DEPENDS: react-hook-form, zod, @hookform/resolvers

ANATOMY:
  Form → FormField → FormItem → FormLabel + FormControl + FormDescription + FormMessage

VALIDATION: Zod schema → resolver → react-hook-form

CODE:
  import { useForm } from "react-hook-form"
  import { zodResolver } from "@hookform/resolvers/zod"
  import { z } from "zod"
  import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage }
    from "@/components/ui/form"

  const schema = z.object({
    email: z.string().email("Invalid email"),
    name: z.string().min(2, "Name must be at least 2 characters"),
  })

  function MyForm() {
    const form = useForm({ resolver: zodResolver(schema) })
    const onSubmit = (data) => { /* handle */ }
    return (
      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
          <FormField control={form.control} name="email" render={({ field }) => (
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl><Input {...field} /></FormControl>
              <FormMessage />
            </FormItem>
          )} />
          <Button type="submit">Submit</Button>
        </form>
      </Form>
    )
  }
```

---

### 3.39 DATE PICKER

```spec
DESCRIPTION: Calendar-based date selection
SHADCN: yes — `npx shadcn@latest add calendar` + `npx shadcn@latest add popover`
DEPENDS: date-fns (or dayjs)

PATTERN: Button trigger → Popover → Calendar

VARIANTS:
  single    select one date
  range     select start + end date

CODE:
  import { Calendar } from "@/components/ui/calendar"
  import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
  import { format } from "date-fns"
  import { CalendarIcon } from "lucide-react"

  <Popover>
    <PopoverTrigger asChild>
      <Button variant="outline" className="w-[240px] justify-start text-left">
        <CalendarIcon className="mr-2 h-4 w-4" />
        {date ? format(date, "PPP") : "Pick a date"}
      </Button>
    </PopoverTrigger>
    <PopoverContent className="w-auto p-0" align="start">
      <Calendar mode="single" selected={date} onSelect={setDate} />
    </PopoverContent>
  </Popover>
```

---

### 3.40 DATA TABLE

```spec
DESCRIPTION: Full-featured data table with sorting, filtering, pagination
SHADCN: yes — `npx shadcn@latest add table` + @tanstack/react-table
DEPENDS: @tanstack/react-table

FEATURES:
  sorting       click header to sort asc/desc
  filtering     text filter on columns
  pagination    page through rows
  selection     checkbox per row
  column-toggle show/hide columns
  row-actions   dropdown menu per row

→ Full implementation pattern in 04-components.md#data-table
→ This is a MOLECULE (table atoms + button atoms + input atoms + dropdown atoms)
```

---

### 3.41 CHART

```spec
DESCRIPTION: Data visualization
SHADCN: yes — `npx shadcn@latest add chart`
DEPENDS: recharts

TYPES:
  line      time series, trends
  bar       comparisons, categories
  area      volume, cumulative
  pie       proportions, distribution
  donut     proportions with center metric
  radar     multi-axis comparison

COLORS: uses --chart-1 through --chart-5 tokens

→ Full implementation in 04-components.md#charts
```

---

### 3.42 SIDEBAR

```spec
DESCRIPTION: Persistent navigation panel
SHADCN: yes — `npx shadcn@latest add sidebar`

STATES:
  expanded    full width (w-64) with icons + labels
  collapsed   icon-only width (w-16)
  mobile      sheet/drawer overlay

ANATOMY:
  SidebarProvider → Sidebar → SidebarHeader + SidebarContent + SidebarFooter
  SidebarContent → SidebarGroup → SidebarGroupLabel + SidebarGroupContent
  SidebarGroupContent → SidebarMenu → SidebarMenuItem → SidebarMenuButton

→ Full implementation in 04-components.md#sidebar
```

---

## UTILITY ATOMS (non-visual helpers)

### 3.43 VISUALLY HIDDEN

```spec
DESCRIPTION: Content hidden visually but accessible to screen readers
USE: Hide DialogTitle/DialogDescription when not visually needed
STYLE: absolute w-[1px] h-[1px] overflow-hidden clip-rect(0,0,0,0)

CODE:
  <span className="sr-only">Close dialog</span>
  // or use Radix VisuallyHidden
```

### 3.44 ASPECT RATIO

```spec
DESCRIPTION: Maintain element aspect ratio
SHADCN: yes — `npx shadcn@latest add aspect-ratio`
COMMON: 16/9 (video), 4/3 (photo), 1/1 (square), 2/1 (banner)

CODE:
  import { AspectRatio } from "@/components/ui/aspect-ratio"
  <AspectRatio ratio={16 / 9}>
    <Image src="..." alt="..." fill className="object-cover" />
  </AspectRatio>
```

### 3.45 COLLAPSIBLE

```spec
DESCRIPTION: Show/hide content with toggle
SHADCN: yes — `npx shadcn@latest add collapsible`

CODE:
  import { Collapsible, CollapsibleContent, CollapsibleTrigger }
    from "@/components/ui/collapsible"
  <Collapsible>
    <CollapsibleTrigger>Toggle</CollapsibleTrigger>
    <CollapsibleContent>Hidden content</CollapsibleContent>
  </Collapsible>
```

---

## ATOM COUNT SUMMARY

```spec
INTERACTIVE ATOMS:  Button, Input, Textarea, Select, Checkbox, Radio, Switch,
                    Slider, DatePicker, Command, Form = 11

DISPLAY ATOMS:      Badge, Avatar, Icon, Separator, Skeleton, Progress,
                    Image, Link, Heading, Paragraph, List, Table, Card,
                    Chart, AspectRatio = 15

OVERLAY ATOMS:      Dialog, AlertDialog, Sheet, Popover, DropdownMenu,
                    Tooltip, Toast, Alert, NavigationMenu = 9

LAYOUT ATOMS:       ScrollArea, Tabs, Accordion, Breadcrumb, Pagination,
                    Sidebar, Collapsible = 7

UTILITY ATOMS:      VisuallyHidden = 1

TOTAL: 43 atoms
These 43 atoms compose into every website ever built.
```
