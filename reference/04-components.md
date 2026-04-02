# 04 — Components (Molecules & Organisms)

## PURPOSE

```spec
Molecules = 2-5 atoms composed into a functional unit.
Organisms = multiple molecules composed into a distinct section.
This file catalogs the most common compositions found across ALL website types.
Each composition: anatomy, atoms used, implementation, variants.
```

---

## MOLECULES

### 4.1 SEARCH BAR

```spec
ATOMS: Input + Button(icon) + Icon(Search)
VARIANTS:
  inline     input with search icon inside, no button
  with-btn   input + search button
  command    opens CommandDialog on click/focus (Cmd+K)
  expanding  icon-only → expands to full input on click

ANATOMY:
  <div className="relative">
    <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
    <Input className="pl-9" placeholder="Search..." />
  </div>

BEHAVIOR:
  - Debounce input (300ms) before triggering search
  - Show clear button (X) when input has value
  - Loading state: replace search icon with Loader2 spin
  - Results: dropdown below or navigate to search results page
```

### 4.2 FORM FIELD

```spec
ATOMS: Label + Input/Select/Textarea + FormMessage(error) + FormDescription(help)
PATTERN: Always use shadcn Form component for validation

ANATOMY:
  <FormField>
    <FormItem className="grid gap-2">
      <FormLabel>Field Name <span className="text-destructive">*</span></FormLabel>
      <FormControl><Input /></FormControl>
      <FormDescription>Helper text</FormDescription>
      <FormMessage /> {/* auto-populated error from zod */}
    </FormItem>
  </FormField>

VARIANTS:
  text         Input type="text"
  email        Input type="email"
  password     Input type="password" + show/hide toggle
  textarea     Textarea
  select       Select component
  checkbox     Checkbox + label inline
  radio        RadioGroup
  switch       Switch + label inline
  date         DatePicker (Popover + Calendar)
  file         custom file input with drag-drop zone
  rich-text    Tiptap or similar editor [C]
```

### 4.3 AUTH FORM

```spec
ATOMS: Card + FormField[] + Button + Separator + SocialButtons + Link
USE: Login, signup, forgot password, reset password

VARIANTS:
  login:
    email + password fields
    "Forgot password?" link
    Submit button
    Separator("or")
    Social login buttons (Google, GitHub, etc.)
    "Don't have an account? Sign up" link

  signup:
    name + email + password + confirm-password fields
    Terms checkbox
    Submit button
    Social login buttons
    "Already have an account? Log in" link

  forgot-password:
    email field
    Submit button
    "Back to login" link

  reset-password:
    password + confirm-password fields
    Submit button

⚠️ IF USING CLERK: Use Clerk's <SignIn /> and <SignUp /> components instead.
   Custom forms only needed for non-Clerk auth implementations.
```

### 4.4 NAV LINK

```spec
ATOMS: Link + Icon(optional) + Badge(optional) + Text
PATTERN: Sidebar or navbar navigation item

ANATOMY:
  <Link href="/path" className={cn(
    "flex items-center gap-3 rounded-md px-3 py-2 text-sm transition-colors",
    isActive
      ? "bg-accent text-accent-foreground font-medium"
      : "text-muted-foreground hover:bg-accent hover:text-accent-foreground"
  )}>
    <Icon className="h-4 w-4" />
    <span>Label</span>
    {count && <Badge variant="secondary" className="ml-auto">{count}</Badge>}
  </Link>

STATES:
  default     text-muted-foreground
  hover       bg-accent text-accent-foreground
  active      bg-accent text-accent-foreground font-medium (current page)
  disabled    opacity-50 pointer-events-none
```

### 4.5 STAT CARD

```spec
ATOMS: Card + Icon + Text(label) + Text(metric) + Text(trend) + Badge
USE: Dashboard KPI displays

ANATOMY:
  <Card>
    <CardContent className="p-6">
      <div className="flex items-center justify-between">
        <p className="text-sm text-muted-foreground">Total Revenue</p>
        <DollarSign className="h-4 w-4 text-muted-foreground" />
      </div>
      <p className="text-2xl font-bold tabular-nums">$45,231.89</p>
      <p className="text-xs text-muted-foreground">
        <span className="text-green-500">+20.1%</span> from last month
      </p>
    </CardContent>
  </Card>

VARIANTS:
  simple     label + metric only
  with-trend label + metric + percentage change (green/red)
  with-icon  label + metric + icon
  with-chart label + metric + sparkline chart
```

