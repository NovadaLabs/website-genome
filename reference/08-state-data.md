# 08 — State Management & Data Layer

## PURPOSE

```spec
This file defines HOW data flows through a website:
- Where data lives (client, server, database, URL)
- How to read it (fetch, query, props)
- How to write it (mutations, server actions, API calls)
- How to keep it fresh (revalidation, real-time, polling)
Every interactive website needs a data strategy. This is it.
```

---

## STATE TYPES

### 8.1 UI STATE (client-only, ephemeral)

```spec
DEFINITION: State that only matters to the current UI view
EXAMPLES: modal open/closed, sidebar collapsed, active tab, form input values
LIFECYCLE: created on mount, destroyed on unmount or page navigation
STORAGE: React useState, useReducer

PATTERNS:
  // Simple toggle
  const [isOpen, setIsOpen] = useState(false)

  // Complex form
  const form = useForm({ resolver: zodResolver(schema) })

  // Multi-step wizard
  const [step, setStep] = useState(1)

RULES:
  - Do NOT put UI state in global stores (unless truly app-wide like theme)
  - Colocate state with the component that uses it
  - Lift state ONLY when a sibling component needs it
```

### 8.2 URL STATE (shareable, bookmarkable)

```spec
DEFINITION: State encoded in the URL (path, search params, hash)
EXAMPLES: current page, filters, sort order, search query, selected tab
LIFECYCLE: persists across page loads, shareable via URL
STORAGE: URL path segments, searchParams

PATTERNS:
  // Read in Server Component
  export default async function Page({
    searchParams
  }: {
    searchParams: Promise<{ q?: string; page?: string; sort?: string }>
  }) {
    const { q, page, sort } = await searchParams
    // use for data fetching
  }

  // Update from Client Component
  import { useRouter, useSearchParams, usePathname } from 'next/navigation'

  function Filters() {
    const router = useRouter()
    const pathname = usePathname()
    const searchParams = useSearchParams()

    const updateFilter = (key: string, value: string) => {
      const params = new URLSearchParams(searchParams.toString())
      params.set(key, value)
      router.push(`${pathname}?${params.toString()}`)
    }
  }

RULES:
  - Filters, pagination, sort → ALWAYS in URL (shareable, back-button works)
  - Modal open state → URL if you want direct linking, state if ephemeral
  - Multi-step wizard → URL (?step=2) for back-button support
  - Search query → URL (?q=term) for bookmarking/sharing
```

### 8.3 SERVER STATE (from database/API)

```spec
DEFINITION: Data that lives on the server and is fetched by the client
EXAMPLES: user profile, product list, dashboard metrics, notifications
LIFECYCLE: fetched on request, cached, revalidated

PATTERNS (Next.js App Router):

  // Server Component — fetch directly (no hooks needed)
  export default async function DashboardPage() {
    const stats = await getStats()           // direct DB/API call
    const recentItems = await getRecent(10)  // runs on server
    return <Dashboard stats={stats} items={recentItems} />
  }

  // With caching
  // Method 1: 'use cache' directive (Next.js 16+)
  'use cache'
  export async function getProducts() {
    const products = await db.query.products.findMany()
    return products
  }
  // cacheLife('hours') or cacheTag('products') for fine control

  // Method 2: unstable_cache (older pattern)
  import { unstable_cache } from 'next/cache'
  const getCachedProducts = unstable_cache(
    async () => db.query.products.findMany(),
    ['products'],
    { revalidate: 3600, tags: ['products'] }
  )

REVALIDATION:
  Time-based:   revalidate: N (seconds) — stale-while-revalidate
  On-demand:    revalidateTag('products') — after mutation
  Path-based:   revalidatePath('/dashboard') — invalidate specific page

MUTATIONS (Server Actions):
  'use server'
  export async function createItem(formData: FormData) {
    const data = schema.parse(Object.fromEntries(formData))
    await db.insert(items).values(data)
    revalidateTag('items')     // refresh cached data
    redirect('/dashboard/items') // navigate to list
  }
```

### 8.4 GLOBAL CLIENT STATE (app-wide)

