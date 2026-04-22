# Agent Team Project — Claude Code Context

## What This Project Is
A multi-agent AI system built iteratively across three frameworks:
1. **Claude Code (headless)** — the first implementation, using md files as agent specs
2. **CrewAI** — the second implementation, translating md specs into Python crew definitions
3. **LangGraph** — the third implementation, translating CrewAI experience into graph-based agents

The goal is to build a reusable "company team" of AI agents organized into departments,
each with specialized roles that can collaborate on complex tasks like business analysis,
market research, content creation, and strategic planning.

---

## Project Owner Context
- Name: Josh
- Background: Hospitality tech founder (Uncorkd, Backbar — acquired by VIP in 2023),
  now GM & Product Owner at VIP (Vermont Information Processing), based in Chicago
- Technical level: Comfortable with coding but not a developer. Can follow instructions,
  run CLI commands, and understand code with explanation. Has used Claude Code as a coding
  assistant but is new to using it as an agent runtime.
- Goal: Learn multi-agent systems by building the same thing three ways, in increasing
  complexity. Start with Claude Code headless, then CrewAI, then LangGraph.

---

## Project Structure

```
/agents
├── CLAUDE.md                          ← this file (Claude Code reads automatically)
├── README.md                          ← human-readable project overview
│
├── research-strategy/                 ← Department 1: Research & Strategy
│   ├── 00_department_overview.md
│   ├── 01_research_strategy_supervisor.md
│   ├── 02_industry_market_researcher.md
│   ├── 03_competitor_researcher.md
│   ├── 04_competitive_analyst.md
│   ├── 05_gtm_analyst.md
│   ├── 06_innovation_guru.md
│   ├── 07_consultant.md
│   └── outputs/                       ← agents write their work here
│       ├── competitors/
│       ├── analysis/
│       ├── gtm/
│       ├── innovation/
│       └── synthesis/
│
├── [future departments go here]
│   ├── engineering/
│   ├── finance/
│   ├── marketing/
│   └── product/
│
├── runs/                              ← logs of actual agent runs
│   └── YYYY-MM-DD_task-name/
│       ├── run_log.md
│       └── [agent outputs copied here for archiving]
│
├── crewai/                            ← Phase 2: CrewAI implementation
│   ├── requirements.txt
│   ├── research_strategy_crew.py
│   └── README.md
│
└── langgraph/                         ← Phase 3: LangGraph implementation
    ├── requirements.txt
    ├── research_strategy_graph.py
    └── README.md
```

---

## Agent Spec Format
Every agent md file follows this standard structure. Do not deviate from it when
creating new agents — consistency is what makes them translatable across frameworks.

```
# Agent: [Name]

## Identity
- Role, Department, Reports To, Manages

## Goal
What this agent is trying to achieve. Written as an outcome, not a task list.

## Backstory
Narrative persona — experience, personality, working style, known strengths.
This is what makes LLM outputs more specific and higher quality.

## Capabilities
Bulleted list of what this agent can do. Maps to CrewAI task types.

## Tools
What tools the agent has access to (web_search, read_file, write_file, etc.)

## Inputs
What the agent receives when activated. Specify required vs. optional.
Include the variable name, type, and description.

## Outputs
What the agent produces and where it writes it.
Be specific about filenames, formats, and directory paths.

## Workflow
Numbered step-by-step process the agent follows.
This becomes the task description in CrewAI and the node logic in LangGraph.

## Collaboration Protocol
Who activates this agent, whose outputs it consumes, who consumes its outputs.
This is the wiring diagram for the multi-agent system.

## Escalation Rules
Specific conditions where the agent should stop and flag rather than proceed.
This prevents hallucination and runaway behavior.
```

---

## Architectural Decisions (rationale recorded here)

**Hierarchical supervisor pattern**: The team uses a layered hierarchy — a top-level
supervisor delegates to department supervisors, who delegate to specialists. This keeps
any single agent's decision surface to 5-7 options max, which improves routing quality
and prevents context window bloat.