### 4.6 PRICING CARD

```spec
ATOMS: Card + Badge + Heading + Text(price) + List(features) + Button
USE: Pricing page plan display

ANATOMY:
  <Card className={cn(highlighted && "border-primary shadow-lg")}>
    <CardHeader>
      {highlighted && <Badge>Most Popular</Badge>}
      <CardTitle>Pro</CardTitle>
      <CardDescription>For growing teams</CardDescription>
      <div className="mt-4">
        <span className="text-4xl font-bold">$29</span>
        <span className="text-muted-foreground">/month</span>
      </div>
    </CardHeader>
    <CardContent>
      <ul className="space-y-2">
        {features.map(f => (
          <li className="flex items-center gap-2">
            <Check className="h-4 w-4 text-primary" />
            <span className="text-sm">{f}</span>
          </li>
        ))}
      </ul>
    </CardContent>
    <CardFooter>
      <Button className="w-full" variant={highlighted ? "default" : "outline"}>
        Get Started
      </Button>
    </CardFooter>
  </Card>

VARIANTS:
  standard       normal styling
  highlighted    border-primary + shadow-lg + "Most Popular" badge
  enterprise     "Contact Sales" button instead of price
```

### 4.7 TESTIMONIAL CARD

```spec
ATOMS: Card + Avatar + Text(quote) + Text(name) + Text(role) + Icon(Star)
USE: Social proof sections

ANATOMY:
  <Card>
    <CardContent className="pt-6">
      <div className="flex gap-1 mb-4">
        {[...Array(5)].map(() => <Star className="h-4 w-4 fill-primary text-primary" />)}
      </div>
      <p className="text-sm italic">"Quote text here..."</p>
      <div className="flex items-center gap-3 mt-4">
        <Avatar><AvatarImage /><AvatarFallback>JD</AvatarFallback></Avatar>
        <div>
          <p className="text-sm font-medium">Jane Doe</p>
          <p className="text-xs text-muted-foreground">CEO, Acme Inc</p>
        </div>
      </div>
    </CardContent>
  </Card>
```

### 4.8 FILE UPLOAD ZONE

```spec
ATOMS: Card + Icon(Upload) + Text + Input(file, hidden) + Button
USE: File upload areas (drag and drop)

ANATOMY:
  <div className="border-2 border-dashed rounded-lg p-8 text-center
    hover:border-primary transition-colors cursor-pointer"
    onDragOver={handleDragOver} onDrop={handleDrop}
    onClick={() => inputRef.current?.click()}>
    <Upload className="h-8 w-8 mx-auto text-muted-foreground mb-4" />
    <p className="text-sm font-medium">Drag & drop or click to upload</p>
    <p className="text-xs text-muted-foreground mt-1">PNG, JPG up to 10MB</p>
    <input ref={inputRef} type="file" className="hidden" onChange={handleFile} />
  </div>

STATES:
  default    dashed border, muted text
  dragover   border-primary, bg-primary/5
  uploading  progress bar, filename, cancel button
  uploaded   file preview, filename, remove button
  error      border-destructive, error message
```

### 4.9 EMPTY STATE

```spec
ATOMS: Icon + Heading + Text + Button
USE: When a list/table/page has no data yet

ANATOMY:
  <div className="flex flex-col items-center justify-center py-12 text-center">
    <div className="rounded-full bg-muted p-4 mb-4">
      <Inbox className="h-8 w-8 text-muted-foreground" />
    </div>
    <h3 className="text-lg font-semibold">No items yet</h3>
    <p className="text-sm text-muted-foreground mt-1 max-w-sm">
      Get started by creating your first item.
    </p>
    <Button className="mt-4"><Plus className="h-4 w-4 mr-2" /> Create Item</Button>
  </div>
```

### 4.10 USER MENU

