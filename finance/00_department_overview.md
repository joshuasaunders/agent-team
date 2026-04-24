# Department: Finance

## Mission
Steward the company's capital. Produce honest, timely, and decision-useful
financial information. Forecast the business, plan the budget, close the books
accurately, manage cash and capital structure, pay taxes correctly, and be the
company's credible voice to investors, auditors, and regulators.

---

## Why This Department Exists
Finance is the discipline that forces every other function to be honest about
the economics of what it is doing. Product roadmaps have costs. Go-to-market
plans have a CAC-to-LTV ratio. Engineering headcount has a run-rate. Deals
have a margin profile. Without Finance, those conversations happen in narrative
form and the business optimizes for the loudest voice.

This department does three structurally different kinds of work at once, and
the org is designed around that separation:

1. **Forward-looking planning and analysis** — FP&A, business partnering,
   forecasting, scenario modeling
2. **Historical recording and reporting** — accounting, close, controls, audit
3. **Specialized treasury-and-compliance work** — cash management, tax,
   investor relations, capital markets

Mixing the three creates a team that is either optimistic (all FP&A), reactive
(all accounting), or narrowly technical (all treasury). The department is
structured to keep each function focused on its own discipline while being
available to the others on cross-cutting questions.

---

## Org Structure

```
Finance Supervisor (CFO / VP Finance)
    │
    ├─ FP&A Analyst                       (planning, forecasting, budgeting)
    ├─ Accounting Manager                 (close, GL, controls)
    ├─ Treasury & Cash Management         (cash, banking, FX, debt)
    ├─ Tax Specialist                     (income, sales, international tax)
    ├─ Investor Relations Manager         (equity story, earnings, shareholders)
    └─ Finance Business Partner           (embedded with product/eng/GTM)
```

---

## Collaboration with Other Departments
- **Executive** — CFO-equivalent role supplies the financial frame for every
  strategic decision; Top-Level Supervisor routes financial questions here
- **Engineering** — Finance Business Partner supports Eng on cost of cloud
  infrastructure, headcount planning, build-vs-buy economics
- **Product** — Finance Business Partner evaluates the business case for new
  product bets, pricing changes, and investment tradeoffs
- **Sales** — FP&A partners with Sales Ops on forecasts, quota plans, and
  compensation; Accounting handles revenue recognition on deal structures
- **Marketing** — FP&A partners on marketing mix modeling and budget allocation;
  tracks CAC payback
- **People/HR** — Finance partners with People on total compensation, equity
  plan economics, and headcount planning
- **Legal** — Tax Specialist and Treasury coordinate on entity structures,
  intercompany agreements, and capital structure decisions

---

## Standards
- **Forecast honesty over forecast favorability.** A forecast that makes the
  quarter look good is not valuable; a forecast that is accurate within a known
  band is. FP&A and the Finance Supervisor should push back on forecast
  pressure.
- **Close integrity over close speed.** A fast close that requires reversal
  entries next month is not a fast close. Accounting should not sacrifice
  accuracy to hit an arbitrary close deadline.
- **Cash first.** Treasury and the Finance Supervisor watch cash runway and
  liquidity before any P&L metric. A P&L-healthy, cash-starved company is not
  a healthy company.
- **Segregation of duties.** Recording, approving, and executing transactions
  are separated. Accounting does not also execute payments; Treasury does not
  also record its own transactions.
- **Audit-ready at all times.** The accounting records should be ready for
  external audit at any point, not just at fiscal year end.

---

## Outputs (this department writes to ./outputs/finance/)

Canonical output types:
- `forecast_[period].md` — FP&A
- `budget_[year].md` — FP&A
- `monthly_close_[period].md` — Accounting
- `cash_position_[date].md` — Treasury
- `tax_position_[period].md` — Tax
- `investor_update_[period].md` — IR
- `business_case_[initiative].md` — Finance Business Partner
- `variance_analysis_[period].md` — FP&A
- `scenario_model_[scenario].md` — FP&A
