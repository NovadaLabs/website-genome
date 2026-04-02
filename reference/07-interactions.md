# 07 — Interactions

## PURPOSE

```spec
This file catalogs EVERY type of user interaction on a website.
For each: trigger, behavior, visual feedback, implementation, accessibility.
The executor agent uses this to ensure every interactive element works correctly.
```

---

## INTERACTION TAXONOMY

### 7.1 CLICK / TAP

```spec
TRIGGER: mouse click or touch tap
FEEDBACK: visual state change (hover→active→result)

SUBTYPES:
  navigate       click → go to new page
  toggle         click → switch state (on/off, open/close)
  submit         click → send data (form, action)
  select         click → choose option (radio, checkbox, dropdown item)
  trigger-overlay click → open modal/dialog/sheet/popover/dropdown
  download       click → download file
  copy           click → copy to clipboard + toast confirmation
  expand/collapse click → show/hide content (accordion, collapsible)
  drag-start     mousedown → begin drag operation

IMPLEMENTATION:
  navigate:        <Link href="/path"> or router.push("/path")
  toggle:          useState + onClick handler
  submit:          form onSubmit or Server Action
  select:          onChange handler on select/radio/checkbox
  trigger-overlay: state toggle (open/setOpen) on Dialog/Sheet/Popover
  download:        <a href="/file" download> or programmatic blob download
  copy:            navigator.clipboard.writeText(text) + toast.success("Copied")
  expand:          Accordion/Collapsible component (handles internally)

ACCESSIBILITY:
  - All clickable elements: cursor-pointer
  - Non-button clickables: role="button" + tabIndex={0} + onKeyDown(Enter/Space)
  - Prefer <button> or <Link> over <div onClick>
  - Active state: scale(0.98) or opacity change for tactile feedback
```

### 7.2 HOVER

```spec
TRIGGER: mouse enters element boundary
FEEDBACK: visual style change

SUBTYPES:
  color-change    bg or text color shift
  elevation       shadow increase
  scale           subtle scale(1.02)
  underline       text decoration appears
  reveal          hidden content becomes visible (icon, tooltip, actions)
  preview         show preview card/image on hover

IMPLEMENTATION:
  Tailwind: hover:bg-accent hover:text-accent-foreground
  CSS transition: transition-colors duration-150
  Reveal: group/item + group-hover/item:opacity-100 (initially opacity-0)

ACCESSIBILITY:
  - Hover effects MUST have keyboard equivalents (focus state)
  - Content revealed on hover MUST also be accessible via focus
  - Touch devices: no hover — use tap instead
  - Pattern: hover:X focus-visible:X (same style for both)

COMMON PATTERNS:
  Button:     hover:bg-primary/90
  Card:       hover:shadow-md hover:border-primary/50 transition-all
  Link:       hover:underline hover:text-primary
  Nav item:   hover:bg-accent hover:text-accent-foreground
  Row:        hover:bg-muted/50
  Table row:  hover:bg-muted/50 cursor-pointer (if clickable)
  Icon btn:   hover:bg-accent rounded-md transition-colors
```

### 7.3 FOCUS

```spec
TRIGGER: element receives keyboard focus (Tab key)
FEEDBACK: focus ring

IMPLEMENTATION:
  Default focus ring: focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2
  Shadcn components: built-in focus styles
  Custom: outline-none focus-visible:ring-2 focus-visible:ring-ring

RULES:
  - EVERY interactive element MUST have visible focus indicator
  - Use focus-visible (not focus) to avoid showing ring on mouse click
  - Tab order must follow visual order (no tabIndex > 0)
  - Focus trap in modals/dialogs (Radix handles this)
  - Skip-to-content link as first focusable element

FOCUS MANAGEMENT:
  Modal opens → focus first focusable element inside
  Modal closes → restore focus to trigger element
  New page content → focus main heading or content area
  Error → focus first error field
  Deletion → focus next item or parent container
```

### 7.4 SCROLL

```spec
TRIGGER: mouse wheel, touch drag, keyboard (Space, PageDown)
EFFECTS:

  SUBTYPES:
    page-scroll      normal page scrolling
    container-scroll  ScrollArea component (custom scrollbar)
    infinite-scroll   load more content as user scrolls down
    scroll-to-anchor  click anchor → smooth scroll to section (#id)
    parallax          background moves slower than foreground
    scroll-reveal     elements animate in as they enter viewport
    sticky            element fixes to viewport edge on scroll past
    scroll-spy        highlight current section in navigation

  IMPLEMENTATION:
    infinite-scroll:  IntersectionObserver on sentinel element → load more
    scroll-to-anchor: <Link href="#section"> + scroll-behavior: smooth in CSS
    scroll-reveal:    IntersectionObserver + animate class toggle
    sticky:           sticky top-[offset] z-[level]
    scroll-spy:       IntersectionObserver on section headings → update active nav

  PERFORMANCE:
    - Use will-change: transform for parallax/animated elements
    - Debounce scroll handlers (if using addEventListener)
    - Prefer IntersectionObserver over scroll event listeners
    - Use CSS scroll-behavior: smooth (not JS scrollTo for simple cases)
```