```spec
ATOMS: DropdownMenu + Avatar + Text(name) + Text(email) + MenuItem[] + Separator
USE: Top-right user account dropdown

ANATOMY:
  <DropdownMenu>
    <DropdownMenuTrigger>
      <Avatar className="h-8 w-8">
        <AvatarImage /><AvatarFallback>JD</AvatarFallback>
      </Avatar>
    </DropdownMenuTrigger>
    <DropdownMenuContent align="end" className="w-56">
      <div className="px-2 py-1.5">
        <p className="text-sm font-medium">Jane Doe</p>
        <p className="text-xs text-muted-foreground">jane@example.com</p>
      </div>
      <DropdownMenuSeparator />
      <DropdownMenuItem>Profile</DropdownMenuItem>
      <DropdownMenuItem>Settings</DropdownMenuItem>
      <DropdownMenuItem>Billing</DropdownMenuItem>
      <DropdownMenuSeparator />
      <DropdownMenuItem>Log out</DropdownMenuItem>
    </DropdownMenuContent>
  </DropdownMenu>
```

---

## ORGANISMS

### 4.11 NAVBAR

```spec
MOLECULES: Logo + NavLinks[] + SearchBar + AuthButtons/UserMenu
USE: Every website has a navbar (except rare fullscreen apps)

VARIANTS:
  marketing    Logo + NavLinks + CTA buttons (Sign In, Get Started)
  app          Logo + NavLinks + SearchBar + Notifications + UserMenu
  minimal      Logo + UserMenu (for focused flows like onboarding)
  transparent  same as marketing but bg-transparent (for hero overlap)

ANATOMY (marketing):
  <header className="sticky top-0 z-30 w-full border-b bg-background/95 backdrop-blur">
    <div className="container flex h-14 items-center justify-between">
      <div className="flex items-center gap-6">
        <Link href="/" className="flex items-center gap-2 font-semibold">
          <Logo /> Brand
        </Link>
        <nav className="hidden md:flex items-center gap-4 text-sm">
          <Link href="/features">Features</Link>
          <Link href="/pricing">Pricing</Link>
          <Link href="/docs">Docs</Link>
        </nav>
      </div>
      <div className="flex items-center gap-2">
        <Button variant="ghost" asChild><Link href="/login">Sign In</Link></Button>
        <Button asChild><Link href="/signup">Get Started</Link></Button>
        {/* Mobile menu: Sheet with hamburger icon (md:hidden) */}
      </div>
    </div>
  </header>

RESPONSIVE:
  desktop (md+):  full horizontal nav
  mobile (<md):   hamburger → Sheet/Drawer with vertical nav
```

### 4.12 FOOTER

```spec
MOLECULES: Logo + LinkGroups[] + SocialLinks + Copyright + NewsletterForm
USE: Bottom of every public page

VARIANTS:
  simple       one row: logo + links + copyright
  columns      multi-column link groups (Product, Company, Resources, Legal)
  mega         columns + newsletter signup + social links

ANATOMY (columns):
  <footer className="border-t bg-background">
    <div className="container py-12 grid grid-cols-2 md:grid-cols-4 gap-8">
      <div>
        <h4 className="text-sm font-semibold mb-3">Product</h4>
        <ul className="space-y-2 text-sm text-muted-foreground">
          <li><Link href="/features">Features</Link></li>
          <li><Link href="/pricing">Pricing</Link></li>
        </ul>
      </div>
      {/* more columns */}
    </div>
    <div className="container border-t py-6 flex justify-between text-xs text-muted-foreground">
      <p>&copy; 2026 Brand. All rights reserved.</p>
      <div className="flex gap-4">
        <Link href="/privacy">Privacy</Link>
        <Link href="/terms">Terms</Link>
      </div>
    </div>
  </footer>
```

### 4.13 HERO SECTION

```spec
MOLECULES: Heading + Subtext + CTAButtons + Image/Video + Badge
USE: Landing pages, marketing pages (first thing visitors see)

VARIANTS:
  centered     text center, CTAs center, image below
  split        text left, image/visual right (50/50)
  fullscreen   full viewport height, text overlay on image/gradient
  with-video   centered text + video embed below
  with-demo    text left, product screenshot/demo right

ANATOMY (split):
  <section className="container py-24 flex flex-col md:flex-row items-center gap-12">
    <div className="flex-1 space-y-6">
      <Badge variant="secondary">New Release</Badge>
      <h1 className="text-4xl md:text-5xl font-bold tracking-tight">
        Build websites at light speed
      </h1>
      <p className="text-xl text-muted-foreground max-w-lg">
        One-line description of the value proposition.
      </p>
      <div className="flex gap-3">
        <Button size="lg">Get Started Free</Button>
        <Button size="lg" variant="outline">Live Demo</Button>
      </div>
    </div>
    <div className="flex-1 relative">
      <Image src="/hero.png" alt="Product screenshot" width={600} height={400}
        priority className="rounded-lg shadow-2xl" />
    </div>
  </section>
```

