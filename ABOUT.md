# Website Genome OS — What It Is and What It Can Do

**中英双语 · Bilingual**

---

## English

### What is Website Genome OS?

Website Genome OS is an agent operating system that replicates any website — from the public marketing pages down to every logged-in dashboard, settings panel, and interactive component — as a deployable Next.js project.

You give it a URL. It extracts everything. It builds a pixel-accurate replica. It ships.

The human does one thing: log into the target site in Chrome. The agent does the rest.

---

### What Can It Replicate?

Everything a browser can see, logged in or not:

| Surface | Can replicate? | Notes |
|---------|---------------|-------|
| Marketing pages (landing, pricing, about) | ✅ | Full content + layout |
| Blog / docs / legal pages | ✅ | Full article HTML |
| Auth pages (sign-in, sign-up, forgot password) | ✅ | Layout + form fields |
| Dashboard (overview, stats, charts) | ✅ | Requires your login session |
| Settings, billing, account pages | ✅ | Requires your login session |
| Mega-menus, dropdowns, modals | ✅ | Extracted as visual units |
| API-powered data (tables, charts, lists) | ✅ via proxy | Routes wired to original API or mock |
| Design tokens (colors, fonts, spacing) | ✅ | Extracted from computed CSS |
| Real images, fonts, icons | ✅ | Downloaded to /public |

---

### Real Results

The genome has been validated on three production sites:

**novada.com** — SaaS developer portal
- 84 routes replicated across 3 agent sessions
- Score: 85/100 on first complete run
- What was hard: 35+ dashboard sub-tabs, dynamic API tables, login-gated proxy config pages
- What the genome added: Chrome Step 0, dashboard-first rule, 8-dimension extraction

**iploop.io** — Proxy SaaS
- Single agent, first pass
- What was hard: multi-level sidebar navigation, product sub-pages
- What the genome added: completeness gates, "quality system not checklist" mindset

**brightdata.com** — Enterprise data platform
- Complex mega-menus, nested nav, large product catalog
- What was hard: mega-menus are visual components, not link lists
- What the genome added: component extraction protocol, side-by-side comparison rule

Each failure on a real site became a rule in the genome. Every line exists because an agent failed without it.

---

### How Accurate Is 99%?

99% means: every page exists, every nav link works, every interactive element responds, every image is a real downloaded file — not a placeholder.

The 1% gap is typically: real-time data that only renders from a live API (e.g. live usage charts), or auth flows that require actual account creation.

What 99% does NOT mean: pixel-perfect to 0.1px. It means: a user visiting the replica cannot tell it apart from the original in normal use.

---

### How It Works — The 5-Step Pipeline

```
STEP 0: Chrome setup (1 human action)
  Run: cd ~/Projects/novada-replicate && npm run launch-chrome
  Agent connects to your Chrome with all your login sessions.

STEP 1: Connect + detect
  Agent opens the target site. Detects framework (Next.js/React),
  CSS system (Tailwind/Bootstrap), auth provider (Clerk/Auth0), analytics.

STEP 2: Discover all pages
  site-crawler maps every public URL automatically.
  existing-chrome navigates every auth-gated page via your Chrome session.
  Output: specs/sitemap.json — the complete route map.

STEP 3: Extract — 8 dimensions per page
  Every page is captured across 8 dimensions:
  1. Structure (full HTML DOM)
  2. Style (computed CSS + design tokens)
  3. Assets (all images, fonts, SVGs downloaded)
  4. Content (verbatim text, numbers, tables)
  5. Behavior (every click documented — tabs, dropdowns, forms, modals)
  6. State (every possible page state: tabs, empty/filled forms, auth states)
  7. Network (every API call captured — URL, method, request, response)
  8. Metadata (title, OG tags, JSON-LD)

  Mechanical gate: verify-extraction.sh checks all 8 dimensions exist.
  If any dimension is missing → build is physically blocked.

STEP 4: Build
  Next.js 16 + shadcn/ui + Tailwind 4 + Geist.
  Every text string comes from extraction. Every image is a downloaded file.
  Zero invented content.

STEP 5: Verify → Reflect → Act
  Automated: verify-build.sh checks routes, links, images, placeholders.
  Manual: fresh agent compares original and replica side by side.
  Loop max 3 times until all gates pass.
  Then: deploy to Vercel.
```

---

### Why It Works Better Than Alternatives

**vs. manual coding:** An agent following the genome extracts 8 dimensions per page systematically. A human developer eyeballing a site guesses at spacing, misses hidden states, and ignores API call structures.

**vs. prompt-only agents:** An agent without the genome starts coding immediately. It invents content, ignores the dashboard, misses sub-tabs, and delivers a wireframe. The genome forces extraction-first discipline.

**vs. screenshot-based tools:** Screenshots capture what a page looks like at one moment. The genome captures HTML, CSS, interactive states, API calls, and assets — everything needed to rebuild it, not just display it.

---

### The Core Insight

> Replication quality = extraction quality.
>
> If you extract 100% of a page's data, building it is mechanical — a code transformation problem.
> If you extract 70%, you guess the other 30%, and the human catches every gap.
>
> Every replication failure in our history traces to incomplete extraction, not bad code.

This is why the genome spends 70% of its process on extraction and 30% on build.

---
---

## 中文

### 什么是 Website Genome OS？

Website Genome OS 是一个 Agent 操作系统，能复刻任何网站——从公开的营销页面，到所有需要登录才能看到的 Dashboard、设置页、交互组件——最终输出一个可部署的 Next.js 项目。

给它一个 URL，它提取所有内容，构建像素级精准的复刻版本，然后部署上线。