### 7.5 FORM INTERACTIONS

```spec
TRIGGER: user types, selects, checks, toggles form controls
FLOW: input → validate → feedback → submit → result

SUBTYPES:
  text-input     typing into input/textarea
  selection      choosing from select/radio/checkbox
  toggle         switch on/off
  file-upload    drag-drop or file picker
  rich-text      formatted text editing (bold, italic, etc.)

VALIDATION TIMING:
  on-blur:    validate when field loses focus [D] (least intrusive)
  on-change:  validate as user types (for real-time feedback)
  on-submit:  validate all fields on form submit (always, as safety net)

FEEDBACK:
  valid:   green check icon, success text (optional)
  invalid: red border, error message below field
  loading: spinner on submit button, disabled fields
  success: toast notification, redirect, or inline success message

IMPLEMENTATION:
  react-hook-form + zod resolver (→ see: 03-atomic-elements.md#form)

  // Async validation (e.g., check if email exists)
  const schema = z.object({
    email: z.string().email().refine(async (email) => {
      const exists = await checkEmail(email)
      return !exists
    }, "Email already registered")
  })

SUBMIT FLOW:
  1. User clicks submit
  2. Client-side validation (zod schema)
  3. If invalid: show errors, focus first error field, STOP
  4. If valid: disable form, show loading state on button
  5. Submit to Server Action or API route
  6. Server-side validation (same zod schema — NEVER trust client only)
  7. If server error: show error toast or inline error
  8. If success: show success toast, redirect or update UI
  9. Re-enable form
```

### 7.6 DRAG AND DROP

```spec
TRIGGER: mousedown + mousemove (or touch equivalent)
USE: reorder lists, kanban boards, file upload, layout builders

IMPLEMENTATION:
  Library: @dnd-kit/core + @dnd-kit/sortable (recommended)
  Alternative: react-beautiful-dnd (deprecated but still works)

FEEDBACK:
  grab:      cursor-grab → cursor-grabbing
  dragging:  opacity-50 on source, drop indicator at target
  drop:      animate to new position
  invalid:   element snaps back to original position

ACCESSIBILITY:
  - Keyboard alternative REQUIRED (arrow keys to reorder)
  - Announce position changes to screen readers
  - aria-roledescription="sortable" on draggable items
```

### 7.7 KEYBOARD SHORTCUTS

```spec
TRIGGER: key combination (Cmd/Ctrl + key)
USE: power user features, command palette, navigation

COMMON SHORTCUTS:
  Cmd+K          open command palette / search
  Cmd+/          open keyboard shortcuts help
  Cmd+S          save (in editors)
  Escape         close modal/popover/dropdown
  Enter          submit form, confirm action
  Tab            move focus to next element
  Shift+Tab      move focus to previous element
  Arrow keys     navigate within menus, lists, grids
  Space          toggle checkbox, activate button
  Delete/Backspace delete selected item (with confirmation)

IMPLEMENTATION:
  // Global shortcut listener
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.key === 'k' && (e.metaKey || e.ctrlKey)) {
        e.preventDefault()
        setCommandOpen(true)
      }
    }
    document.addEventListener('keydown', handler)
    return () => document.removeEventListener('keydown', handler)
  }, [])

  // Or use a hook library: useHotkeys from @mantine/hooks

ACCESSIBILITY:
  - Never override browser defaults (Cmd+C, Cmd+V, Cmd+Z, etc.)
  - Provide discoverable shortcut hints (tooltips, help dialog)
  - All shortcut-only actions MUST have mouse/touch alternative
```

### 7.8 ANIMATIONS & TRANSITIONS