### 4.14 FEATURE SECTION

```spec
MOLECULES: SectionHeading + FeatureCards[]
USE: Showcasing product capabilities

VARIANTS:
  grid         3-column grid of feature cards
  alternating  feature + image, alternating sides per row
  bento        asymmetric grid (bento box layout)
  icon-list    simple icon + title + description list

ANATOMY (grid):
  <section className="container py-24">
    <div className="text-center mb-12">
      <h2 className="text-3xl font-bold">Features</h2>
      <p className="text-muted-foreground mt-2 max-w-2xl mx-auto">Description</p>
    </div>
    <div className="grid md:grid-cols-3 gap-8">
      {features.map(f => (
        <Card key={f.title}>
          <CardContent className="pt-6">
            <div className="rounded-lg bg-primary/10 w-10 h-10 flex items-center justify-center mb-4">
              <f.icon className="h-5 w-5 text-primary" />
            </div>
            <h3 className="font-semibold mb-2">{f.title}</h3>
            <p className="text-sm text-muted-foreground">{f.description}</p>
          </CardContent>
        </Card>
      ))}
    </div>
  </section>
```

### 4.15 PRICING SECTION

```spec
MOLECULES: SectionHeading + PricingToggle(monthly/annual) + PricingCard[] + FAQ
USE: Pricing pages

ANATOMY:
  <section className="container py-24">
    <div className="text-center mb-12">
      <h2 className="text-3xl font-bold">Pricing</h2>
      <p className="text-muted-foreground mt-2">Simple, transparent pricing</p>
      <div className="flex items-center justify-center gap-3 mt-6">
        <Label>Monthly</Label>
        <Switch onCheckedChange={setAnnual} />
        <Label>Annual <Badge variant="secondary">Save 20%</Badge></Label>
      </div>
    </div>
    <div className="grid md:grid-cols-3 gap-8 max-w-5xl mx-auto">
      {plans.map(plan => <PricingCard key={plan.name} {...plan} annual={annual} />)}
    </div>
  </section>

PLANS (standard SaaS):
  Free:       $0, limited features, for evaluation
  Pro:        $X/mo, full features, for individuals/small teams [HIGHLIGHTED]
  Enterprise: custom pricing, contact sales, for large organizations
```

### 4.16 TESTIMONIALS SECTION

```spec
MOLECULES: SectionHeading + TestimonialCard[] or Carousel
VARIANTS:
  grid       3-column grid of testimonial cards
  carousel   horizontally scrolling cards
  featured   one large testimonial with photo
  wall       masonry layout of varied-length testimonials
```

### 4.17 FAQ SECTION

```spec
MOLECULES: SectionHeading + Accordion
ANATOMY:
  <section className="container py-24 max-w-3xl mx-auto">
    <h2 className="text-3xl font-bold text-center mb-12">FAQ</h2>
    <Accordion type="single" collapsible>
      {faqs.map(faq => (
        <AccordionItem key={faq.q} value={faq.q}>
          <AccordionTrigger>{faq.q}</AccordionTrigger>
          <AccordionContent>{faq.a}</AccordionContent>
        </AccordionItem>
      ))}
    </Accordion>
  </section>
```

### 4.18 CTA SECTION

```spec
MOLECULES: Heading + Text + Button(s)
USE: Call to action banner (usually before footer)

ANATOMY:
  <section className="container py-24">
    <div className="rounded-lg bg-primary text-primary-foreground p-12 text-center">
      <h2 className="text-3xl font-bold">Ready to get started?</h2>
      <p className="mt-4 max-w-lg mx-auto opacity-90">Description</p>
      <div className="mt-8 flex justify-center gap-4">
        <Button size="lg" variant="secondary">Start Free Trial</Button>
        <Button size="lg" variant="outline" className="border-primary-foreground
          text-primary-foreground hover:bg-primary-foreground/10">
          Contact Sales
        </Button>
      </div>
    </div>
  </section>
```

### 4.19 DASHBOARD SHELL

