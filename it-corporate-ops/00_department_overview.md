# Department: IT / Corporate Operations

## Mission
Run the company's internal technology, business systems, security posture,
and workplace operations. Make sure employees have the tools, access, and
environment to do their jobs; the internal systems (not the product) are
reliable and integrated; the corporate security posture is strong; and the
physical (or distributed) workplace supports how the company actually works.

---

## Why This Department Exists
Separate from the engineering that builds the product, every technology
company needs an internal technology function: the laptops, the identity
system, the SaaS stack, the data integrations between business systems,
the corporate security controls, the onboarding and offboarding automation.
When these are done well, no one notices. When they are done poorly — bad
identity, broken integrations, slow laptops, tangled SaaS sprawl — the
friction compounds across every function.

This department is also the steward of the physical and distributed
workplace. Whether the company is fully remote, hybrid, or in offices, the
workplace experience shapes productivity and culture. Corporate Ops owns
the infrastructure that makes the workplace function.

Finally, this department is where internal security lives — corporate
security, distinct from product/AppSec which lives in Engineering. Identity,
access management, device security, data loss prevention, SaaS security —
these are IT's operational responsibility in coordination with the Security
Engineer (who handles AppSec) and Privacy Counsel (who handles privacy law).

---

## Org Structure

```
IT / Corporate Ops Supervisor (VP IT / Chief Information Officer)
    │
    ├─ Systems Administrator           (identity, devices, SaaS, infrastructure)
    ├─ Help Desk / IT Support Lead     (end-user support)
    ├─ IT Security Manager             (corporate security, IAM, DLP)
    ├─ Business Systems Analyst        (CRM, HRIS, ERP, integrations)
    └─ Workplace / Facilities Manager  (physical space, distributed workplace)
```

---

## Collaboration with Other Departments
- **All departments** — IT provisions access, manages devices, supports the
  SaaS applications each department uses
- **People/HR** — tight partnership on onboarding (provisioning) and
  offboarding (deprovisioning); partnership on workplace experience
- **Finance** — Business Systems Analyst supports ERP and finance systems;
  IT Security supports financial controls
- **Legal** — IT Security partners with Privacy Counsel on data protection
  operations; coordination with Litigation Counsel on e-discovery
- **Engineering** — IT and Engineering coordinate on tooling, identity,
  and dev infrastructure (not product infrastructure)

---

## Standards
- **Identity is the foundation.** A strong identity system (SSO, MFA,
  access reviews) is the highest-leverage corporate security investment.
  Every other control depends on identity being right.
- **Automation over manual provisioning.** Provisioning that requires a
  human to execute each step will inevitably be incomplete or late. The
  target state is automated provisioning and deprovisioning driven off
  the HRIS and role.
- **Integration over SaaS sprawl.** A company with 200 SaaS apps but
  no integration between them has higher cost, more data silos, and
  worse security posture than a company with 100 apps and well-managed
  integrations.
- **Help desk experience as culture signal.** Employees judge the company's
  operational competence by how IT support feels. A help desk that is
  responsive, capable, and respectful builds trust; one that is slow or
  dismissive erodes it.
- **Security as enabler, not gate.** Corporate security controls should
  make secure behavior easy and insecure behavior hard, rather than
  blocking work and training employees to work around controls.
- **Audit-ready.** IT controls that are important to SOC 2, ISO 27001, or
  financial audits operate consistently, not just before audit windows.

---

## Outputs (this department writes to ./outputs/it-corp-ops/)

Canonical output types:
- `access_review_[period].md` — IT Security
- `it_incident_[incident].md` — IT Security / Systems Admin
- `provisioning_playbook_[role].md` — Systems Admin / Help Desk
- `saas_inventory.md` — Systems Admin
- `integration_design_[topic].md` — Business Systems Analyst
- `workplace_plan_[location].md` — Workplace / Facilities
- `help_desk_metrics_[period].md` — Help Desk Lead
- `corporate_security_posture.md` — IT Security
