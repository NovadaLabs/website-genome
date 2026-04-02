# 09 — Invisible Layer (SEO, Accessibility, Performance, Security)

## PURPOSE

```spec
The invisible layer is everything users don't see but production websites MUST have.
Missing this layer = looks good in demo, fails in production.
Four pillars: SEO, Accessibility, Performance, Security.
```

---

## 9.1 SEO (Search Engine Optimization)

### META TAGS

```spec
EVERY PAGE MUST HAVE:
  <title>        unique, 50-60 chars, primary keyword first
  <meta description>  unique, 150-160 chars, compelling summary
  <meta viewport>     "width=device-width, initial-scale=1" (Next.js default)
  <link canonical>    self-referencing canonical URL
  <meta robots>       "index, follow" (default) or "noindex" for private pages

NEXT.JS IMPLEMENTATION:
  // Static metadata (app/page.tsx or any page/layout)
  export const metadata: Metadata = {
    title: 'Page Title — Brand',
    description: 'Page description for search results.',
    alternates: { canonical: 'https://example.com/page' },
  }

  // Dynamic metadata (for [slug] pages)
  export async function generateMetadata({ params }: Props): Promise<Metadata> {
    const { slug } = await params
    const post = await getPost(slug)
    return {
      title: `${post.title} — Brand`,
      description: post.excerpt,
      alternates: { canonical: `https://example.com/blog/${slug}` },
    }
  }

  // Layout-level (app/layout.tsx — defaults for all pages)
  export const metadata: Metadata = {
    metadataBase: new URL('https://example.com'),
    title: { default: 'Brand', template: '%s — Brand' },
    description: 'Default site description',
    openGraph: {
      type: 'website',
      locale: 'en_US',
      siteName: 'Brand',
    },
    twitter: { card: 'summary_large_image' },
  }
```

### OPEN GRAPH & SOCIAL

```spec
REQUIRED FOR SOCIAL SHARING:
  og:title        same as <title> or shorter
  og:description  same as meta description
  og:image        1200x630px recommended
  og:url          canonical URL
  og:type         website | article | product
  twitter:card    summary_large_image

NEXT.JS:
  export const metadata: Metadata = {
    openGraph: {
      title: 'Page Title',
      description: 'Description',
      images: [{ url: '/og-image.png', width: 1200, height: 630 }],
    },
    twitter: {
      card: 'summary_large_image',
      images: ['/og-image.png'],
    },
  }

DYNAMIC OG IMAGES:
  // app/api/og/route.tsx (or app/opengraph-image.tsx)
  import { ImageResponse } from 'next/og'
  export async function GET(request: Request) {
    return new ImageResponse(
      <div style={{ display: 'flex', fontSize: 48, background: 'black', color: 'white',
        width: '100%', height: '100%', alignItems: 'center', justifyContent: 'center' }}>
        Title Here
      </div>,
      { width: 1200, height: 630 }
    )
  }
```

### STRUCTURED DATA (JSON-LD)

```spec
PURPOSE: Help search engines understand page content (rich snippets)
FORMAT: JSON-LD in <script type="application/ld+json">

TYPES:
  Organization    brand/company info (homepage)
  WebSite         site-level info with search action
  Article         blog posts, news articles
  Product         e-commerce product pages
  FAQ             FAQ pages (expandable in search results)
  BreadcrumbList  navigation breadcrumbs
  SoftwareApplication  software/SaaS products

IMPLEMENTATION:
  // components/json-ld.tsx
  export function JsonLd({ data }: { data: Record<string, unknown> }) {
    return (
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }}
      />
    )
  }

  // Usage in page
  <JsonLd data={{
    "@context": "https://schema.org",
    "@type": "Article",
    "headline": post.title,
    "author": { "@type": "Person", "name": post.author },
    "datePublished": post.date,
    "image": post.coverImage,
  }} />
