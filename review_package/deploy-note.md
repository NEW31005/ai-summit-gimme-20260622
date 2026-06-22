# Gimme Deploy Note

## Public Preview
- URL: https://new31005.github.io/ai-summit-gimme-20260622/
- Provider: GitHub Pages
- Repository: https://github.com/NEW31005/ai-summit-gimme-20260622
- Deploy source: `C:\dev\ai-summit-gimme-20260622-pages`
- Latest commit: GitHub Pages repository HEAD after the completion-standard rework push
- Deploy command used: `gh repo create NEW31005/ai-summit-gimme-20260622 --public --source C:\dev\ai-summit-gimme-20260622-pages --remote origin --push`, then GitHub Pages enabled from `main` `/`.

## 2026-06-22 Update

Claude review fixes were applied and republished:

- estimate ranges and basis text
- medical deduction wording correction
- visible compliance/privacy surfaces
- native-ready `Gimme Plus` paywall
- Gimme-specific Web/Android/iOS metadata

Public mobile-width verification passed after GitHub Pages propagation.

## Important
The first Cloudflare temporary deploy appeared to succeed but later resolved to `100::` and failed external HTTPS checks, so it is not the delivery URL.

GitHub Pages required rebuilding Flutter Web with `--base-href /ai-summit-gimme-20260622/`. After republishing, mobile-width browser verification passed at 390 x 844.

## 2026-06-22 Completion-Standard Rework

Shinchan rejected treating the build as an MVP. The app was republished from version `1.2.0+3` after a product-logic rework:

- real deadline dates and derived remaining days
- city-aware benefit profiles
- functional Free/Plus gating
- subscription saving model based on contracts, unused count, and stale months
- separated application-prepared value and actual recovered value
- local AI statement scan flow
- Android/iOS app label cleanup and stale package cleanup

Verification before push:

- `flutter analyze`: pass
- `flutter test`: pass, 9 tests
- `flutter build web --base-href /ai-summit-gimme-20260622/`: pass
- `flutter build apk --debug`: pass
- Chrome DevTools mobile visual check: pass at 390 x 844 with no horizontal overflow

## 2026-06-23 80-Plus Remediation Republish

Claude's 80-plus redesign review was applied to the Flutter implementation and republished as `1.2.0+4`.

- child allowance logic now includes supported 18-22 older children in third-child classification
- medical deduction estimate separates deduction amount and tax relief estimate
- AI statement scan now detects billing period, normalizes to monthly amounts, and shows confidence/reason
- Free plan now exposes two candidates; Plus adds monthly guard value

Verification before push:

- `dart format lib test`: pass
- `flutter analyze`: pass
- `flutter test`: pass, 10 tests
- `flutter build web --release --base-href /ai-summit-gimme-20260622/`: pass

## 2026-06-23 Build 5 Rereview Remediation

Claude's follow-up review was treated as valid on product/commercial implementation gaps. Gimme was republished as `1.2.0+5`.

- Web preview entitlement is now separated from native store entitlement architecture.
- `in_app_purchase`, `flutter_local_notifications`, and `flutter_local_notifications_web` dependencies were added.
- Plus notification value now generates visible deadline/monthly-scan reminder plans and persists the enabled state.
- Medical deduction now collects insurance reimbursement and total income, then estimates tax relief after reimbursement.
- AI statement scan no longer counts annual-risk unknown-period charges in monthly totals.
- Child allowance now collects under-three count and uses exact national amount logic.
- Fabricated city-specific money ranges were removed; city matching is only a primary-source lookup cue.

Verification before push:

- `flutter pub get`: pass
- `dart format lib test`: pass
- `flutter analyze`: pass
- `flutter test`: pass, 13 tests
- `flutter build web --base-href /ai-summit-gimme-20260622/`: pass
- Public `version.json`: `1.2.0+5`
- Public mobile visual check: pass at 390 x 844 for Home, AI scan, extraction result, and Insights notification plan

GitHub Pages repository commit: `9111286 Deploy Gimme build 5 remediation`.

## 2026-06-23 Build 6 IAP/Notification Wiring

Claude's Build 5 rereview said the calculation layer was credible, but monetization/native readiness still failed because purchase and notification code were only scaffolding. Gimme was updated to `1.2.0+6`.

- Store purchase start is wired through `InAppPurchase.buyNonConsumable`.
- Purchase stream updates now grant `EntitlementSource.store` on `purchased/restored`.
- Pending purchases call `completePurchase`.
- Purchase restore is exposed from the paywall.
- Notification initialization, permission request, `zonedSchedule`, and cancellation are implemented in `NativeReminderBridge`.
- The Plus reminder switch calls native scheduling on non-Web targets.
- Android core library desugaring was enabled for `flutter_local_notifications`.
- Public review source snapshot was synchronized to Build 6.

Verification before push:

- `flutter pub get`: pass
- `dart format lib test`: pass
- `flutter analyze`: pass
- `flutter test`: pass, 14 tests
- `flutter build web --base-href /ai-summit-gimme-20260622/`: pass
- `flutter build apk --debug`: pass

## 2026-06-23 Build 7 Subscription Lifecycle

Gimme was updated to `1.2.0+7` to address the remaining Build 6 monetization blocker.

- Store Plus is no longer a permanent local unlock.
- Native purchase/restored events create a 32-day verification window.
- The app stores verified and expiry timestamps, refreshes near expiry, and locks expired/unverified store entitlements.
- The paywall exposes sync state, expiry, restore, and store-management guidance.
- The review source package was updated for Build 7.

Verification before push:

- `dart format lib test`: pass
- `flutter analyze`: pass
- `flutter test`: pass, 17 tests
- `flutter build web --base-href /ai-summit-gimme-20260622/`: pass
- `flutter build apk --debug`: pass
- Public `version.json`: `1.2.0+7`
- Public mobile visual check: pass at 390 x 844, no console errors, no horizontal overflow

GitHub Pages repository commit: `7a9b262 Deploy Gimme build 7 subscription lifecycle`.
