# 13 — Content Strategy

## PURPOSE

```spec
Every website needs content: text, images, icons, videos.
This file tells the executor agent WHERE to get content and HOW to generate it
when the human hasn't provided it.
```

---

## 13.1 TEXT CONTENT

### WHEN HUMAN PROVIDES COPY
```spec
ACTION: Use exactly as provided. Do not rewrite unless asked.
FORMAT: May come as plain text, markdown, Google Doc, or Notion link.
PROCESS: Copy into components, format per design tokens.
```

### WHEN NO COPY PROVIDED (AI-GENERATED)
```spec
ACTION: Generate contextually appropriate copy using AI.

GUIDELINES:
  - Match brand voice (professional, casual, technical — infer from context)
  - Keep copy concise (web users scan, don't read)
  - Use active voice ("Create a project" not "A project can be created")
  - Include real-seeming data (not "Lorem ipsum")
  - Headlines: benefit-focused, 6-12 words
  - Descriptions: 1-2 sentences, clear value prop
  - CTAs: action verbs ("Get Started", "Try Free", "View Dashboard")
  - Error messages: specific and helpful ("Email must include @" not "Invalid")

CONTENT TYPES TO GENERATE:
  Page titles:       descriptive, keyword-rich
  Hero headline:     benefit statement, 6-12 words
  Hero subtext:      value proposition, 1-2 sentences
  Feature titles:    capability name, 2-4 words
  Feature desc:      benefit explanation, 1-2 sentences
  CTA buttons:       action + object ("Create Project", "Start Free Trial")
  Nav labels:        1-2 words, consistent terminology
  Form labels:       clear field names
  Error messages:    specific problem + how to fix
  Empty states:      what to do next
  Placeholder text:  realistic examples (email: "jane@example.com", not "test@test.com")
  Legal pages:       ⚠️ DO NOT generate — use template with "customize" markers
  Testimonials:      ⚠️ DO NOT fabricate — use placeholder structure only

PLACEHOLDER DATA (realistic, not Lorem Ipsum):
  Names:        "Alex Chen", "Sarah Kim", "Marcus Johnson" (diverse, realistic)
  Emails:       "alex@company.com" (not test@test.com)
  Companies:    "Acme Inc", "TechFlow", "DataBridge" (realistic startup names)
  Metrics:      "$45,231.89", "2,345 users", "+12.5%" (realistic numbers)
  Dates:        Use recent dates relative to current date
  Descriptions: Realistic 1-2 sentence descriptions of plausible items
```

## 13.2 IMAGES

### MODE A: COPY FROM ORIGINAL (for replication projects)

```spec
Extract images from the original site. Do this BEFORE building.
See: 14-extraction-sop.md §2.7 (Asset Collection)

METHOD 1: Chrome DevTools MCP evaluate_script (best — most control)
  Run on each page of the original site:
    () => {
      const imgs = [...document.querySelectorAll('img')].map(img => ({
        src: img.src, alt: img.alt,
        width: img.naturalWidth, height: img.naturalHeight
      }));
      const bgImages = [...document.querySelectorAll('*')].reduce((acc, el) => {
        const bg = getComputedStyle(el).backgroundImage;
        if (bg && bg !== 'none') acc.push(bg);
        return acc;
      }, []);
      return { imgs, bgImages };
    }
  Then download each URL:
    mkdir -p public/images
    curl -o public/images/hero.png "https://original-site.com/path/to/hero.png"

METHOD 2: wget mirror (fastest bulk grab)
    wget --mirror --page-requisites --no-parent \
      --accept=png,jpg,jpeg,svg,webp,gif,ico,woff,woff2 \
      --directory-prefix=./assets-dump \
      https://original-site.com/
  Then cherry-pick needed files into public/images/.

METHOD 3: Browser "Save As Complete" (human fallback)
  Human opens page → Cmd+S → "Webpage, Complete" → saves all assets.
  Agent picks needed files from the saved folder.

METHOD 4: single-file npm (special cases)
    npx single-file https://original-site.com/page --output=page-complete.html
  Embeds all assets as data URIs. Agent extracts them later.

PRIORITY: Method 1 (precision) → Method 2 (speed) → Method 3 (fallback) → Method 4 (edge case)
⚠️ Download assets BEFORE building. Zero images = wireframe, not replica.
```

### MODE B: AI-GENERATED IMAGES (for original products or replacing copied assets)

