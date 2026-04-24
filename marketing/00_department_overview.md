# Marketing Department — Overview

## Purpose
This department owns how the company talks about itself and its products, how it
reaches prospective customers, and how it measures whether the marketing investment
is working. It covers product marketing, brand, content, growth/performance, SEO,
PR and communications, and marketing analytics.

When the Top-Level Supervisor receives a request involving positioning, messaging,
launch planning, content creation, SEO, paid acquisition, PR, executive comms, or
marketing measurement, it delegates to this department.

## Hierarchy

```
[Top-Level Supervisor]
        |
        v
[Marketing Supervisor]  <-- CMO, orchestrates all agents below
        |
        |-----> [Product Marketer]        -- positioning, messaging, launches
        |-----> [Brand Manager]           -- brand voice, visual identity, guidelines
        |-----> [Content Strategist]      -- editorial strategy, content calendar
        |-----> [Content Writer]          -- blog posts, long-form, copy (doer)
        |-----> [Growth Marketer]         -- paid, lifecycle, performance
        |-----> [SEO Specialist]          -- technical + content SEO
        |-----> [PR & Communications]     -- press, analyst relations, exec comms
        |-----> [Marketing Analyst]       -- attribution, ROI, synthesizer
```

## Typical Activation Sequences

**Product launch:**
Product Marketer (positioning + messaging) → Brand Manager (fit to brand) → Content
Strategist (launch content plan) → Content Writer (create assets) + PR (announce)
+ Growth Marketer (acquisition campaign) → Marketing Analyst (measure launch impact)

**Content campaign:**
Content Strategist (plan) → Content Writer (execute) → SEO Specialist (optimization)
→ Growth Marketer (distribution) → Marketing Analyst (results)

**Brand or messaging audit:**
Brand Manager (brand diagnostic) → Product Marketer (message diagnostic) →
Marketing Analyst (synthesis) → Marketing Supervisor recommendation

**Channel performance issue:**
Growth Marketer (channel diagnostic) → Marketing Analyst (attribution check) →
Marketing Supervisor decision on reallocation

## Shared Output Directory
All agents write to `./outputs/` with these subdirectories:
- `positioning/` — positioning docs, messaging frameworks, battlecards
- `brand/` — brand guidelines, voice and tone docs, visual system references
- `content/` — content plans, briefs, drafts, published content references
- `growth/` — campaign plans, creative, channel performance, experiments
- `seo/` — keyword strategy, technical SEO audits, content optimization
- `pr/` — press releases, pitch memos, analyst briefings, exec comms drafts
- `analytics/` — attribution, funnel, campaign measurement, synthesis

## Output Format Default
- Narrative docs (positioning, content briefs, PR drafts): markdown (.md)
- Campaign and content plans: markdown with linked specs
- Creative and visual assets: links to design files plus exported previews
- Analytics: markdown reports with linked dashboards/queries

## Inter-Agent Communication Rules
1. All coordination goes through the Marketing Supervisor.
2. The Product Marketer owns positioning and messaging. The Brand Manager owns voice
   and visual identity. The Content Writer writes against both — they do not re-invent
   either in individual pieces.
3. The SEO Specialist reviews content for SEO before publish, not after. Post-hoc SEO
   on already-published content is remediation, not strategy.
4. The Marketing Analyst is activated for cross-channel synthesis or for specific
   measurement questions. Not every campaign needs the analyst; most need their work
   reviewed in aggregate at a cadence.
