# 10 — Agent-Browsable Specification

## PURPOSE

```spec
UNIQUE REQUIREMENT: Websites built by this genome are agent-first.
Agents interact with websites through the accessibility tree and DOM, not pixels.
This file specifies how to make a website optimally consumable by AI agents.
Human browsing is a SECONDARY concern (still important, but secondary).
```

---

## 10.1 SEMANTIC DATA ATTRIBUTES

```spec
PURPOSE: Give agents machine-readable handles for every interactive element
CONVENTION: data-agent-* namespace

REQUIRED ATTRIBUTES:
  data-agent-action="<action-type>"
    Values: navigate, submit, toggle, open, close, delete, edit, create,
            filter, sort, search, paginate, upload, download, copy, expand
    Applied to: every clickable/interactive element

  data-agent-target="<destination>"
    Values: page path, modal name, section id
    Applied to: navigation elements, trigger buttons

  data-agent-resource="<resource-type>"
    Values: user, project, order, article, product, etc.
    Applied to: CRUD-related elements

  data-agent-id="<unique-id>"
    Values: database ID or unique identifier
    Applied to: elements representing specific entities

  data-agent-role="<ui-role>"
    Values: primary-nav, breadcrumb, search, filter, pagination,
            sort-control, bulk-action, row-action, form, sidebar-nav
    Applied to: structural UI elements

EXAMPLES:
  // Navigation
  <Link href="/dashboard" data-agent-action="navigate" data-agent-target="/dashboard"
    data-agent-role="primary-nav">
    Dashboard
  </Link>

  // CRUD button
  <Button data-agent-action="create" data-agent-resource="project"
    data-agent-target="create-project-dialog">
    New Project
  </Button>

  // Table row
  <TableRow data-agent-resource="project" data-agent-id={project.id}>
    <TableCell>{project.name}</TableCell>
  </TableRow>

  // Delete action
  <DropdownMenuItem data-agent-action="delete" data-agent-resource="project"
    data-agent-id={project.id}>
    Delete
  </DropdownMenuItem>

  // Search
  <Input data-agent-role="search" data-agent-action="search"
    data-agent-resource="project" />

  // Pagination
  <Button data-agent-action="paginate" data-agent-target="next">Next</Button>
```

## 10.2 JSON-LD STRUCTURED DATA

```spec
PURPOSE: Machine-readable page semantics (schema.org vocabulary)
IMPLEMENTATION: script tag in page head

EVERY PAGE TYPE:
  Landing page:       Organization + WebSite (with SearchAction)
  Product page:       Product (price, availability, reviews)
  Article/blog:       Article (author, datePublished, headline)
  FAQ page:           FAQPage (question/answer pairs)
  Pricing page:       SoftwareApplication + Offer[]
  Profile:            Person or Organization
  Search results:     SearchResultsPage
  Breadcrumbs:        BreadcrumbList (on every page with breadcrumbs)

IMPLEMENTATION PATTERN:
  // lib/json-ld.ts
  export function organizationJsonLd(brand: string, url: string, logo: string) {
    return {
      "@context": "https://schema.org",
      "@type": "Organization",
      "name": brand,
      "url": url,
      "logo": logo,
    }
  }

  export function articleJsonLd(article: Article) {
    return {
      "@context": "https://schema.org",
      "@type": "Article",
      "headline": article.title,
      "author": { "@type": "Person", "name": article.author },
      "datePublished": article.publishedAt,
      "dateModified": article.updatedAt,
      "image": article.coverImage,
      "publisher": { "@type": "Organization", "name": "Brand" },
    }
  }

  export function breadcrumbJsonLd(items: { name: string; url: string }[]) {
    return {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      "itemListElement": items.map((item, i) => ({
        "@type": "ListItem",
        "position": i + 1,
        "name": item.name,
        "item": item.url,
      })),
    }
  }
```

## 10.3 API ENDPOINTS MIRRORING PAGES