```spec
When building from scratch, or replacing copied images with original ones.
AI can generate: hero illustrations, product screenshots, abstract backgrounds,
icons, logos, team avatars, blog thumbnails, OG images.

TOOL 1: GEMINI 3.1 FLASH IMAGE PREVIEW (recommended — free via AI Gateway)
  Best for: general-purpose image generation, text+image in one call
  How: AI SDK generateText() with model: 'google/gemini-3.1-flash-image-preview'
    import { generateText } from 'ai';
    const result = await generateText({
      model: 'google/gemini-3.1-flash-image-preview',
      prompt: 'Dark gradient background with floating 3D proxy nodes connected by glowing lines, tech aesthetic, 1200x600',
    });
    // result.files contains the generated image
  Save to: public/images/ at build time, not on every request

TOOL 2: FLUX 2 / IMAGEN 4.0 (via AI Gateway)
  Best for: high-quality illustrations, photorealistic images
  How: generateText with the specific model via AI Gateway (images in result.files)
  Use when: Gemini quality isn't sufficient for photorealism or specific art styles

TOOL 3: MIDJOURNEY (highest aesthetic quality)
  Best for: hero images, marketing visuals, brand photography
  How: Discord bot or web UI (manual — not agent-automatable)
  Cost: $10/mo subscription
  Use when: maximum visual quality matters (landing page hero, OG image)

TOOL 4: RECRAFT (recraft.ai)
  Best for: SVG icons, logos, brand assets, consistent style sets
  How: Web UI (manual) or API
  Use when: need custom icons/logos that Lucide doesn't cover

TOOL 5: GPT-IMAGE (OpenAI)
  Best for: quick generation, text-in-image
  How: ChatGPT or API
  Use when: need text rendered inside the image (infographics, badges)

PROMPT PATTERNS FOR WEBSITE ASSETS:
  Hero image:      "[brand style] background, [key visual element], [mood], wide format 1200x600"
  Product shot:    "Clean screenshot of [product type] dashboard, dark mode, realistic data"
  Team avatar:     "Professional headshot, [ethnicity], [gender], neutral background, friendly"
  Blog thumbnail:  "[topic] concept illustration, minimal, [brand color] accent, 600x400"
  Icon set:        "Minimal line icon for [concept], 24x24, single color, consistent stroke width"
  OG image:        "[brand name] — [page title], dark background, clean typography, 1200x630"

DECISION MATRIX:
  Need free + automated → Gemini via AI Gateway
  Need highest quality → Midjourney (manual)
  Need custom SVG icons → Recraft
  Need photorealistic → Imagen 4.0 via AI Gateway
  Need text-in-image → GPT-image
```

### MODE C: STOCK + FREE SOURCES (no AI needed)

```spec
1. HUMAN-PROVIDED ASSETS
   Format: SVG (logos, icons), PNG/WebP (screenshots), JPG (photos)
   Action: Place in public/ directory, reference with next/image

2. UNSPLASH API (free stock photos)
   Use: Hero backgrounds, team photos, blog post covers
   URL pattern: https://images.unsplash.com/photo-{id}?w={width}&h={height}&fit=crop
   Configure in next.config.ts:
     images: { remotePatterns: [{ hostname: 'images.unsplash.com' }] }
   ⚠️ Requires attribution (link to photographer)

3. SVG ILLUSTRATIONS
   Use: Empty states, error pages, onboarding
   Sources: undraw.co (free, customizable colors), illustrations.co
   Action: Download SVG, place in public/ or components/illustrations/

4. PLACEHOLDER SERVICES (development only)
   Options: https://placehold.co/600x400/1a1a1a/ffffff?text=Hero+Image
   ⚠️ Replace ALL placeholders before deployment
```

### IMAGE SPECIFICATIONS

```spec
HERO IMAGE:
  Size: 1200x600 or 1920x1080 (depends on layout)
  Format: WebP or AVIF (next/image converts automatically)
  Priority: yes (above-the-fold, LCP candidate)

OG IMAGE:
  Size: 1200x630 (required for social sharing)
  Format: PNG
  Content: brand + page title + visual

CARD THUMBNAILS:
  Size: 400x300 or 600x400 (aspect 4:3)
  Format: WebP

AVATARS:
  Size: 80x80 to 200x200
  Format: WebP or PNG
  Shape: rounded-full (circular)

FAVICON:
  Sizes: 16x16, 32x32, 180x180 (apple-touch-icon), 512x512 (PWA)
  Format: ICO (16/32), PNG (180/512)
  Place: app/icon.tsx (dynamic) or public/favicon.ico (static)

LOGO:
  Format: SVG (scalable, small file size) [PREFERRED]
  Variants: full (text + icon), icon-only (for compact spaces)
  Colors: primary + white + dark versions
```