**Researcher/Analyst split**: Agents that gather information are separate from agents
that interpret it. Mixing research and analysis in one agent produces lower quality
outputs because the model anchors on early findings before the research is complete.

**Shared output directory**: Agents communicate via files in a shared `./outputs/`
directory rather than direct message passing. This makes the system debuggable — you
can inspect exactly what each agent produced at each stage.

**Consultant is last**: The Consultant/synthesizer always runs after all research and
analysis is complete. It has no web search tool. Its only input is other agents' outputs.
Activating it early produces synthesis without a complete evidence base.

**Escalation over hallucination**: Every agent has explicit escalation rules — conditions
where it should stop and flag rather than invent an answer. This is more important than
any other quality control mechanism.

---

## Current Status

### Phase 1: Claude Code Headless (IN PROGRESS)
- [x] Department overview and hierarchy designed
- [x] Research & Strategy department: all 7 agent md files complete
- [ ] First headless test run against a real company (Toast Inc. suggested)
- [ ] Debrief and refine agent specs based on test run
- [ ] Add remaining departments (Engineering, Finance, Marketing, Product)
- [ ] Build orchestration script to run multiple agents in sequence

### Phase 2: CrewAI (NOT STARTED)
- [ ] Install CrewAI and set up Python environment
- [ ] Translate Research & Strategy agents into CrewAI crew definition
- [ ] Test against same task as Phase 1 for comparison
- [ ] Add tool integrations (web search, file write)

### Phase 3: LangGraph (NOT STARTED)
- [ ] Install LangGraph and set up Python environment
- [ ] Translate CrewAI crew into LangGraph state graph
- [ ] Add conditional edges and supervisor routing logic
- [ ] Test against same task for comparison

---

## How to Run an Agent Headlessly (Phase 1)

### Prerequisites
- Claude Code CLI installed (`npm install -g @anthropic-ai/claude-code`)
- `ANTHROPIC_API_KEY` set as environment variable
- Output directories created before running

### Basic command structure
```bash
claude -p "[TASK DESCRIPTION]" \
  --system-prompt-file [AGENT_MD_FILE] \
  --allowedTools "Read,Write,WebSearch,Bash" \
  --max-turns 20 \
  --dangerously-skip-permissions
```

### Example: Run the Competitor Researcher
```bash
cd /path/to/agents/research-strategy
mkdir -p outputs/competitors

claude -p \
  "Research [COMPANY NAME] as a competitor.

  Company context: [BRIEF DESCRIPTION OF THE CLIENT COMPANY]

  Research depth: deep
  Specific focus areas: [ANY SPECIFIC ANGLES]

  Write your findings to:
  - ./outputs/competitors/[company]_profile.md
  - ./outputs/competitors/research_gaps.md" \
  --system-prompt-file 03_competitor_researcher.md \
  --allowedTools "Read,Write,WebSearch,Bash" \
  --max-turns 20 \
  --dangerously-skip-permissions
```

### After a run
- Review outputs in `./outputs/` directory
- Copy outputs to `./runs/YYYY-MM-DD_task-name/` for archiving
- Note any quality issues or gaps in `./runs/YYYY-MM-DD_task-name/run_log.md`
- Use observations to refine agent md files before next run

---

## Key Decisions Still To Make
- How to build the orchestration script that runs multiple agents in sequence
- Whether the top-level supervisor should be a Claude Code script or a separate agent md
- Which additional departments to build before moving to CrewAI
- What the "same test task" will be for comparing all three frameworks

---

## Notes for Claude Code Sessions
- When creating new agent md files, always follow the standard format above exactly
- When refining existing agent files, preserve the section structure — only edit content
- When building the CrewAI implementation, use the md files as the source of truth,
  not the other way around
- Always commit working changes to git before making significant edits
- The `outputs/` directories should be in .gitignore (they're run artifacts, not source)
