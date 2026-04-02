# 11 — Error & Edge Cases

## PURPOSE

```spec
Every state in a UI has an unhappy path. This file catalogs ALL of them.
A production website handles EVERY error gracefully.
Missing error handling = demo quality, not production quality.
```

---

## 11.1 LOADING STATES

```spec
EVERY DATA-DEPENDENT VIEW MUST HAVE A LOADING STATE.

PATTERNS:
  Skeleton:    shape-matched placeholder (preferred for layouts)
  Spinner:     centered loader (for full-page or section loads)
  Progress:    determinate bar (for file uploads, multi-step processes)
  Inline:      button spinner (for form submissions)
  Optimistic:  show expected result immediately, reconcile later

IMPLEMENTATION:
  // Page-level loading (Next.js)
  // app/dashboard/loading.tsx (automatic — shows while page data loads)
  export default function Loading() {
    return (
      <div className="p-6 space-y-6">
        <Skeleton className="h-8 w-48" />
        <div className="grid grid-cols-3 gap-6">
          <Skeleton className="h-32" />
          <Skeleton className="h-32" />
          <Skeleton className="h-32" />
        </div>
        <Skeleton className="h-[400px]" />
      </div>
    )
  }

  // Component-level loading (React Suspense)
  <Suspense fallback={<Skeleton className="h-[300px]" />}>
    <AsyncComponent />
  </Suspense>

  // Button loading state
  <Button disabled={isPending}>
    {isPending && <Loader2 className="h-4 w-4 animate-spin" />}
    {isPending ? 'Saving...' : 'Save'}
  </Button>

  // Optimistic update
  import { useOptimistic } from 'react'
  const [optimisticItems, addOptimistic] = useOptimistic(items,
    (state, newItem) => [...state, { ...newItem, pending: true }]
  )
```

## 11.2 ERROR STATES

```spec
ERROR LEVELS:
  Page error:      entire page failed to load → error.tsx
  Section error:   part of page failed → ErrorBoundary around section
  Component error: single component failed → try/catch in server component
  Field error:     form validation → inline error message
  Action error:    mutation failed → toast or inline error
  Network error:   API unreachable → retry prompt

IMPLEMENTATION:
  // Page-level error boundary (app/dashboard/error.tsx)
  'use client'
  export default function Error({ error, reset }: {
    error: Error & { digest?: string }
    reset: () => void
  }) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[400px] gap-4">
        <AlertCircle className="h-12 w-12 text-destructive" />
        <h2 className="text-lg font-semibold">Something went wrong</h2>
        <p className="text-sm text-muted-foreground max-w-md text-center">
          {error.message || 'An unexpected error occurred.'}
        </p>
        <Button onClick={reset}>Try again</Button>
      </div>
    )
  }

  // Global error (app/global-error.tsx — catches root layout errors)
  'use client'
  export default function GlobalError({ error, reset }: {
    error: Error & { digest?: string }
    reset: () => void
  }) {
    return (
      <html><body>
        <div className="flex min-h-svh items-center justify-center">
          <div className="text-center space-y-4">
            <h1 className="text-2xl font-bold">Something went wrong</h1>
            <Button onClick={reset}>Try again</Button>
          </div>
        </div>
      </body></html>
    )
  }

  // Server Action error handling
  'use server'
  export async function createItem(formData: FormData) {
    try {
      const data = schema.parse(Object.fromEntries(formData))
      await db.insert(items).values(data)
      revalidateTag('items')
    } catch (error) {
      if (error instanceof z.ZodError) {
        return { error: 'Validation failed', details: error.flatten() }
      }
      return { error: 'Failed to create item. Please try again.' }
    }
    redirect('/dashboard/items')
  }

  // Client-side action error (useActionState)
  import { useActionState } from 'react'
  const [state, formAction, isPending] = useActionState(createItem, null)

  {state?.error && (
    <Alert variant="destructive">
      <AlertTitle>Error</AlertTitle>
      <AlertDescription>{state.error}</AlertDescription>
    </Alert>
  )}
```

## 11.3 EMPTY STATES

```spec
EVERY LIST/TABLE/COLLECTION MUST HAVE AN EMPTY STATE.

PATTERNS:
  First-time:   "No projects yet" + "Create your first project" button
  Filtered:     "No results match your filters" + "Clear filters" button
  Search:       "No results for 'query'" + suggestions
  Deleted all:  "All items deleted" + "Create new" button
  Permission:   "You don't have access to this resource" + contact admin

IMPLEMENTATION:
  {items.length === 0 ? (
    <div className="flex flex-col items-center justify-center py-16 text-center">
      <div className="rounded-full bg-muted p-4 mb-4">
        <Inbox className="h-8 w-8 text-muted-foreground" />
      </div>
      <h3 className="text-lg font-semibold">No projects yet</h3>
      <p className="text-sm text-muted-foreground mt-1 max-w-sm">
        Create your first project to get started.
      </p>
      <Button className="mt-6">
        <Plus className="h-4 w-4" /> Create Project
      </Button>
    </div>
  ) : (
    <DataTable data={items} />
  )}
```

## 11.4 NOT FOUND (404)