```spec
PURPOSE: Every page that displays data should have an API endpoint returning the same data
WHY: Agents can fetch data without rendering the page (headless access)

PATTERN:
  PAGE                    → API ENDPOINT
  /dashboard              → GET /api/dashboard (stats, recent items)
  /dashboard/projects     → GET /api/projects?page=1&sort=created
  /dashboard/projects/123 → GET /api/projects/123
  /settings               → GET /api/settings
  /blog                   → GET /api/posts?page=1
  /blog/my-post           → GET /api/posts/my-post

API RESPONSE FORMAT (consistent across all endpoints):
  {
    "data": { ... } | [...],           // the actual data
    "meta": {
      "page": 1,                       // current page (if paginated)
      "totalPages": 10,                // total pages
      "totalItems": 100,               // total count
      "resource": "project",           // resource type
      "actions": ["create", "update", "delete"]  // available actions
    },
    "links": {
      "self": "/api/projects?page=1",
      "next": "/api/projects?page=2",
      "prev": null,
    }
  }

DISCOVERY ENDPOINT:
  GET /api → returns available resources and their endpoints
  {
    "resources": {
      "projects": { "url": "/api/projects", "actions": ["list", "get", "create", "update", "delete"] },
      "users": { "url": "/api/users", "actions": ["list", "get"] },
      ...
    }
  }
```

## 10.4 ACCESSIBILITY TREE AS PRIMARY INTERFACE

```spec
PURPOSE: Agents use the accessibility tree, not CSS/visual layout
WHY: The a11y tree is the most reliable machine-readable representation

RULES:
  1. Every interactive element MUST have an accessible name
     (text content, aria-label, or aria-labelledby)
  2. Every section MUST have a heading (h1-h6) or aria-label
  3. Navigation landmarks MUST be labeled:
     <nav aria-label="Main navigation">
     <nav aria-label="Footer links">
     <aside aria-label="Sidebar">
  4. Form controls MUST have labels
  5. Tables MUST have <thead> with <th> elements
  6. Dynamic content changes MUST use aria-live regions
  7. Meaningful icons MUST have aria-label on their container

TESTING: Run Lighthouse accessibility audit (score >= 90)
```

## 10.5 MCP SERVER ENDPOINT

```spec
PURPOSE: Allow agents to connect to the website via MCP protocol [C — advanced]
WHEN: When the website IS a tool/service that agents should interact with

IMPLEMENTATION:
  // app/api/mcp/route.ts
  // Expose site functionality as MCP tools
  // Agents can: mcp add https://your-site.com/api/mcp

  Tools to expose:
    - search: search site content
    - get_page: get structured data for a specific page
    - list_resources: list available resources
    - create/update/delete: CRUD operations (with auth)

  ⚠️ This is OPTIONAL and only for sites that ARE agent tools.
  Most websites just need data-agent-* attributes and API endpoints.
```

## 10.6 AGENT-FRIENDLY CONTENT PATTERNS

```spec
TEXT CONTENT:
  - Use clear, unambiguous language
  - Structure content hierarchically (headings → paragraphs)
  - Avoid idioms, metaphors, and sarcasm in UI text
  - Use consistent terminology (don't mix "delete"/"remove"/"trash")
  - Include units and context for numbers ("$29/month" not just "29")

DATA DISPLAY:
  - Tables with proper headers (agents parse headers to understand columns)
  - Lists with consistent structure
  - Status badges with text (not just color): "Active" not just a green dot
  - Dates in ISO 8601 format in data attributes: data-date="2026-03-30"
  - Numbers with proper formatting: data-value="1234.56" (raw value for parsing)

NAVIGATION:
  - Descriptive link text ("View project settings" not "Click here")
  - Breadcrumbs on every interior page (agents use these to understand hierarchy)
  - Consistent menu structure across pages
  - Unique page titles (agents use these to identify pages)

FORMS:
  - Every field has a visible label
  - Validation errors are specific ("Email must include @" not "Invalid input")
  - Required fields explicitly marked
  - Form submit success/error clearly indicated in DOM (not just toast)
```

## IMPLEMENTATION CHECKLIST

```spec
☐ data-agent-* attributes on all interactive elements
☐ JSON-LD structured data on all public pages
☐ API endpoints mirror all data-displaying pages
☐ API discovery endpoint at /api
☐ All elements have accessible names
☐ All sections have headings or aria-labels
☐ Navigation landmarks labeled
☐ Status conveyed via text (not just color/icon)
☐ Dates have data-date attribute (ISO 8601)
☐ Numbers have data-value attribute (raw number)
☐ Consistent terminology across UI
☐ Descriptive link text (no "click here")
☐ Breadcrumbs on interior pages
☐ Form errors specific and in DOM
☐ Lighthouse accessibility >= 90
```