```

### SITEMAP & ROBOTS

```spec
SITEMAP (app/sitemap.ts):
  import type { MetadataRoute } from 'next'

  export default function sitemap(): MetadataRoute.Sitemap {
    return [
      { url: 'https://example.com', lastModified: new Date(), priority: 1 },
      { url: 'https://example.com/features', lastModified: new Date(), priority: 0.8 },
      { url: 'https://example.com/pricing', lastModified: new Date(), priority: 0.8 },
      // dynamically add blog posts, products, etc.
    ]
  }

ROBOTS (app/robots.ts):
  import type { MetadataRoute } from 'next'

  export default function robots(): MetadataRoute.Robots {
    return {
      rules: [
        { userAgent: '*', allow: '/', disallow: ['/dashboard', '/api', '/admin'] },
      ],
      sitemap: 'https://example.com/sitemap.xml',
    }
  }
```

### HEADING HIERARCHY

```spec
RULES:
  - ONE h1 per page (page title / main topic)
  - h2 for major sections
  - h3 for subsections within h2
  - NEVER skip levels (h1 → h3 without h2)
  - Headings should be descriptive (include keywords naturally)
```

---

## 9.2 ACCESSIBILITY (a11y)

### WCAG 2.1 AA CHECKLIST

```spec
PERCEIVABLE:
  ☐ All images have alt text (decorative: alt="", meaningful: descriptive alt)
  ☐ Color contrast >= 4.5:1 for normal text, >= 3:1 for large text
  ☐ Information not conveyed by color alone (add icons, text, patterns)
  ☐ Text resizable to 200% without loss of content
  ☐ Captions for video content [C]
  ☐ Audio descriptions for video [C]

OPERABLE:
  ☐ All functionality keyboard accessible (Tab, Enter, Space, Escape, Arrows)
  ☐ Visible focus indicators on all interactive elements
  ☐ Skip-to-content link (first focusable element)
  ☐ No keyboard traps (except modals, which trap intentionally)
  ☐ Page titles describe page purpose
  ☐ Focus order follows visual order
  ☐ Touch targets >= 44x44px on mobile
  ☐ No content that flashes > 3 times per second

UNDERSTANDABLE:
  ☐ Language declared: <html lang="en">
  ☐ Form inputs have visible labels (not just placeholder)
  ☐ Error messages identify the field and describe the error
  ☐ Required fields indicated visually and programmatically
  ☐ Consistent navigation across pages

ROBUST:
  ☐ Valid, semantic HTML (proper element usage)
  ☐ ARIA attributes correct (roles, states, properties)
  ☐ Name, role, value exposed for all UI components
```

### SEMANTIC HTML

```spec
USE CORRECT ELEMENTS:
  <header>     page/section header
  <nav>        navigation blocks
  <main>       main content (ONE per page)
  <article>    self-contained content
  <section>    thematic grouping with heading
  <aside>      complementary content
  <footer>     page/section footer
  <button>     clickable actions (NOT <div onClick>)
  <a>          navigation (NOT <span onClick>)
  <h1>-<h6>   headings (NOT <p className="text-2xl font-bold">)
  <ul>/<ol>    lists (NOT <div> with dashes)
  <table>      tabular data (NOT <div> grid for data tables)
  <form>       form containers
  <label>      form labels (with htmlFor)
  <fieldset>   group related form controls
  <legend>     caption for fieldset
```

### ARIA PATTERNS

```spec
RULES:
  1. Prefer semantic HTML over ARIA (a button is better than div role="button")
  2. Don't change native semantics (don't put role="button" on an <a>)
  3. All interactive ARIA elements must be keyboard operable
  4. Don't use role="presentation" or aria-hidden on focusable elements
  5. All interactive elements must have accessible name

