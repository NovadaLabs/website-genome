# Genome Version & Dependency Pins

```spec
GENOME_VERSION:    1.0.0
LAST_VALIDATED:    2026-03-31
CREATED_BY:        Opus orchestrator + tongwu

PINNED DEPENDENCIES:
  next:                    16.x
  react:                   19.x
  react-dom:               19.x
  typescript:              5.x
  tailwindcss:             4.x
  shadcn (CLI):            2.x
  @clerk/nextjs:           7.x
  drizzle-orm:             0.40.x
  @neondatabase/serverless: 0.10.x
  @upstash/redis:          1.x
  react-hook-form:         7.x
  zod:                     3.x
  @hookform/resolvers:     4.x
  recharts:                2.x
  @tanstack/react-table:   8.x
  date-fns:                4.x
  lucide-react:            0.470.x
  next-themes:             0.4.x
  geist:                   1.x
  ai (AI SDK):             6.x
  @ai-sdk/react:           2.x
  stripe:                  17.x
  resend:                  4.x
  sonner:                  2.x

RUNTIME:
  node:                    22 LTS (>=22.0.0)
  pnpm:                    9.x (>=9.0.0)

DEPLOYMENT:
  vercel (CLI):            50.x
  vercel (platform):       latest (auto-managed)

SCAFFOLD COMMANDS (version-locked):
  npx create-next-app@16   (not @latest)
  npx shadcn@2 init -d     (not @latest)
  npx shadcn@2 add [comp]  (not @latest)

UPDATE POLICY:
  - Review this file monthly
  - Test scaffold commands before updating versions
  - Breaking changes: update genome files that reference changed APIs
  - Keep this file as the SINGLE SOURCE OF TRUTH for all version references
```
