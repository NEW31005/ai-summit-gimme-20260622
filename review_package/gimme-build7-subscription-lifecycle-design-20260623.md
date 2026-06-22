# Gimme Build 7 Subscription Lifecycle Design

Date: 2026-06-23
Target app: `C:\dev\summit_2026_06_25_frame2_genre_002`
Public preview: https://new31005.github.io/ai-summit-gimme-20260622/

## Chloe Build 6 Finding

Build 6 fixed real purchase, restore, purchase-stream, notification, source-package, and Android debug APK gaps. The remaining critical monetization blocker was subscription lifetime handling:

- Store purchase/restored events granted local Plus access.
- The local entitlement did not contain an expiry or refresh requirement.
- A monthly subscription could remain unlocked after cancellation or expiration.
- The app therefore behaved like a lifetime unlock while presenting a monthly recurring product.

## Build 7 Decision

Keep the recurring Plus thesis. Do not switch the whole app to a lifetime unlock because recurring revenue is the strategy.

Implement a release-safe client lifecycle guard:

- Store entitlements get a verification window instead of permanent access.
- Monthly Plus is considered locally active for 32 days after a native purchase/restored event.
- The app stores `lastStoreVerifiedAt` and `storeExpiresAt`.
- On startup, an expired store entitlement is cleared.
- Within the final 5 days of the verification window, the app triggers purchase restoration so a still-active subscription can refresh the window.
- If restore/purchase does not return an active purchase before expiry, Plus locks again and asks the user to restore or manage the subscription in the store.
- Native users cannot cancel a store subscription by locally toggling Plus off. The UI tells them to manage/cancel in the store, and the next restore/expiry cycle reflects the result.

This does not replace App Store / Google Play backend receipt validation. It removes the dangerous "forever unlocked" behavior and creates the correct app-side expiration contract. For store release, the final production pass should add server-side receipt validation or a managed entitlement service using the same expiry fields.

## Implementation Scope

### Services

- Extend `EntitlementSnapshot` with:
  - `verifiedAt`
  - `expiresAt`
  - `statusLabel`
  - `shouldRefreshStoreEntitlement(now)`
- Persist:
  - `storeVerifiedAt`
  - `storeExpiresAt`
  - `storePurchaseId`
- `PreviewEntitlementRepository.load()` expires stale store entitlements.
- `PreviewEntitlementRepository.saveStoreEntitlement()` writes a bounded 32-day store entitlement.
- `StoreEntitlementBridge.listenForPurchaseUpdates()` reports pending, error, canceled, purchased, and restored states.

### UI

- Paywall shows:
  - Store sync status
  - Plus expiry date when native store entitlement exists
  - Native restore action
  - Clear copy that store cancellation is managed in the store, not by a local toggle
- Native store failure/cancel states produce user-visible messages.

### Tests

- Active store entitlements load as unlocked before expiry.
- Expired store entitlements load as free and clear local unlock.
- Store entitlement snapshots request refresh near expiry.
- Purchase handling no longer creates an indefinite entitlement.

## Remaining External Release Tasks

These cannot be completed from the local Flutter/Web preview alone:

- Create `gimme_plus_monthly` subscription product in App Store Connect and Google Play Console.
- Test purchases in sandbox/internal test tracks.
- Add production receipt validation endpoint or managed entitlement provider.
- Release-sign Android and iOS builds.

Build 7 should still be materially stronger than Build 6 because the app no longer claims a monthly subscription while preserving a permanent local unlock.