COMMON PATTERNS:
  Icon button:     <button aria-label="Close"><X /></button>
  Loading:         <div aria-busy="true" aria-live="polite">Loading...</div>
  Live region:     <div aria-live="polite">{status message}</div>
  Modal:           role="dialog" aria-modal="true" aria-labelledby aria-describedby
  Tab panel:       role="tablist" / role="tab" / role="tabpanel" (Radix handles)
  Alert:           role="alert" (auto-announced by screen readers)
  Status:          role="status" (polite announcement)
  Error:           aria-invalid="true" aria-describedby="error-msg-id"
  Required:        aria-required="true" + required attribute
  Expanded:        aria-expanded="true/false" (accordion, dropdown)
  Current page:    aria-current="page" (nav links)
```

### SKIP LINK

```spec
IMPLEMENTATION (first element in <body>):
  <a href="#main-content"
    className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4
      focus:z-50 focus:bg-background focus:px-4 focus:py-2 focus:rounded-md
      focus:border focus:shadow-md">
    Skip to content
  </a>

  // Target
  <main id="main-content" tabIndex={-1}>
```

---

## 9.3 PERFORMANCE

### CORE WEB VITALS TARGETS

```spec
LCP (Largest Contentful Paint):  < 2.5s [GOOD]
INP (Interaction to Next Paint):  < 200ms [GOOD]
CLS (Cumulative Layout Shift):   < 0.1 [GOOD]
FCP (First Contentful Paint):    < 1.8s
TTFB (Time to First Byte):      < 800ms
```

### IMAGE OPTIMIZATION

```spec
ALWAYS USE next/image:
  - Automatic format conversion (WebP/AVIF)
  - Automatic responsive sizing
  - Lazy loading by default
  - Prevents CLS (reserves space via width/height)

RULES:
  - Set width + height (or use fill) on ALL images
  - Add priority prop to above-the-fold images (hero, LCP)
  - Add sizes prop for responsive images: sizes="(max-width: 768px) 100vw, 50vw"
  - Configure remotePatterns in next.config.ts for external images
  - Use placeholder="blur" for large images (better perceived load)
```

### FONT OPTIMIZATION

```spec
ALWAYS USE next/font:
  // app/layout.tsx
  import { GeistSans } from 'geist/font/sans'
  import { GeistMono } from 'geist/font/mono'

  <body className={`${GeistSans.variable} ${GeistMono.variable}`}>

BENEFITS:
  - Self-hosted (no external requests to Google Fonts)
  - Automatic font subsetting
  - Zero CLS (font-display: swap + size-adjust)
  - Preloaded automatically
```

### CODE SPLITTING & LAZY LOADING

```spec
AUTOMATIC (Next.js handles):
  - Route-based code splitting (each page = separate bundle)
  - Server Components send zero JS to client by default

MANUAL:
  // Lazy load heavy client components
  import dynamic from 'next/dynamic'
  const HeavyChart = dynamic(() => import('@/components/heavy-chart'), {
    loading: () => <Skeleton className="h-[300px]" />,
    ssr: false,  // skip server rendering for client-only components
  })

  // Lazy load below-fold sections
  const Features = dynamic(() => import('@/components/features'))
```

### BUNDLE SIZE

```spec
RULES:
  - Audit with: npx @next/bundle-analyzer
  - No single page JS > 200KB gzipped
  - Avoid importing entire libraries (use tree-shaking imports)
  - date-fns: import { format } from 'date-fns' (not import * as dateFns)
  - lodash: use lodash-es or individual imports
  - Icons: import { Search } from 'lucide-react' (tree-shakes)
  - Charts: lazy load recharts (heavy)
```

### CACHING STRATEGY

```spec
STATIC PAGES (SSG):
  Cache-Control: public, max-age=31536000, immutable
  Automatic on Vercel for static pages

ISR PAGES:
  revalidate: N (seconds) — stale-while-revalidate
  Cache-Control: s-maxage=N, stale-while-revalidate

DYNAMIC PAGES (SSR):
  Cache-Control: private, no-cache
  Use 'use cache' for component-level caching

