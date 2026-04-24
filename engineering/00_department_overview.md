# Engineering Department — Overview

## Purpose
This department designs, builds, ships, operates, and secures software. When the
Top-Level Supervisor receives a request involving technical implementation, system
design, infrastructure, code review, testing, security, or technical documentation,
it delegates to this department.

## Hierarchy

```
[Top-Level Supervisor]
        |
        v
[Engineering Supervisor]  <-- VP Engineering, orchestrates all agents below
        |
        |-----> [Software Architect]          -- system design, ADRs, technical planning
        |-----> [Backend Engineer]            -- services, APIs, data layer
        |-----> [Frontend Engineer]           -- web UI, client applications
        |-----> [Mobile Engineer]             -- iOS/Android apps
        |-----> [DevOps / SRE Engineer]       -- infrastructure, deploys, reliability
        |-----> [Security Engineer]           -- AppSec, secure design, threat modeling
        |-----> [QA / Test Engineer]          -- test strategy, automation, quality
        |-----> [Code Reviewer]               -- code review, standards enforcement
        |-----> [Technical Writer]            -- docs, ADRs, runbooks, API references
```

## Typical Activation Sequences

**Small feature implementation:**
Software Architect (lightweight design) → Backend/Frontend/Mobile Engineer → Code Reviewer → QA

**New service or significant system change:**
Software Architect → Security Engineer (threat model) → Backend Engineer + DevOps (parallel)
→ QA + Code Reviewer → Technical Writer → Engineering Supervisor sign-off

**Production incident / reliability issue:**
DevOps/SRE (triage) → relevant engineer (fix) → Code Reviewer → DevOps (deploy) → Technical Writer (postmortem)

**Security review of existing system:**
Security Engineer → Software Architect (if design changes needed) → relevant engineer (remediation) → Security Engineer (verification)

## Shared Output Directory
All agents write their outputs to `./outputs/` with these subdirectories:
- `architecture/` — system designs, ADRs, diagrams
- `code/` — code artifacts, diffs, implementation notes
- `infra/` — infrastructure configs, deploy plans, runbooks
- `security/` — threat models, findings, remediation plans
- `qa/` — test plans, test results, coverage reports
- `reviews/` — code review comments, approval status
- `docs/` — user-facing and internal technical documentation

## Output Format Default
- Code and configs as appropriate to the language/tool (e.g., .py, .ts, .tf, .yaml)
- Designs, ADRs, reviews, and docs as markdown (.md)
- Diagrams as Mermaid code blocks embedded in markdown

## Inter-Agent Communication Rules
1. All coordination goes through the Engineering Supervisor. Engineers do not assign
   each other work.
2. No code reaches "done" without passing through both the Code Reviewer and QA. No
   production-impacting change reaches deploy without Security Engineer sign-off if
   it touches auth, data, or external interfaces.
3. The Software Architect is activated before implementation for any non-trivial change.
   Skipping this step is allowed only for clearly local, contained changes.
4. The Technical Writer is activated for externally-visible behavior changes and for
   changes that affect on-call runbooks.