```spec
FILE: app/not-found.tsx

TRIGGERS:
  - URL doesn't match any route
  - Dynamic route param doesn't resolve (notFound() called)
  - Deleted resource accessed via old link

IMPLEMENTATION:
  // app/not-found.tsx
  import Link from 'next/link'

  export default function NotFound() {
    return (
      <div className="flex min-h-svh flex-col items-center justify-center gap-4">
        <h1 className="text-6xl font-bold text-muted-foreground">404</h1>
        <h2 className="text-xl font-semibold">Page not found</h2>
        <p className="text-sm text-muted-foreground">
          The page you're looking for doesn't exist or has been moved.
        </p>
        <Button asChild><Link href="/">Go home</Link></Button>
      </div>
    )
  }

  // Trigger in dynamic routes
  import { notFound } from 'next/navigation'
  export default async function Page({ params }: { params: Promise<{ id: string }> }) {
    const { id } = await params
    const item = await getItem(id)
    if (!item) notFound()
    return <ItemDetail item={item} />
  }
```

## 11.5 NETWORK / OFFLINE STATES

```spec
PATTERNS:
  Slow network:     loading states with timeout → "Taking longer than usual"
  Offline:          "You're offline" banner + cached content
  API down:         "Service unavailable" + retry button
  Rate limited:     "Too many requests" + wait timer

IMPLEMENTATION:
  // Offline detection
  'use client'
  const [isOnline, setIsOnline] = useState(true)
  useEffect(() => {
    setIsOnline(navigator.onLine)
    const handleOnline = () => setIsOnline(true)
    const handleOffline = () => setIsOnline(false)
    window.addEventListener('online', handleOnline)
    window.addEventListener('offline', handleOffline)
    return () => {
      window.removeEventListener('online', handleOnline)
      window.removeEventListener('offline', handleOffline)
    }
  }, [])

  // Offline banner
  {!isOnline && (
    <div className="bg-destructive text-destructive-foreground px-4 py-2 text-center text-sm">
      You're offline. Some features may be unavailable.
    </div>
  )}
```

## 11.6 AUTH EDGE CASES

```spec
CASES:
  Session expired:     redirect to /login?redirect=/current-page
  Token refresh:       Clerk handles automatically
  Role changed:        revalidate on next request (may lose access mid-session)
  Account deleted:     sign out + redirect to landing
  Org not found:       redirect to org creation (Clerk orgs)
  Email not verified:  block dashboard access, show verification prompt
  Banned/suspended:    show account status page, not dashboard

IMPLEMENTATION:
  // Session expired → proxy.ts handles
  export default clerkMiddleware(async (auth, req) => {
    if (isProtected(req)) {
      await auth.protect()  // auto-redirects to /login if session expired
    }
  })

  // No org after login
  const { orgId } = await auth()
  if (!orgId && isOrgRequired) {
    redirect('/create-org')
  }
```

## 11.7 FORM EDGE CASES

```spec
CASES:
  Double submit:     disable button on first click + debounce
  Back button:       preserve form state (store in URL or sessionStorage)
  Accidental close:  beforeunload prompt if form is dirty
  Paste bomb:        maxLength on inputs, validate on server
  Autofill:          ensure labels work with browser autofill
  File too large:    client-side size check + server-side limit
  Wrong file type:   accept attribute + client-side type check
  Timeout:           server action timeout → show retry

IMPLEMENTATION:
  // Prevent double submit (useActionState handles via isPending)
  <Button disabled={isPending} type="submit">
    {isPending ? 'Saving...' : 'Save'}
  </Button>

  // Dirty form warning
  useEffect(() => {
    if (!isDirty) return
    const handler = (e: BeforeUnloadEvent) => {
      e.preventDefault()
      e.returnValue = ''
    }
    window.addEventListener('beforeunload', handler)
    return () => window.removeEventListener('beforeunload', handler)
  }, [isDirty])
```

## 11.8 RESPONSIVE EDGE CASES

```spec
→ see: 12-responsive.md for full responsive spec

CASES:
  Text overflow:       truncate with ellipsis or wrap
  Image overflow:      object-cover + overflow-hidden
  Table overflow:      horizontal scroll wrapper on mobile
  Long URLs/words:     break-all or break-words
  Tiny viewport:       min-w on critical elements
  Landscape phone:     test at 667x375
  Foldable devices:    test at various fold states
  Zoom 200%:           all content still accessible (WCAG requirement)
```

## 11.9 DATA EDGE CASES

```spec
CASES:
  Null/undefined:     always handle with fallback values
  Empty string:       distinguish from null (empty name vs no name)
  Very long text:     truncate with ... or use ScrollArea
  Special characters: XSS prevention (React handles by default)
  Unicode/emoji:      ensure font supports it, test rendering
  Large numbers:      format with Intl.NumberFormat
  Dates:              timezone handling (store UTC, display local)
  Pagination edge:    last page may have fewer items → don't show empty rows
  Concurrent edit:    two users edit same resource → last-write-wins or conflict resolution
  Stale data:         show "updated X minutes ago" + refresh button

IMPLEMENTATION:
  // Null safety
  <p>{user?.name || 'Unknown User'}</p>
  <p>{item?.description || <span className="text-muted-foreground italic">No description</span>}</p>

  // Number formatting
  new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount)
  new Intl.NumberFormat('en-US', { notation: 'compact' }).format(largeNumber)

  // Date formatting
  new Intl.DateTimeFormat('en-US', { dateStyle: 'medium' }).format(new Date(dateString))

  // Truncation
  <p className="truncate">{longText}</p>  // single line
  <p className="line-clamp-3">{longText}</p>  // multi-line (3 lines)
```
