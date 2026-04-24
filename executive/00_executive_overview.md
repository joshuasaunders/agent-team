# Executive Department — Overview

## Purpose
The Executive department sits above all other departments. It receives every incoming
request, decides which department(s) should handle it, breaks ambiguous requests into
concrete assignments, and reviews the final outputs before they go back to the user.
Think of this layer as the CEO + Chief of Staff of a company — they do not themselves
produce market research, write code, or close deals, but they decide what needs to be
done, who should do it, in what order, and to what quality bar.

## Hierarchy

```
[User / External Requester]
        |
        v
[Top-Level Supervisor]  <-- CEO-equivalent; single entry point for all requests
        |
        |---> [Chief of Staff]               -- tracks work, produces memos, handles cross-dept coordination
        |
        |---> [Research & Strategy Supervisor]
        |---> [Engineering Supervisor]
        |---> [Product Supervisor]
        |---> [Marketing Supervisor]
        |---> [Sales Supervisor]
        |---> [Customer Success Supervisor]  (placeholder — not yet built)
        |---> [Finance Supervisor]
        |---> [Legal Supervisor]
        |---> [People Supervisor]
        |---> [IT Operations Supervisor]
```

## Typical Activation Sequences

**Single-department request:**
Top-Level Supervisor → Department Supervisor → specialists → Department Supervisor → Top-Level Supervisor

**Cross-department request (e.g., "launch our new product"):**
Top-Level Supervisor → Chief of Staff (builds coordination plan) → multiple Department Supervisors in parallel → Chief of Staff (synthesizes) → Top-Level Supervisor

**Strategic decision (e.g., "should we enter Europe?"):**
Top-Level Supervisor → Research & Strategy (primary) + Finance + Legal + People (parallel input) → Chief of Staff synthesis → Top-Level Supervisor

## Shared Output Directory
The Executive department writes to `./executive/outputs/` and has read access to every
other department's `outputs/` directory. The Top-Level Supervisor's final deliverables
for the user are archived in `./runs/YYYY-MM-DD_task-name/`.

## Output Format Default
Markdown (.md) for narrative deliverables. Executive summary documents default to
one-page format (roughly 400 words max).

## Inter-Department Communication Rules
1. Only the Top-Level Supervisor talks to the user. Department supervisors do not
   communicate with the user directly.
2. Only the Top-Level Supervisor delegates to department supervisors. Departments
   never delegate to each other directly — cross-department work is coordinated by
   the Chief of Staff under the Top-Level Supervisor's authority.
3. The Chief of Staff is not a decision-maker. They coordinate, track, and synthesize.
   Authority always rests with the Top-Level Supervisor.
4. The Top-Level Supervisor reviews every final deliverable before it leaves the system.
