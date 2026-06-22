# Claude 80+ Redesign Review / 2026-06-23

Claude chat:

`https://claude.ai/chat/dedeb474-719f-4922-bb2d-37d15bae79c5`

Reviewed input:

- `app/02_spec/gimme-80plus-redesign-spec.md`
- `app/02_spec/gimme-80plus-implementation-prompt.md`

## Score

| Item | Current | Spec Target | Claude Forecast | Result |
|---|---:|---:|---:|---|
| Overall | 63 | 84 | 80 | Borderline |
| Hit potential | 58 | 82 | 73 | Below 80 |
| Monetization | 52 | 84 | 71 | Below 80 |
| UI/UX | 76 | 85 | 82 | Above 80 |
| Technical quality | 70 | 85 | 80 | Borderline, only if child allowance is fixed |

## Main Verdict

Claude judged that the redesign is much more serious than the previous version, especially around trust:

- `BenefitRule` plus `SourceCitation` is the right direction.
- `EntitlementRepository` separation and removing the free `_premiumUnlocked` toggle is right.
- `StatementLine` plus `BillingPeriod` and monthly normalization fixes the old 12x subscription bug.
- "Do not show money for unverified municipality rules" is honest and correct.
- `CalculationTrace`, source dates, empty states, and missing-input handling are strong.

But Claude does **not** think this version clears all 80-point targets yet. Hit potential and monetization remain below 80.

## Critical Findings

### 1. Child allowance model is still wrong for large families

Claude's strongest objection:

The spec treats child allowance as the first "real" rule, but the model only has `HouseholdProfile.children`. It does not represent older economically dependent siblings after high-school age and until the end of the fiscal year in which they turn 22.

That means the app can miscalculate third-child allowance in families with an older 18-22-year-old child who is not directly eligible for payment but is counted for the "third child and later" calculation.

Required fix:

- Add an 18-22 dependent sibling / economically supported child model.
- Calculate birth order using eligible children plus counted older siblings.
- Model the fiscal-year boundary when an older sibling ages out of the count.
- Show that the extra count can require `監護相当・生計費の負担についての確認書`.
- Add tests for a family such as 20-year-old, 15-year-old, and 12-year-old children.

### 2. Trust improved, but differentiation got weaker

Claude said the redesign removes fake municipality amounts, which is correct. But if local benefits are pushed to Phase 4 without a collection and maintenance plan, the product becomes:

- child allowance calculator
- medical expense deduction calculator
- subscription cleanup scanner

Those are too close to existing free tools unless Gimme adds a stronger reason to use it.

Required fix:

- Define a real municipality-data collection and update plan.
- Start with at least top cities or high-impact local rules.
- Define who checks sources, how often, and how stale rules are handled.

### 3. Monetization is still not strong enough

Claude judged monetization at 71, mainly because:

- the strongest trust-building values are free
- monthly subscription value is weak
- the app lacks a conversion funnel
- `¥1,480/month` may be too high for once-a-year benefits
- outcome/recovered-value monetization is still not in the spec

Required fix:

- Define paywall trigger points:
  - after a large value is detected
  - after scan limit
  - before notification activation
  - before PDF/report creation
- Add trial and conversion metrics.
- Rework Free/Plus so the user sees enough value, but ongoing saved diagnosis, notifications, reports, history, and detailed next actions are Plus.
- Add monthly value:
  - subscription monitoring
  - new benefit feed
  - monthly missed-money counter
  - family plan
  - outcome-based add-on

### 4. Medical deduction needs more precise tax design

Claude flagged that simply multiplying deduction by a single tax rate is weak.

Required fix:

- Separate income tax refund estimate from resident tax reduction.
- Explain `総所得金額等` clearly so users do not confuse it with salary revenue.
- Avoid asking users for a marginal tax rate they probably do not know.
- Prefer deriving a range from income inputs or showing deduction amount only until sufficient data exists.

### 5. Onboarding is too hard-gated

Claude liked the existence of onboarding, but said forcing all fields before showing value will hurt activation.

Required fix:

- Show the fastest useful number first.
- Ask only child ages / birthdates and counted older dependents first.
- Let users skip medical, loan, and statement steps.
- Deepen precision after the first "you may be missing this" moment.

### 6. AI scan still needs a real-world input strategy

Claude agreed with period normalization, but warned that real card statements often do not include words like "monthly" or "yearly."

Required fix:

- Add CSV import and/or OCR plan.
- Add merchant-name classification.
- Add repeat-transaction detection across months.
- Keep unknown subscriptions as confirmable candidates rather than discarding or excluding too much.
- Define concrete PII masking, not just "mask before AI."

### 7. Rule engine expression needs to be unified

Claude flagged a design inconsistency:

- Dart closures in `BenefitRule.evaluate` are easy for national rules.
- JSON rules are needed for municipality expansion.
- If both exist, the system becomes two engines.

Required fix:

- Decide on a unified rule expression:
  - versioned JSON rule DSL plus Dart interpreter, or
  - Dart calculators for national rules and structured JSON for local checklist-only rules with clear boundaries.

## Claude's Priority Order

1. Fix child allowance model before implementation.
2. Add monetization funnel.
3. Redesign Free/Plus boundary.
4. Add monthly recurring value.
5. Improve medical deduction tax estimate.
6. Add municipality-data collection and maintenance plan.
7. Make AI scan work with real statements.
8. Add remote/staleness handling for rule updates.
9. Add tax/legal/compliance notes.
10. Unify rule expression.

## Mari Read

Claude's review is fair. The redesign successfully fixed the trust architecture, but it still does not satisfy Shinchan's "monetization first, all 80+" bar.

The biggest miss is the child allowance rule. I confirmed with official Children and Families Agency information that "third child and later" counting includes eligible children plus economically supported older siblings through the fiscal year in which they turn 22. The current redesign spec does not model those older siblings, so it can be wrong for large families.

The next redesign pass should not add more UI polish first. It should revise:

- child allowance data model
- Free/Plus boundary
- monthly-value loop
- paywall funnel
- municipality-data plan
- real statement scan plan

Only after those are written into the spec should implementation restart.
