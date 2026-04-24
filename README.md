# Agent Team Project

A multi-agent AI system built iteratively across three frameworks — Claude Code,
CrewAI, and LangGraph — to learn how each one works by building approximately the
same thing three times, in increasing complexity.

## The Idea

A "company team" of AI agents organized into departments, each with specialized
roles, that can collaborate on complex tasks: market research, competitive
analysis, business planning, GTM strategy, engineering work, financial analysis,
legal review, people operations, and more.

## Full Org Chart

```
┌──────────────────────────────────────────────────────────────────┐
│                    Top-Level Supervisor (CEO)                    │
│                  + Chief of Staff (cross-dept)                   │
└──────────────────────────────────────────────────────────────────┘
                                │
  ┌───────────┬──────────┬──────┴───────┬──────────┬────────────┐
  ▼           ▼          ▼              ▼          ▼            ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────────┐ ┌──────┐ ┌─────────┐
│Research│ │Product │ │Market- │ │Engineering │ │Sales │ │Customer │
│& Strat.│ │Data/UX │ │ing     │ │            │ │      │ │Success  │
└────────┘ └────────┘ └────────┘ └────────────┘ └──────┘ │(placeholder)
                                                          └─────────┘
  ┌──────────┬──────────┬─────────┬────────────┐
  ▼          ▼          ▼         ▼            ▼
┌────────┐ ┌────────┐ ┌──────┐ ┌──────┐ ┌────────────┐
│Finance │ │Legal   │ │People│ │  IT /  Corporate  Ops │
│        │ │        │ │/ HR  │ │                       │
└────────┘ └────────┘ └──────┘ └───────────────────────┘
```

## Departments

| # | Department | Status | Agents |
|---|---|---|---|
| 0 | **Executive** | Defined | Top-Level Supervisor, Chief of Staff |
| 1 | **Research & Strategy** | Defined | Supervisor, Market Researcher, Competitor Researcher, Competitive Analyst, GTM Analyst, Innovation Guru, Consultant |
| 2 | **Engineering** | Defined | Supervisor, Architect, Backend, Frontend, Mobile, DevOps/SRE, Security Engineer, QA, Code Reviewer, Technical Writer |
| 3 | **Product / Data / Design** | Defined | Supervisor, Product Manager, Product Researcher, Product Designer, Data Analyst, Data Scientist, Data Engineer, Product Strategist |
| 4 | **Marketing** | Defined | Supervisor, Product Marketer, Brand Manager, Content Strategist, Content Writer, Growth Marketer, SEO Specialist, PR/Comms, Marketing Analyst |
| 5 | **Sales** | Defined | Supervisor, Account Executive, SDR/BDR, Sales Engineer, Sales Ops, Partnerships Manager |
| 6 | **Customer Success** | Placeholder | (to be built in later phase) |
| 7 | **Finance** | Defined | Supervisor, FP&A Analyst, Accounting Manager, Treasury, Tax Specialist, Investor Relations, Finance Business Partner |
| 8 | **Legal** | Defined | Supervisor, Corporate Counsel, Commercial Counsel, IP Counsel, Privacy & Compliance Counsel, Employment Counsel, Litigation Counsel |
| 9 | **People / HR** | Defined | Supervisor, Recruiter, People Operations, Learning & Development, Total Rewards, Employee Relations, DEI/Culture |
| 10 | **IT / Corporate Operations** | Defined | Supervisor, Systems Administrator, Help Desk Lead, IT Security Manager, Business Systems Analyst, Workplace/Facilities |

**Total:** 11 departments (1 placeholder), 63 agent specifications.

## Architectural Patterns

- **Hierarchical supervisor pattern** — Top-Level Supervisor → Department
  Supervisors → Specialists. Each decision surface is 5–7 options max.
- **Researcher/Analyst split** — information gathering is separate from
  interpretation, to avoid premature anchoring.
- **Doer + Reviewer + Planner** — doer agents build, reviewer agents validate,
  planner/synthesizer agents structure or combine. Adapted per department.
- **Shared output directory** — agents communicate via files in `./outputs/`,
  not direct message passing, so runs are inspectable.