API ROUTES:
  Set Cache-Control header explicitly
  return NextResponse.json(data, {
    headers: { 'Cache-Control': 'public, s-maxage=60, stale-while-revalidate=300' }
  })

STATIC ASSETS:
  Automatic on Vercel: immutable caching for _next/static/*
```

---

## 9.4 SECURITY

### INPUT VALIDATION

```spec
RULE: Validate on BOTH client AND server. Client is UX, server is security.

CLIENT (zod + react-hook-form):
  const schema = z.object({
    email: z.string().email(),
    name: z.string().min(2).max(100),
    content: z.string().max(10000),
  })

SERVER (same schema, always re-validate):
  'use server'
  export async function createItem(formData: FormData) {
    const raw = Object.fromEntries(formData)
    const data = schema.parse(raw)  // throws if invalid
    // safe to use data
  }
```

### XSS PREVENTION

```spec
REACT DEFAULT: JSX auto-escapes all string content (safe by default)

DANGER ZONES:
  - dangerouslySetInnerHTML — ONLY use with sanitized HTML
  - href={userInput} — validate URL scheme (no javascript:)
  - eval(), Function() — NEVER use with user input

SANITIZATION (when HTML rendering is needed):
  import DOMPurify from 'isomorphic-dompurify'
  <div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(htmlContent) }} />
```

### CSRF PROTECTION

```spec
NEXT.JS SERVER ACTIONS: Built-in CSRF protection (automatic origin check)
API ROUTES: Verify Origin header matches your domain

IMPLEMENTATION:
  export async function POST(request: NextRequest) {
    const origin = request.headers.get('origin')
    if (origin !== process.env.NEXT_PUBLIC_URL) {
      return NextResponse.json({ error: 'Forbidden' }, { status: 403 })
    }
    // process request
  }
```

### RATE LIMITING

```spec
USE: Protect API routes from abuse
IMPLEMENTATION: Upstash rate limiter

  import { Ratelimit } from '@upstash/ratelimit'
  import { Redis } from '@upstash/redis'

  const ratelimit = new Ratelimit({
    redis: Redis.fromEnv(),
    limiter: Ratelimit.slidingWindow(10, '10s'),  // 10 requests per 10s
  })

  export async function POST(request: NextRequest) {
    const ip = request.headers.get('x-forwarded-for') || 'anonymous'
    const { success } = await ratelimit.limit(ip)
    if (!success) {
      return NextResponse.json({ error: 'Rate limited' }, { status: 429 })
    }
    // process
  }
```

### ENVIRONMENT VARIABLES

```spec
RULES:
  - NEVER commit .env files to git (.env*.local in .gitignore)
  - Server-only secrets: no NEXT_PUBLIC_ prefix
  - Client-safe values: NEXT_PUBLIC_ prefix (exposed to browser)
  - Use vercel env for production secrets
  - Validate env vars at build time:

  // env.ts (validate on import)
  import { z } from 'zod'
  const envSchema = z.object({
    DATABASE_URL: z.string().url(),
    CLERK_SECRET_KEY: z.string().min(1),
  })
  export const env = envSchema.parse(process.env)
```

### CONTENT SECURITY POLICY

```spec
IMPLEMENTATION (next.config.ts headers):
  async headers() {
    return [{
      source: '/(.*)',
      headers: [
        {
          key: 'Content-Security-Policy',
          value: [
            "default-src 'self'",
            "script-src 'self' 'unsafe-inline' 'unsafe-eval'",  // Next.js needs these
            "style-src 'self' 'unsafe-inline'",
            "img-src 'self' data: https:",
            "font-src 'self'",
            "connect-src 'self' https:",
          ].join('; ')
        },
        { key: 'X-Frame-Options', value: 'DENY' },
        { key: 'X-Content-Type-Options', value: 'nosniff' },
        { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
      ]
    }]
  }
```
