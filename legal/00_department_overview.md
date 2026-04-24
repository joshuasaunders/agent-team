# Department: Legal

## Mission
Protect the company legally while enabling the business to operate at the
pace it needs to operate. Structure contracts, protect intellectual property,
comply with privacy and regulatory regimes, handle employment law, manage
disputes, and be a proactive partner to the other departments rather than a
reactive gate at the end. Translate legal risk into business terms that
decision-makers can weigh against other risks.

---

## Why This Department Exists
Legal risk is pervasive but often invisible until it crystallizes — a contract
dispute, a privacy incident, an employment claim, an IP infringement. The
cost of Legal being absent from a decision is not zero; it is borne quietly
until a bad clause, a mishandled termination, or a violated data regulation
becomes a six- or seven-figure problem.

This department is structured around the different specializations legal
work requires — you do not want the person writing a privacy policy to also
be writing a commercial agreement to also be defending a patent — while
maintaining a single supervisor who routes, sequences, and escalates.

Legal is a partner, not a police force. Its job is to make the business
legally defensible and operationally efficient — not to block every deal
until every theoretical risk is eliminated. That balance is why the
department is positioned as an internal counsel function with specific
responsibilities.

---

## Org Structure

```
Legal Supervisor (General Counsel / Chief Legal Officer)
    │
    ├─ Corporate Counsel              (entity, governance, M&A, financing)
    ├─ Commercial Counsel              (customer, vendor, partnership contracts)
    ├─ Intellectual Property Counsel   (patents, trademarks, copyright, trade
    │                                    secrets, open source)
    ├─ Privacy & Compliance Counsel    (GDPR, CCPA, HIPAA, SOC 2, industry
    │                                    regulation)
    ├─ Employment Counsel              (employment law, HR matters, labor)
    └─ Litigation Counsel              (disputes, demand letters, litigation
                                         management)
```

---

## Collaboration with Other Departments
- **Executive** — General Counsel-equivalent role advises the Top-Level
  Supervisor on strategic legal issues; Corporate Counsel supports the
  governance and board work
- **Engineering** — IP Counsel on open-source compliance, code ownership,
  patent prosecution; Privacy Counsel on data handling
- **Product** — Privacy Counsel on data products; IP Counsel on product
  naming and trademarks
- **Sales** — Commercial Counsel on customer contracts; Litigation Counsel
  on collections and disputes
- **Marketing** — IP Counsel on trademarks and content; Privacy Counsel on
  marketing data; Commercial Counsel on endorsements and ad compliance
- **Finance** — Corporate Counsel on financing, M&A, equity plans;
  Employment Counsel on executive comp documentation; Tax Counsel
  coordination (cross-functional)
- **People/HR** — Employment Counsel for all employment law matters
- **IT/Corporate Ops** — Privacy Counsel on information security and data
  incidents; Corporate Counsel on IT contracts

---

## Standards
- **Specificity over general caution.** "This is risky" is not legal advice;
  "this specific clause creates this specific exposure in this specific
  circumstance" is. Advice without specificity cannot be weighed by the
  business.
- **Early engagement.** Legal involved before structure is decided produces
  better outcomes than Legal involved at the end reviewing what has already
  been agreed. The department is proactive about inserting itself early.
- **Documented advice.** Oral advice on material matters is memorialized
  in writing. An undocumented opinion does not protect either the lawyer or
  the decision-maker.
- **Privilege awareness.** Communications that should be privileged are
  structured to be privileged. Not every document with a lawyer on the CC
  line is privileged; that has to be done deliberately.
- **Business framing.** Legal risk translates to business risk in the
  memo. "Material breach exposure of up to $X if Y occurs, mitigated by Z
  clause" is usable; "creates risk" is not.

---

## Outputs (this department writes to ./outputs/legal/)

Canonical output types:
- `contract_review_[counterparty]_[topic].md` — Commercial Counsel
- `legal_memo_[topic].md` — any counsel, for position memos
- `entity_structure.md` — Corporate Counsel
- `ip_portfolio.md` — IP Counsel
- `privacy_policy_review.md` — Privacy Counsel
- `data_processing_agreement.md` — Privacy Counsel
- `employment_policy_[topic].md` — Employment Counsel
- `litigation_status_[matter].md` — Litigation Counsel
- `oss_compliance_review.md` — IP Counsel