- **Escalation over hallucination** — every agent has explicit conditions
  where it should stop and flag rather than invent.

## Implementations

| Framework | Status | Notes |
|---|---|---|
| Claude Code (headless) | In Progress | Phase 1 — agent md files as specs (complete for 10 of 11 departments) |
| CrewAI | Not started | Phase 2 — Python crew definitions |
| LangGraph | Not started | Phase 3 — graph-based state machines |

## Quick Start

See `CLAUDE.md` for full context, run instructions, and architectural decisions.

To run an agent headlessly (example):

```bash
cd /path/to/agent-team/research-strategy
mkdir -p outputs/competitors

claude -p "Research Toast Inc. as a competitor..." \
  --system-prompt-file 03_competitor_researcher.md \
  --allowedTools "Read,Write,WebSearch,Bash" \
  --max-turns 20 \
  --dangerously-skip-permissions
```

## Project Structure

```
/agent-team
├── CLAUDE.md                          ← Claude Code context file
├── README.md                          ← this file
│
├── executive/                         ← Dept 0: Executive
│   ├── 00_executive_overview.md
│   ├── 01_top_level_supervisor.md
│   ├── 02_chief_of_staff.md
│   └── outputs/
│
├── research-strategy/                 ← Dept 1: Research & Strategy
│   ├── 00_department_overview.md
│   ├── 01–07_*.md                     (7 agents)
│   └── outputs/
│
├── engineering/                       ← Dept 2: Engineering
│   ├── 00_department_overview.md
│   ├── 01–10_*.md                     (10 agents)
│   └── outputs/
│
├── product/                           ← Dept 3: Product / Data / Design
│   ├── 00_department_overview.md
│   ├── 01–08_*.md                     (8 agents)
│   └── outputs/
│
├── marketing/                         ← Dept 4: Marketing
│   ├── 00_department_overview.md
│   ├── 01–09_*.md                     (9 agents)
│   └── outputs/
│
├── sales/                             ← Dept 5: Sales
│   ├── 00_department_overview.md
│   ├── 01–06_*.md                     (6 agents)
│   └── outputs/
│
├── customer-success/                  ← Dept 6: placeholder only
│   └── 00_department_overview.md
│
├── finance/                           ← Dept 7: Finance
│   ├── 00_department_overview.md
│   ├── 01–07_*.md                     (7 agents)
│   └── outputs/
│
├── legal/                             ← Dept 8: Legal
│   ├── 00_department_overview.md
│   ├── 01–07_*.md                     (7 agents)
│   └── outputs/
│
├── people/                            ← Dept 9: People / HR
│   ├── 00_department_overview.md
│   ├── 01–07_*.md                     (7 agents)
│   └── outputs/
│
├── it-corporate-ops/                  ← Dept 10: IT / Corporate Ops
│   ├── 00_department_overview.md
│   ├── 01–06_*.md                     (6 agents)
│   └── outputs/
│
├── runs/                              ← archived run outputs
├── crewai/                            ← Phase 2 implementation
└── langgraph/                         ← Phase 3 implementation
```

## Status

### Phase 1: Claude Code Headless
- [x] Research & Strategy department (7 agents) — tested with industry report run
- [x] Executive department (2 agents)
- [x] Engineering department (10 agents)
- [x] Product / Data / Design department (8 agents)
- [x] Marketing department (9 agents)
- [x] Sales department (6 agents)
- [x] Customer Success department (placeholder only)
- [x] Finance department (7 agents)
- [x] Legal department (7 agents)
- [x] People / HR department (7 agents)
- [x] IT / Corporate Operations department (6 agents)
- [ ] End-to-end orchestration script spanning multiple departments
- [ ] Customer Success agents (planned for later phase)

### Phase 2: CrewAI
- [ ] Environment setup
- [ ] Translate one department into a CrewAI crew
- [ ] Compare output quality against Phase 1

### Phase 3: LangGraph
- [ ] Environment setup
- [ ] Translate the crew into a LangGraph state machine
- [ ] Add supervisor routing and conditional edges