## 13.3 ICONS

```spec
PRIMARY: lucide-react (installed with shadcn/ui)
  import { Icon } from "lucide-react"
  2000+ icons, tree-shakeable, consistent style

CUSTOM ICONS (when lucide doesn't have what you need):
  Option 1: SVG component
    export function CustomIcon({ className }: { className?: string }) {
      return <svg className={className} viewBox="0 0 24 24">{/* paths */}</svg>
    }

  Option 2: React Icons (react-icons package — multiple icon sets)
    npm install react-icons
    import { FaGithub } from "react-icons/fa"

BRAND ICONS (social, company logos):
  GitHub, Twitter/X, LinkedIn, Google, Apple, etc.
  Source: react-icons/si (Simple Icons) or custom SVGs
  ⚠️ Follow brand guidelines for colors and usage

FAVICON GENERATION:
  // app/icon.tsx (dynamic favicon from code)
  import { ImageResponse } from 'next/og'
  export const size = { width: 32, height: 32 }
  export const contentType = 'image/png'
  export default function Icon() {
    return new ImageResponse(
      <div style={{ fontSize: 24, background: '#000', color: '#fff',
        width: '100%', height: '100%', display: 'flex',
        alignItems: 'center', justifyContent: 'center', borderRadius: 6 }}>
        B
      </div>,
      { ...size }
    )
  }
```

## 13.4 VIDEOS, GIFS & ANIMATIONS

```spec
AI-GENERATED VIDEO/GIF:
  Kling (kling.ai):        Short product demos, hero background videos. Best quality.
  Runway Gen-3 (runway.ml): Cinematic short clips, brand videos. Professional grade.
  Pika (pika.art):          Quick animated clips from text or image prompts.
  Use when: hero section needs motion, product demo without real product, explainer clips

ANIMATIONS (no video file needed):
  Lottie (lottiefiles.com): Micro-animations, loading states, onboarding illustrations.
    Huge free library. Lightweight JSON format. Use @lottiefiles/react-lottie-player.
  CSS/Tailwind animations:  Hover effects, scroll reveals, fade-ins.
    Agent writes these directly in code — no external tool needed.
  Framer Motion:            Complex page transitions, layout animations.
    npm install framer-motion. Use sparingly — adds bundle size.

SELF-HOSTED VIDEO:
  Use Vercel Blob for video storage
  Implement with HTML5 <video> tag
  Lazy load below-fold videos
  Convert GIF → MP4 (10x smaller file size, same visual)

EMBEDDED (YouTube, Vimeo, Loom):
  Use iframe with lazy loading
  <iframe
    src="https://www.youtube.com/embed/{id}"
    loading="lazy"
    className="w-full aspect-video rounded-lg"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope"
    allowFullScreen
  />

PRODUCT DEMOS:
  Option 1: AI-generated video (Kling/Runway from product description)
  Option 2: Screen recording (MP4, hosted on Vercel Blob)
  Option 3: Animated GIF → convert to MP4 (smaller file)
  Option 4: Interactive demo (iframe to staging env or Vercel Sandbox)
  Option 5: Lottie animation (lightweight, looping, no video file)
```

## 13.5 CONTENT DECISION MATRIX

```spec
CONTENT TYPE     | HUMAN PROVIDED? | ACTION
-----------------|-----------------|-----------------------------------
Brand name       | REQUIRED        | Cannot generate — ask human
Logo             | PREFERRED       | Use text logo if not provided
Hero copy        | OPTIONAL        | Generate benefit-focused headline
Feature list     | OPTIONAL        | Generate based on product type
Pricing          | REQUIRED        | Cannot fabricate pricing
Testimonials     | PREFERRED       | Use placeholder structure (no fake quotes)
Blog posts       | OPTIONAL        | Generate sample posts
Legal pages      | REQUIRED        | Use template markers (human must review)
Product data     | REQUIRED        | Cannot fabricate product catalog
Team photos      | OPTIONAL        | Use avatar placeholders
Hero image       | OPTIONAL        | Generate or use Unsplash
Icons            | NOT NEEDED      | Use lucide-react
Favicon          | OPTIONAL        | Generate from brand initial
OG images        | NOT NEEDED      | Generate dynamically with next/og
```