```spec
DEFINITION: Client-side state shared across many components
EXAMPLES: theme (dark/light), auth session, shopping cart, notification count
LIFECYCLE: persists across navigation within the app

PATTERNS:
  // React Context (simple cases)
  const ThemeContext = createContext<{ theme: string; setTheme: (t: string) => void }>()

  // Zustand (complex state — recommended for cart, complex filters)
  import { create } from 'zustand'
  const useCartStore = create((set) => ({
    items: [],
    addItem: (item) => set((s) => ({ items: [...s.items, item] })),
    removeItem: (id) => set((s) => ({ items: s.items.filter(i => i.id !== id) })),
    total: () => { /* compute */ }
  }))

RULES:
  - Default to Server Components + props for data flow
  - Only use global client state for truly cross-cutting concerns
  - Theme: use next-themes library (handles SSR hydration)
  - Auth: use Clerk hooks (useUser, useAuth) or server-side auth()
  - Cart: Zustand + localStorage persistence
  - Do NOT replicate server state in client stores
```

### 8.5 PERSISTENT STATE (survives browser close)

```spec
DEFINITION: State stored in browser storage
EXAMPLES: cart items, user preferences, draft form data, recently viewed
STORAGE: localStorage, sessionStorage, cookies

PATTERNS:
  // localStorage (simple key-value)
  localStorage.setItem('cart', JSON.stringify(items))
  const cart = JSON.parse(localStorage.getItem('cart') || '[]')

  // Cookies (for server-readable state like theme, locale)
  import { cookies } from 'next/headers'
  const cookieStore = await cookies()
  const theme = cookieStore.get('theme')?.value || 'dark'

  // Zustand with localStorage persistence
  import { persist } from 'zustand/middleware'
  const useCartStore = create(persist(
    (set) => ({ items: [], /* ... */ }),
    { name: 'cart-storage' }
  ))

RULES:
  - localStorage: max 5-10MB, NOT available in Server Components
  - Cookies: max 4KB, available in Server Components and proxy.ts
  - Session storage: same as localStorage but clears on tab close
  - NEVER store sensitive data (tokens, passwords) in localStorage
  - Auth tokens: httpOnly cookies only (set by server)
```

---

## DATABASE LAYER

### 8.6 DATABASE SETUP

```spec
DEFAULT: Neon Postgres (via Vercel Marketplace)
ORM: Drizzle ORM [D] (or Prisma)

SETUP:
  1. vercel integration add neon (or add via dashboard)
  2. Neon auto-provisions DATABASE_URL env var
  3. npm install drizzle-orm @neondatabase/serverless drizzle-kit
  4. Create schema (db/schema.ts)
  5. Run migration: npx drizzle-kit push

SCHEMA PATTERN:
  // db/schema.ts
  import { pgTable, text, timestamp, uuid, boolean, integer } from 'drizzle-orm/pg-core'

  export const users = pgTable('users', {
    id: uuid('id').primaryKey().defaultRandom(),
    email: text('email').notNull().unique(),
    name: text('name'),
    avatarUrl: text('avatar_url'),
    role: text('role').notNull().default('user'),
    createdAt: timestamp('created_at').defaultNow().notNull(),
    updatedAt: timestamp('updated_at').defaultNow().notNull(),
  })

  export const items = pgTable('items', {
    id: uuid('id').primaryKey().defaultRandom(),
    userId: uuid('user_id').references(() => users.id).notNull(),
    title: text('title').notNull(),
    description: text('description'),
    status: text('status').notNull().default('active'),
    createdAt: timestamp('created_at').defaultNow().notNull(),
  })

DB CLIENT:
  // db/index.ts
  import { neon } from '@neondatabase/serverless'
  import { drizzle } from 'drizzle-orm/neon-http'
  import * as schema from './schema'

  const sql = neon(process.env.DATABASE_URL!)
  export const db = drizzle(sql, { schema })

QUERY PATTERNS:
  // List with filters
  const items = await db.query.items.findMany({
    where: eq(items.userId, userId),
    orderBy: desc(items.createdAt),
    limit: 20,
    offset: page * 20,
  })

  // Insert
  const [newItem] = await db.insert(items).values({ title, userId }).returning()

  // Update
  await db.update(items).set({ status: 'done' }).where(eq(items.id, itemId))

  // Delete
  await db.delete(items).where(eq(items.id, itemId))
```

### 8.7 CACHE LAYER

```spec
DEFAULT: Upstash Redis (via Vercel Marketplace) [C — when needed]

SETUP:
  1. vercel integration add upstash-redis
  2. Auto-provisions REDIS_URL, REDIS_TOKEN
  3. npm install @upstash/redis

USE CASES:
  - Rate limiting (API routes)
  - Session storage
  - Expensive computation caching
  - Real-time counters (views, likes)
  - Queue job status

PATTERN:
  import { Redis } from '@upstash/redis'
  const redis = Redis.fromEnv()

  // Cache with TTL
  await redis.set('key', value, { ex: 3600 })  // 1 hour TTL
  const cached = await redis.get('key')

  // Rate limiting
  const { success } = await ratelimit.limit(identifier)
  if (!success) return new Response('Too many requests', { status: 429 })
```

