# Gimme Build 7 Review Request

Please review Build 7 as a follow-up to your Build 6 finding.

Public preview:
https://new31005.github.io/ai-summit-gimme-20260622/?build=7

Local app project:
`C:\dev\summit_2026_06_25_frame2_genre_002`

Version:
`1.2.0+7`

## What changed since Build 6

Build 6 still had a monetization blocker: a monthly Plus purchase could become an indefinite local unlock because the app did not store or enforce a subscription expiry/refresh lifecycle.

Build 7 fixes the app-side lifecycle:

- `EntitlementSnapshot` now carries `verifiedAt`, `expiresAt`, and `purchaseId`.
- `PreviewEntitlementRepository` persists `storeVerifiedAt`, `storeExpiresAt`, and `storePurchaseId`.
- Native purchase/restored events create a 32-day Store Plus verification window.
- Expired store entitlements are cleared and lock Plus.
- Legacy store unlocks with no expiry metadata are treated as unverified and locked until restore.
- Entitlements within 5 days of expiry trigger restore refresh.
- Paywall shows sync state and Plus confirmation expiry.
- Native users are told to manage cancellation in App Store / Google Play rather than locally toggling off Plus.
- Purchase pending/canceled/error states produce visible billing status messages.

## Verification evidence

- `dart format lib test`: pass
- `flutter analyze`: pass
- `flutter test`: pass, 17 tests
- `flutter build web --base-href /ai-summit-gimme-20260622/`: pass
- `flutter build apk --debug`: pass

## Review focus

Please give a strict review of whether Build 7 has moved the product past the previous monetization/native-readiness blocker:

1. Does the app still risk permanent local Plus access after a canceled monthly subscription?
2. Is the client-side expiry/restore lifecycle credible enough for a pre-store release build?
3. Is the remaining store-console/backend validation work clearly bounded rather than hidden?
4. Are the paywall and recurring-value explanation commercially credible?
5. Would you now score monetization, technical, and native readiness at 80+?

Please score:

- Overall
- Hit potential
- Monetization
- UI/UX
- Technical implementation
- Legal/safety
- Native release readiness

Final answer should be one of:

- ship candidate
- keep iterating
- major redesign needed