```spec
MOLECULES: Sidebar + TopNav + MainContent area
USE: SaaS application pages (post-login)

ANATOMY:
  <SidebarProvider>
    <Sidebar>
      <SidebarHeader>{/* logo */}</SidebarHeader>
      <SidebarContent>
        <SidebarGroup>
          <SidebarGroupLabel>Main</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              <SidebarMenuItem>
                <SidebarMenuButton asChild>
                  <Link href="/dashboard"><Home /> Dashboard</Link>
                </SidebarMenuButton>
              </SidebarMenuItem>
              {/* more items */}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>
      <SidebarFooter>{/* user menu */}</SidebarFooter>
    </Sidebar>
    <main className="flex-1">
      <header className="flex h-14 items-center gap-4 border-b px-6">
        <SidebarTrigger />
        <Breadcrumb>...</Breadcrumb>
        <div className="ml-auto flex items-center gap-2">
          <SearchBar />
          <NotificationBell />
          <UserMenu />
        </div>
      </header>
      <div className="p-6">
        {children}
      </div>
    </main>
  </SidebarProvider>
```

### 4.20 DATA TABLE (full-featured)

```spec
MOLECULES: Input(filter) + Table + Pagination + DropdownMenu(actions) + Button(column toggle)
DEPENDS: @tanstack/react-table

FEATURES CHECKLIST:
  ☐ Column sorting (click header)
  ☐ Text filtering (search input)
  ☐ Row selection (checkboxes)
  ☐ Pagination (previous/next + page size)
  ☐ Column visibility toggle
  ☐ Row actions (edit, delete dropdown)
  ☐ Loading state (skeleton rows)
  ☐ Empty state (no results message)
  ☐ Responsive (horizontal scroll on mobile)

→ Implementation is complex. Use shadcn data-table pattern:
  npx shadcn@latest add table
  npm install @tanstack/react-table
  Follow: https://ui.shadcn.com/docs/components/data-table
```

### 4.21 SETTINGS FORM

```spec
MOLECULES: Tabs + Card + FormField[] + Button(save)
USE: User/account settings pages

ANATOMY:
  <Tabs defaultValue="general">
    <TabsList>
      <TabsTrigger value="general">General</TabsTrigger>
      <TabsTrigger value="security">Security</TabsTrigger>
      <TabsTrigger value="notifications">Notifications</TabsTrigger>
    </TabsList>
    <TabsContent value="general">
      <Card>
        <CardHeader>
          <CardTitle>Profile</CardTitle>
          <CardDescription>Manage your account settings</CardDescription>
        </CardHeader>
        <CardContent>
          <Form>{/* FormField components */}</Form>
        </CardContent>
        <CardFooter>
          <Button>Save Changes</Button>
        </CardFooter>
      </Card>
    </TabsContent>
  </Tabs>
```

### 4.22 NOTIFICATION BELL

```spec
MOLECULES: Popover + Button(icon) + Badge(count) + List(notifications)
USE: App header notification indicator

ANATOMY:
  <Popover>
    <PopoverTrigger asChild>
      <Button variant="ghost" size="icon" className="relative">
        <Bell className="h-4 w-4" />
        {count > 0 && (
          <span className="absolute -top-1 -right-1 h-4 w-4 rounded-full bg-destructive
            text-[10px] font-medium text-destructive-foreground flex items-center justify-center">
            {count}
          </span>
        )}
      </Button>
    </PopoverTrigger>
    <PopoverContent className="w-80 p-0" align="end">
      <div className="p-4 border-b">
        <h4 className="text-sm font-semibold">Notifications</h4>
      </div>
      <ScrollArea className="h-[300px]">
        {notifications.map(n => <NotificationItem key={n.id} {...n} />)}
      </ScrollArea>
    </PopoverContent>
  </Popover>
```

---

## COMPONENT COUNT SUMMARY

```spec
MOLECULES: SearchBar, FormField, AuthForm, NavLink, StatCard, PricingCard,
           TestimonialCard, FileUploadZone, EmptyState, UserMenu = 10

ORGANISMS: Navbar, Footer, HeroSection, FeatureSection, PricingSection,
           TestimonialsSection, FAQSection, CTASection, DashboardShell,
           DataTable, SettingsForm, NotificationBell = 12

TOTAL: 22 compositions
Combined with 43 atoms → 65 building blocks covering ~90% of all website needs.
```
