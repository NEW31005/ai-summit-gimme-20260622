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

## 2026-06-23 Build 5 Rereview Remediation

Claude's next rereview found the previous remediation still weak on entitlement, notification, medical-input wiring, annual-risk subscriptions, and fabricated local money ranges. Those findings were treated as valid and implemented.

Implemented fixes:
- Added a preview entitlement repository and native store entitlement bridge with product id `gimme_plus_monthly`.
- Added `in_app_purchase`, `flutter_local_notifications`, and `flutter_local_notifications_web`.
- Added Plus notification plan generation and persisted notification enablement.
- Added household inputs for under-three children, medical reimbursement, and total income.
- Rewired medical deduction estimates to subtract reimbursement and use income tax rate plus resident-tax estimate.
- Changed unknown annual-risk subscription charges to `周期確認待ち` and excluded them from monthly totals.
- Removed fabricated city-specific amount ranges from city profiles.
- Added tests for under-three child allowance, annual-risk subscription exclusion, reimbursement/income medical calculation, and city amount removal.

Verification:
- `flutter pub get`: pass
- `dart format lib test`: pass
- `flutter analyze`: pass
- `flutter test`: pass, 13 tests
- `flutter build web --base-href /ai-summit-gimme-20260622/`: pass
- Public preview version check: `1.2.0+5`
- Public mobile visual check: pass at 390 x 844 for Home, AI scan, extraction result, and Insights notification plan

Review package:
- `C:\Users\Rig5070\Documents\AI_Summits\ai-summit\runs\2026-06-25_frame2-genre-002\app\04_reports\gimme-rereview-build5-package-20260623.zip`

## 2026-06-23 Build 6 IAP/Notification Wiring

Claude's Build 5 rereview found two recurring blockers: Plus still did not start/restore a store transaction, and notification code still did not schedule OS notifications. Those were implemented as Build 6.

Implemented fixes:
- Added `startPlusPurchase()` using `InAppPurchase.buyNonConsumable`.
- Added purchase update listener and store entitlement grant for `purchased/restored`.
- Added `completePurchase` for pending purchase completion.
- Added `restorePurchases` and a native-only restore button.
- Connected non-Web Plus activation to store purchase start.
- Added notification initialization, permission request, `zonedSchedule`, and cancellation.
- Connected Plus reminder switch to native scheduling on non-Web targets.
- Added Android desugaring for `flutter_local_notifications`.
- Updated public review source snapshot to Build 6 so it no longer points to stale Build 4 files.

Verification:
- `flutter pub get`: pass
- `dart format lib test`: pass
- `flutter analyze`: pass
- `flutter test`: pass, 14 tests
- `flutter build web --base-href /ai-summit-gimme-20260622/`: pass
- `flutter build apk --debug`: pass

Known notes:
- Web preview intentionally remains a no-purchase preview entitlement.
- iOS build cannot be verified from this Windows environment.
- Real Play/App Store product creation for `gimme_plus_monthly` remains a store-console release task.

## 2026-06-23 Claude Build 6 Rereview Result

Saved review:
- `C:\Users\Rig5070\Documents\AI_Summits\ai-summit\runs\2026-06-25_frame2-genre-002\app\04_reports\claude-rereview-build6-20260623.md`

Claude/Chloe judgment:
- Build 5's two major blockers were judged fixed in real code:
  - store purchase/restore/purchase-stream handling now exists and is wired from `main.dart`
  - notification initialization/permission/`zonedSchedule` now exists and is wired from the reminder toggle
- Public source snapshot mismatch was judged fixed.
- Android debug build evidence was judged fixed.
- Scores improved:
  - Overall: 76
  - Monetization: 74
  - UI/UX: 81
  - Technical: 83
  - Legal/safety: 78
  - Native readiness: 74
  - Hit potential: 72
- Final judgment: `keep iterating`, but now "one build before shipping".

Remaining blocker:
- Monthly subscription state has no expiration/renewal/active-state verification yet. A one-month user could cancel but remain locally unlocked unless store revalidation or a buyout model is implemented.
- Store product creation, release signing, internal test track, and real purchase test remain external store-console release tasks.

## 2026-06-23 Build 7 Subscription Lifecycle Remediation

Claude/Chloe's Build 6 blocker was accepted as valid. Build 7 removes the dangerous "monthly purchase becomes permanent local unlock" behavior.

Implemented fixes:
- Bumped app version to `1.2.0+7`.
- Added bounded store entitlement fields: `storeVerifiedAt`, `storeExpiresAt`, and `storePurchaseId`.
- Store purchases/restores now create a 32-day Store Plus entitlement instead of an indefinite unlock.
- Expired store entitlements are cleared on app startup/load.
- Entitlements inside the final 5 days request store restore refresh.
- Legacy Build 6 store unlocks that do not have expiry metadata are treated as unverified and locked until restore.
- Paywall now shows sync state and Plus confirmation expiry.
- Native users are told to cancel/manage subscriptions in App Store / Google Play rather than by locally toggling Plus off.
- Purchase pending/canceled/error states now surface a visible billing status message.

Verification:
- `dart format lib test`: pass
- `flutter analyze`: pass
- `flutter test`: pass, 17 tests
- `flutter build web --base-href /ai-summit-gimme-20260622/`: pass
- `flutter build apk --debug`: pass
- Public `version.json`: `1.2.0+7`
- Public mobile visual check: pass at 390 x 844, `scrollWidth=390`, no browser console errors

Known notes:
- This is still a Web preview plus native-ready Flutter code. Web preview intentionally uses no real purchase.
- Store-console work remains required for formal release: create `gimme_plus_monthly`, run sandbox/internal purchase tests, and release-sign native builds.
- For production-grade subscription verification, the same expiry fields should be backed by App Store / Google Play receipt validation or a managed entitlement provider. Build 7 prevents indefinite local unlock even before that final store backend pass.
