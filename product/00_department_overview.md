# Product Department — Overview

## Purpose
This department owns **what to build**, **who for**, **how it should look and feel**,
and **how we know it is working**. It combines three disciplines that in many
organizations are separated (Product Management, Design/UX, and Data/Analytics) because
for most requests these disciplines must reason together: you cannot decide what to
build without understanding who the user is, what their workflow looks like, and what
the data says about current behavior.

When the Top-Level Supervisor receives a request involving feature prioritization, user
research, product design, UX flows, product metrics, A/B test analysis, predictive
modeling, or data pipeline work, it delegates to this department.

## Hierarchy

```
[Top-Level Supervisor]
        |
        v
[Product Supervisor]  <-- CPO-equivalent, orchestrates all agents below
        |
        |-----> [Product Manager]          -- roadmap, PRDs, prioritization
        |-----> [Product Researcher]       -- qualitative user research, usability
        |-----> [Product Designer]         -- UX flows, UI, interaction design, visual
        |-----> [Data Analyst]             -- product metrics, dashboards, A/B analysis
        |-----> [Data Scientist]           -- modeling, forecasting, experimentation
        |-----> [Data Engineer]            -- data pipelines, warehouse, instrumentation
        |-----> [Product Strategist]       -- synthesizer — cross-discipline recs
```

## Typical Activation Sequences

**Roadmap prioritization:**
Data Analyst (current state) + Product Researcher (user input) → Product Manager (proposes prioritization)
→ Product Strategist (synthesis) → Product Supervisor sign-off

**New feature design:**
Product Manager (PRD) → Product Researcher (discovery) → Product Designer (flows + UI)
→ Data Analyst (metric definition) → back to Product Manager for spec finalization

**A/B test analysis:**
Data Analyst (primary) → Data Scientist (significance, lift decomposition) → Product
Manager (decision recommendation)

**Data pipeline / instrumentation work:**
Data Engineer (primary) → Data Analyst (verification the pipeline produces what the
metrics need) → Product Manager (confirm the downstream use case is met)

**Full product strategy question (e.g., "should we build X?"):**
Product Researcher + Data Analyst (parallel) → Product Manager → Product Designer
(feasibility sketch) → Data Scientist (projection) → Product Strategist (synthesis)

## Shared Output Directory
All agents write to `./outputs/` with these subdirectories:
- `roadmaps/` — prioritization, roadmap artifacts, PRDs
- `research/` — user research findings, usability studies, personas
- `designs/` — wireframes, flows, visual designs, design systems
- `analytics/` — dashboards, A/B test analyses, metric definitions
- `models/` — data science artifacts, model performance, forecasts
- `pipelines/` — data pipeline documentation, schema docs, instrumentation specs
- `strategy/` — synthesized cross-discipline product recommendations

## Output Format Default
- PRDs, research reports, strategy docs: markdown (.md)
- Dashboards and A/B test analyses: markdown with linked visualizations
- Design artifacts: links to design files (Figma, Sketch) plus exported frames
- Data models and pipelines: code (SQL, Python, dbt) plus markdown documentation

## Inter-Agent Communication Rules
1. All coordination goes through the Product Supervisor. Specialists do not assign
   each other work.
2. The Product Researcher and Data Analyst inform the Product Manager — they do not
   produce roadmap decisions themselves.
3. The Product Designer is activated after the Product Manager has produced at least a
   rough PRD and the Product Researcher has shared relevant user context. Designing
   before the problem is defined produces polished designs for the wrong problem.
4. The Product Strategist synthesizes across multiple specialist outputs when
   recommendations require integrating qualitative research, quantitative data, and
   design constraints. Not every task needs the Strategist.
