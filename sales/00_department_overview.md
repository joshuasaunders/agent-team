# Sales Department — Overview

## Purpose
This department owns revenue generation. It finds, qualifies, and closes customers;
runs the technical sales motion for complex deals; manages the pipeline and
forecast; enables the field with playbooks and training; and develops channel and
alliance partnerships.

When the Top-Level Supervisor receives a request involving prospecting, deal
strategy, pipeline analysis, sales enablement, forecasting, partnerships, or
customer evidence development for sales purposes, it delegates to this department.

## Hierarchy

```
[Top-Level Supervisor]
        |
        v
[Sales Supervisor]  <-- CRO / VP Sales, orchestrates all agents below
        |
        |-----> [Account Executive]        -- full-cycle deal owner (closer)
        |-----> [SDR / BDR]                -- prospecting and qualification
        |-----> [Sales Engineer]           -- technical sales, demos, RFPs
        |-----> [Sales Operations]         -- pipeline, forecast, enablement, tools
        |-----> [Partnerships Manager]     -- channel, alliances, co-sell
```

## Typical Activation Sequences

**New opportunity pursuit:**
SDR (qualify) → Account Executive (discover + propose) → Sales Engineer (technical
fit + demo) → Account Executive (negotiate + close) → Sales Ops (handoff + record)

**Pipeline review:**
Sales Ops (pull pipeline) → Account Executive(s) (deal updates) → Sales Supervisor
(forecast call + risk triage)

**RFP / enterprise deal:**
Account Executive (deal strategy) → Sales Engineer (technical response) + Partnerships
(if partner motion) → Sales Ops (pricing desk, approvals) → Sales Supervisor (final
review)

**Sales enablement update (e.g., new product launch):**
Sales Ops (enablement plan) + Account Executive (field feedback) → Sales Ops
(materials produced) → Sales Supervisor (training delivery)

**Partner motion:**
Partnerships Manager (partner fit) → Account Executive (joint account plan) → Sales
Engineer (technical integration) → Partnerships Manager (co-sell execution)

## Shared Output Directory
All agents write to `./outputs/` with these subdirectories:
- `deals/` — deal strategies, close plans, competitive intel per opportunity
- `prospecting/` — outbound sequences, ICP lists, qualification notes
- `technical/` — demos, POC plans, RFP responses, reference architectures
- `ops/` — pipeline reports, forecasts, enablement materials, territory plans
- `partnerships/` — partner plans, co-sell motions, partner-sourced pipeline

## Output Format Default
- Deal plans, prospecting sequences, enablement docs: markdown (.md)
- Pipeline and forecast reports: markdown with linked CRM queries and dashboards
- Customer-facing materials (proposals, decks): linked from the project's source
  of truth (CRM, deck tool), not duplicated in agent outputs

## Inter-Agent Communication Rules
1. All coordination goes through the Sales Supervisor.
2. The Account Executive is the single point of ownership for an opportunity once
   it is handed off from the SDR. Other specialists support the AE; they do not
   own the deal.
3. Pipeline and forecast numbers come from Sales Ops. Individual deal estimates
   come from AEs. The two roll up, they do not compete.
4. Sales Engineer involvement is scoped before a deal — not every deal requires
   technical sales. Over-engaging the SE team is how technical sales capacity
   becomes the bottleneck.
5. Partnerships Manager activates Partner motion; AEs do not route deals through
   partners without coordination, and partners do not bypass AEs to sell direct.
