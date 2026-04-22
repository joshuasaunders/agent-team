# Agent Team Project

A multi-agent AI system built iteratively across three frameworks — Claude Code,
CrewAI, and LangGraph — to learn how each one works by building approximately the
same thing three times, in increasing complexity.

## The Idea

A "company team" of AI agents organized into departments, each with specialized
roles, that can collaborate on complex tasks: market research, competitive analysis,
business planning, GTM strategy, and more.

## Departments

| Department | Status | Agents |
|---|---|---|
| Research & Strategy | ✅ Defined | Supervisor, Market Researcher, Competitor Researcher, Competitive Analyst, GTM Analyst, Innovation Guru, Consultant |
| Engineering | 🔲 Planned | TBD |
| Finance | 🔲 Planned | TBD |
| Marketing | 🔲 Planned | TBD |
| Product | 🔲 Planned | TBD |

## Implementations

| Framework | Status | Notes |
|---|---|---|
| Claude Code (headless) | 🔄 In Progress | Phase 1 — agent md files as specs |
| CrewAI | 🔲 Not started | Phase 2 — Python crew definitions |
| LangGraph | 🔲 Not started | Phase 3 — graph-based state machines |

## Quick Start

See `CLAUDE.md` for full context, run instructions, and architectural decisions.

## Project Structure

```
/agents
├── CLAUDE.md                    ← Claude Code reads this automatically
├── README.md                    ← this file
├── research-strategy/           ← Department 1
│   ├── 00_department_overview.md
│   ├── 01_research_strategy_supervisor.md
│   ├── 02_industry_market_researcher.md
│   ├── 03_competitor_researcher.md
│   ├── 04_competitive_analyst.md
│   ├── 05_gtm_analyst.md
│   ├── 06_innovation_guru.md
│   ├── 07_consultant.md
│   └── outputs/
├── runs/                        ← archived run outputs
├── crewai/                      ← Phase 2
└── langgraph/                   ← Phase 3
```