人类只需做一件事：在 Chrome 里登录目标网站。剩下的由 Agent 完成。

---

### 能复刻什么？

浏览器能看到的一切，无论是否需要登录：

| 页面类型 | 是否支持 | 备注 |
|---------|---------|------|
| 营销页（首页、定价、关于） | ✅ | 完整内容 + 布局 |
| 博客 / 文档 / 法律页面 | ✅ | 完整文章 HTML |
| 认证页（登录、注册、找回密码） | ✅ | 布局 + 表单字段 |
| Dashboard（概览、统计、图表） | ✅ | 需要你的登录 session |
| 设置、账单、账户页面 | ✅ | 需要你的登录 session |
| 大型菜单、下拉框、模态弹窗 | ✅ | 作为视觉组件整体提取 |
| API 驱动的数据（表格、图表、列表） | ✅ via proxy | 路由接入真实 API 或 mock |
| 设计 token（颜色、字体、间距） | ✅ | 从 computed CSS 提取 |
| 真实图片、字体、图标 | ✅ | 下载到 /public 目录 |

---

### 真实案例数据

Genome 已在三个生产环境网站上得到验证：

**novada.com** — SaaS 开发者门户
- 84 个路由，3 个 Agent session 完成复刻
- 得分：第一次完整运行 85/100
- 难点：35+ Dashboard 子标签页、动态 API 表格、登录后才能看到的代理配置页
- 因此新增：Chrome Step 0、Dashboard 优先规则、8 维度提取框架

**iploop.io** — 代理 SaaS
- 单个 Agent，一次通过
- 难点：多层侧边栏导航、产品子页面
- 因此新增：完整性关卡、"质量系统而非清单"的工作方式

**brightdata.com** — 企业数据平台
- 复杂大型菜单、嵌套导航、大型产品目录
- 难点：大型菜单是视觉组件，不是链接列表
- 因此新增：组件提取协议、并排对比规则

每一次真实网站上的失败，都变成了 Genome 里的一条规则。每一行代码都是因为 Agent 没有它就失败了。

---

### 99% 准确度是什么意思？

99% 的意思是：每个页面都存在，每个导航链接都能跳转，每个交互元素都有响应，每张图片都是真实下载的文件——而不是占位符。

剩余 1% 的差距通常是：仅从真实 API 渲染的实时数据（例如实时使用量图表），或需要真实账号才能完成的认证流程。

99% **不是**指像素精度到 0.1px。它的意思是：普通用户访问复刻版时，在正常使用中无法分辨真假。

---

### 工作原理 — 5 步流水线

```
第 0 步：Chrome 准备（人类唯一的操作）
  运行：cd ~/Projects/novada-replicate && npm run launch-chrome
  Agent 连接到你的 Chrome，获取所有登录 session。

第 1 步：连接 + 检测技术栈
  Agent 打开目标网站，检测框架（Next.js/React）、
  CSS 系统（Tailwind/Bootstrap）、Auth 服务（Clerk/Auth0）、Analytics。

第 2 步：发现所有页面
  site-crawler 自动爬取所有公开 URL。
  existing-chrome 通过你的 Chrome session 导航到所有需要登录的页面。
  输出：specs/sitemap.json — 完整路由地图。

第 3 步：提取 — 每个页面 8 个维度
  每个页面从 8 个维度完整采集：
  1. 结构（完整 HTML DOM）
  2. 样式（computed CSS + 设计 token）
  3. 资产（所有图片、字体、SVG 下载到本地）
  4. 内容（原文文字、数字、表格）
  5. 行为（记录每次点击的结果：标签页、下拉框、表单、模态框）
  6. 状态（每种页面状态：标签切换、表单空/填写/错误/成功、Auth 状态）
  7. 网络（捕获每个 API 请求：URL、方法、请求体、响应）
  8. 元数据（title、OG tags、JSON-LD）

  机械关卡：verify-extraction.sh 检查 8 个维度是否都存在。
  任何维度缺失 → 构建被物理阻断，无法跳过。

第 4 步：构建
  Next.js 16 + shadcn/ui + Tailwind 4 + Geist。
  每一段文字来自提取数据。每张图片是下载的真实文件。
  零 AI 生成内容。

第 5 步：验证 → 反思 → 修复
  自动化：verify-build.sh 检查路由、链接、图片、占位符。
  人工：全新 Agent 并排比对原站和复刻版。
  最多循环 3 次，直到所有关卡通过。
  然后：部署到 Vercel。
```

---

### 为什么比其他方法更好？

**对比手动开发：** 按 Genome 工作的 Agent 会系统性地对每个页面提取 8 个维度。人类开发者靠眼睛估算间距，会漏掉隐藏状态，会忽略 API 调用结构。

**对比纯提示词 Agent：** 没有 Genome 约束的 Agent 会立刻开始写代码。它会凭空生成内容，忽略 Dashboard，漏掉子标签页，最终交付一个线框图。Genome 强制先提取，再构建。

**对比截图工具：** 截图只能捕捉某一时刻的视觉外观。Genome 捕捉 HTML、CSS、交互状态、API 调用和资产——复建所需的一切，而不只是显示。

---

### 核心洞察

> 复刻质量 = 提取质量。
>
> 如果你提取了一个页面 100% 的数据，构建它就是机械的——纯代码转化问题。
> 如果你只提取了 70%，你要猜测剩下的 30%，人类会发现每一处差距。
>
> 我们历史上所有的复刻失败，都源于提取不完整，而不是代码写错了。

这就是为什么 Genome 把 70% 的流程放在提取上，30% 放在构建上。