---

## DATA FLOW ARCHITECTURE

```spec
DATA FLOW DIAGRAM:

  Browser                    Server                      Database
  ┌──────────┐              ┌──────────────┐            ┌────────┐
  │  Client  │   fetch/     │  Server      │   query    │  Neon  │
  │  Comps   │──────────→   │  Components  │──────────→ │Postgres│
  │          │   useChat    │  Server      │   insert   │        │
  │          │──────────→   │  Actions     │──────────→ │        │
  │          │              │  Route       │            │        │
  │          │   REST/WS    │  Handlers    │   cache    │        │
  │          │──────────→   │              │──────────→ │Upstash │
  └──────────┘              └──────────────┘            └────────┘
       ↕                          ↕
  localStorage               env vars
  cookies                    secrets
  URL state                  file system

RULES:
  1. Default to Server Components for data fetching (no client fetch)
  2. Use Server Actions for mutations (not API routes)
  3. API routes only for: webhooks, external API access, file uploads
  4. Never expose database credentials to client
  5. Always validate on server (even if validated on client)
  6. Use optimistic updates for perceived performance
```

## AUTH DATA FLOW

```spec
WITH CLERK:

  // Server-side (Server Components, Server Actions, Route Handlers)
  import { auth } from '@clerk/nextjs/server'

  export default async function Page() {
    const { userId, orgId } = await auth()
    if (!userId) redirect('/login')
    const data = await getDataForUser(userId)
    return <Dashboard data={data} />
  }

  // Client-side
  import { useUser, useAuth } from '@clerk/nextjs'

  function Profile() {
    const { user } = useUser()
    return <p>{user?.fullName}</p>
  }

  // Proxy/Middleware (proxy.ts in Next.js 16)
  import { clerkMiddleware, createRouteMatcher } from '@clerk/nextjs/server'

  const isProtected = createRouteMatcher(['/dashboard(.*)'])
  export default clerkMiddleware(async (auth, req) => {
    if (isProtected(req)) await auth.protect()
  })

ROUTE PROTECTION MATRIX:
  /                    → public (no protection)
  /login, /signup      → public (redirect if already authed)
  /dashboard/*         → auth.protect() in proxy.ts
  /admin/*             → auth.protect({ role: 'admin' })
  /api/webhooks/*      → no auth (webhook secret verification instead)
  /api/*               → auth() check in route handler
```

## API ROUTE PATTERNS

```spec
WHEN TO USE ROUTE HANDLERS (instead of Server Actions):
  - Public API (third-party consumers)
  - Webhooks (Stripe, Clerk, GitHub)
  - File uploads (streaming body)
  - SSE/streaming responses (AI features)
  - External service callbacks (OAuth)

PATTERN:
  // app/api/items/route.ts
  import { NextRequest, NextResponse } from 'next/server'
  import { auth } from '@clerk/nextjs/server'

  export async function GET(request: NextRequest) {
    const { userId } = await auth()
    if (!userId) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })

    const { searchParams } = new URL(request.url)
    const page = parseInt(searchParams.get('page') || '1')

    const items = await db.query.items.findMany({
      where: eq(items.userId, userId),
      limit: 20,
      offset: (page - 1) * 20,
    })

    return NextResponse.json({ items, page })
  }

  export async function POST(request: NextRequest) {
    const { userId } = await auth()
    if (!userId) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })

    const body = await request.json()
    const data = createItemSchema.parse(body)  // validate with zod

    const [item] = await db.insert(items).values({ ...data, userId }).returning()
    return NextResponse.json(item, { status: 201 })
  }

WEBHOOK PATTERN:
  // app/api/webhooks/stripe/route.ts
  import { headers } from 'next/headers'
  import Stripe from 'stripe'

  export async function POST(request: NextRequest) {
    const body = await request.text()
    const headersList = await headers()
    const signature = headersList.get('stripe-signature')!

    const event = stripe.webhooks.constructEvent(
      body, signature, process.env.STRIPE_WEBHOOK_SECRET!
    )

    switch (event.type) {
      case 'checkout.session.completed':
        // handle payment success
        break
      case 'customer.subscription.updated':
        // handle subscription change
        break
    }

    return NextResponse.json({ received: true })
  }
```
