# Gimme QA Report

## Result
- Status: Pass
- Builder: Codex
- Project: `C:\dev\summit_2026_06_25_frame2_genre_002`
- Public preview: https://new31005.github.io/ai-summit-gimme-20260622/
- Current version: 1.2.0+4, 80-plus remediation applied after Claude rereview

## Verification
- `dart format lib test`: pass
- `flutter analyze`: pass
- `flutter test`: pass, 10 tests
- `flutter build web --base-href /ai-summit-gimme-20260622/`: pass
- `flutter build apk --debug`: pass
- Mobile viewport visual check: pass at 390 x 844, Chrome DevTools emulation, `innerWidth=390`, `scrollWidth=390`
- Public HTTPS visual check: pass at 390 x 844
- Paywall visual check: pass at 390 x 844

## Scope Checked
- Home dashboard renders with the Gimme brand, household profile, monthly reclaim estimate, and next quest.
- Opportunity logic changes based on household conditions.
- Quest checklist progress is persisted with `shared_preferences`.
- Household settings can be edited and recalculate opportunities.
- Plan/insights screen describes the recurring revenue path.
- Gimme Plus paywall opens from the home CTA and supports preview unlock state.
- Estimate ranges and estimate basis are visible in model/UI.
- Deadlines are calculated from the current date instead of hardcoded `daysLeft`.
- Child allowance counts supported 18-22 older children for third-child classification.
- Free plan gates lower-priority candidates; Plus unlocks all candidate detail.
- Subscription savings use monthly total, contract count, unused count, and stale months.
- Application-prepared amount and actual recovered amount are separated.
- AI statement scan extracts recurring charges, normalizes yearly/weekly/quarterly amounts to monthly equivalents, and can update household subscription inputs.
- Android/iOS display names are `Gimme`; stale `com/example/gimme` source folders are removed.

## Known Notes
- This is a confirmation Web build for mobile review. Official release remains Android/iOS native mobile.
- Android debug APK was generated for local device verification.
- Eligibility, amounts, and claim flows are demo logic. Production requires verified rules, data sources, and legal/tax review before users submit real claims.
- Real in-app purchase products are not connected in the Web confirmation build.
- Cloudflare temporary deployment failed external reachability after initial publish; GitHub Pages is now the confirmed preview URL.

## 2026-06-22 Claude Rereview Follow-up

Shinchan clarified that the goal was never a verification MVP. The product was reworked toward the requested completion standard instead of defending the previous lower bar.

Implemented follow-up fixes:
- Replaced static deadline values with computed deadline dates and derived `daysLeft`.
- Connected city input to local benefit profiles and source labels.
- Connected Plus unlock to actual candidate gating and detail visibility.
- Replaced arbitrary subscription math with contract/unused/stale-month calculation.
- Split prepared application value from actual recovered value.
- Added local AI statement scan flow with API-ready parsing boundary.
- Cleaned Android/iOS labels, stale package directories, and review package cache exclusions.

## 2026-06-23 80-Plus Remediation

Claude's latest review said the direction improved but still missed all-80 quality. The implementation was updated again:

- Added `supportedOlderChildren` to household profile, persistence, and UI.
- Reworked child allowance estimates to follow national child allowance counting, including supported 18-22 older children for third-child classification.
- Reworked medical deduction calculation so deduction amount and tax relief estimate are separated.
- Strengthened AI statement scan with period detection, monthly normalization, raw amount display, confidence, and broader candidate extraction.
- Added a Plus-only monthly guard opportunity and reduced Free visibility to two candidates.
- Updated tests for child allowance, AI scan normalization, and medical deduction separation.
