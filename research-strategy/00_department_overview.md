# Research & Strategy Department — Overview

## Purpose
This department handles all market intelligence, competitive analysis, go-to-market strategy,
and innovation thinking. When the top-level supervisor receives a request involving industry
research, competitor analysis, strategic planning, or opportunity identification, it delegates
to this department.

## Hierarchy

```
[Top-Level Supervisor]
        |
        v
[Research & Strategy Supervisor]  <-- department head, orchestrates all agents below
        |
        |-----> [Industry & Market Researcher]   -- gathers macro market data
        |-----> [Competitor Researcher]          -- gathers raw competitor data
        |-----> [Competitive Analyst]            -- interprets competitor data, SWOTs
        |-----> [GTM Analyst]                   -- develops go-to-market strategy
        |-----> [Innovation Guru]               -- identifies disruption opportunities
        |-----> [Consultant]                    -- synthesizes everything into recommendations
```

## Typical Activation Sequences

**Quick competitive scan:**
Competitor Researcher → Competitive Analyst → Consultant

**Market entry analysis:**
Industry Researcher + Competitor Researcher (run in parallel) → Competitive Analyst
→ GTM Analyst → Consultant

**Full strategic analysis:**
Industry Researcher + Competitor Researcher (run in parallel) → Competitive Analyst
→ GTM Analyst → Innovation Guru → Consultant

## Shared Output Directory
All agents write their outputs to a shared folder so downstream agents can find them.
Default location: `./outputs/`

## Output Format Default
Unless otherwise specified in the incoming task, all outputs default to markdown (.md).
Structured data outputs (tables, matrices) default to CSV.

## Inter-Agent Communication Rules
1. Agents do not communicate directly with each other — all coordination goes through
   the Research & Strategy Supervisor.
2. Agents must flag data gaps or quality issues to the supervisor rather than
   making assumptions to fill them.
3. The Consultant is always the last agent activated — it synthesizes, it does not research.
4. The Research & Strategy Supervisor reviews all outputs before passing them downstream.