```spec
TRIGGER: state change, page navigation, scroll position

SUBTYPES:
  enter     element appears (mount, show, open)
  exit      element disappears (unmount, hide, close)
  layout    element moves/resizes (reorder, filter, accordion)
  feedback  response to interaction (button press, success, error)
  ambient   continuous decorative motion (gradient, particles)
  loading   indicates pending state (spinner, skeleton, progress)

COMMON PATTERNS:
  Page transition:    fade-in content (opacity 0→1, duration-200)
  Modal open:         fade-in backdrop + scale-in content (scale 0.95→1)
  Modal close:        reverse of open (faster: duration-150)
  Dropdown open:      slide-down + fade-in (translateY(-8px)→0)
  Toast enter:        slide-in from right + fade-in
  Toast exit:         slide-out to right + fade-out
  Accordion open:     height 0→auto (animate-accordion-down)
  Skeleton:           pulse animation (opacity oscillation)
  Button loading:     icon spin (animate-spin)

IMPLEMENTATION:
  CSS transitions: transition-all duration-200 ease-in-out (simplest)
  Tailwind animate: animate-fade-in, animate-slide-down (via tw-animate-css)
  Radix animations: data-[state=open]:animate-in data-[state=closed]:animate-out
  Complex: framer-motion (only if needed — adds bundle size)

RULES:
  - Keep durations short (100-300ms for UI, 500ms max for emphasis)
  - Faster exit than enter (enter: 200ms, exit: 150ms)
  - Respect prefers-reduced-motion (→ see: 02-design-tokens.md#animation)
  - No animation on initial page load (except loading indicators)
  - No infinite ambient animations in app UI (distracting)
```

### 7.9 REAL-TIME UPDATES

```spec
TRIGGER: server pushes new data
USE: notifications, chat, live dashboards, collaborative editing

METHODS:
  polling         fetch every N seconds (simplest, least efficient)
  SSE             server-sent events (one-way server → client)
  WebSocket       bidirectional (chat, collaboration)
  revalidation    Next.js revalidatePath/revalidateTag (server-triggered)

IMPLEMENTATION:
  Polling:
    useEffect + setInterval → fetch → update state
    ⚠️ Clean up interval on unmount

  SSE (AI streaming):
    AI SDK handles this automatically (useChat, streamText)

  WebSocket (real-time features):
    Library: Pusher, Ably, or raw WebSocket
    Pattern: connect on mount, subscribe to channels, update state on message

  Revalidation (data freshness):
    Server Action: revalidateTag("resource-list") after mutation
    Cron: periodic revalidation for slowly-changing data

FEEDBACK:
  - "New items available" banner (click to refresh)
  - Optimistic updates (update UI immediately, reconcile on server response)
  - Connection status indicator (online/offline/reconnecting)
```

### 7.10 GESTURES (MOBILE)

```spec
TRIGGER: touch interactions on mobile devices

SUBTYPES:
  tap           single touch (= click)
  long-press    hold 500ms+ (context menu, drag start)
  swipe         horizontal/vertical drag (dismiss, navigate, reveal actions)
  pinch-zoom    two-finger zoom (image gallery)
  pull-refresh  pull down from top (refresh content)

IMPLEMENTATION:
  Most gestures handled by native browser + React events
  Complex: use-gesture library (@use-gesture/react)

  Swipe to dismiss (toast):
    CSS: touch-action: pan-y (allow vertical scroll only)
    JS: track touchstart/touchmove/touchend, apply translateX

RULES:
  - Every gesture MUST have a non-gesture alternative
  - Swipe targets: minimum 44x44px touch target
  - Prevent accidental gestures near screen edges
```

---

## INTERACTION MATRIX BY COMPONENT

```spec
COMPONENT          | INTERACTIONS
-------------------|----------------------------------------------
Button             | click, hover, focus, active, disabled, loading
Input              | focus, blur, type, paste, clear, error
Select             | click-open, arrow-navigate, type-filter, select, close
Checkbox           | click-toggle, focus, space-toggle
Switch             | click-toggle, focus, space-toggle, drag
Slider             | drag, click-position, arrow-step, focus
Dialog             | open(trigger-click), close(escape/backdrop/button), focus-trap
Sheet              | open(trigger-click), close(escape/backdrop/swipe), focus-trap
Dropdown           | open(click), navigate(arrows), select(enter), close(escape/click-outside)
Tabs               | click-tab, arrow-navigate, focus
Accordion          | click-toggle, focus, enter/space-toggle
Tooltip            | hover-show, focus-show, escape-hide
Toast              | auto-dismiss, click-dismiss, swipe-dismiss, action-click
Table              | sort(header-click), filter(input), paginate, select(checkbox), row-click
Sidebar            | toggle-expand/collapse, nav-click, mobile-sheet
Command            | open(cmd+k), type-filter, arrow-navigate, enter-select, escape-close
Form               | input-all-fields, validate, submit, error-focus, success-redirect
```
