# Gimme Completion Note

## Completed App
- Title: Gimme
- Selected finalist: 1
- Saved future plan: 3 / NoMan
- Genre: AI生活補助
- Frame: ② 斬新/未来需要/独創性主体
- Builder: Codex
- Current version: 1.2.0+7

## App Summary
Gimme is a household reclaim assistant. It scans a family's likely missed money opportunities, such as benefits, deductions, refunds, subscription leaks, and move-related rebates, then turns each one into a quest with documents, steps, deadlines, and estimated recovery amount.

The current completion-standard build focuses on a polished mobile-first experience: dashboard, opportunity list, AI statement scan, household profile editing, quest detail checklist, persisted progress, estimate ranges with visible basis, real deadline dates, separated prepared/actual recovery tracking, privacy/compliance surfaces, and a native-ready Gimme Plus subscription screen.

## 2026-06-22 Completion-Standard Rework
- Fixed the incorrect MVP framing after Shinchan's correction.
- Reworked the product logic so deadlines, city profiles, plan gating, subscription estimates, prepared value, actual recovered value, and AI statement scan are connected to the app state.
- Added tests covering deadline calculation, city-specific estimates, Plus gating, subscription math, prepared vs actual recovered value, and AI scan extraction.
- Cleaned Android/iOS app names, stale package directories, and review package cache exclusions.

## 2026-06-23 Build 7 Status
- Build 7 fixes the remaining app-side subscription lifecycle blocker from Build 6.
- Store Plus now has a bounded 32-day entitlement window, 5-day restore refresh, expiry lockout, legacy unverified lockout, purchase-state messaging, and cancellation guidance.
- Verification passed: `flutter analyze`, `flutter test` with 17 tests, `flutter build web`, and `flutter build apk --debug`.
- Public preview reports `1.2.0+7` and passed mobile-width visual verification.
- Claude/Chloe rereview judged the app a `ship candidate` for closed/internal test track, not yet public paid GA.
- Public paid GA still requires server-side receipt validation or managed entitlement verification, signed release builds, store product creation, real test-device purchase flow, and one stronger monthly retention/differentiation lever.

## Files
- App project: `C:\dev\summit_2026_06_25_frame2_genre_002`
- Android debug APK: `C:\dev\summit_2026_06_25_frame2_genre_002\build\app\outputs\flutter-apk\app-debug.apk`
- Final champion spec: `C:\Users\Rig5070\Documents\AI_Summits\ai-summit\runs\2026-06-25_frame2-genre-002\final\final_champion_spec.md`
- Saved future plan: `C:\Users\Rig5070\Documents\AI_Summits\ai-summit\runs\2026-06-25_frame2-genre-002\final\noman_saved_plan.md`
- QA report: `C:\Users\Rig5070\Documents\AI_Summits\ai-summit\runs\2026-06-25_frame2-genre-002\app\04_reports\qa-report.md`
- Claude follow-up report: `C:\Users\Rig5070\Documents\AI_Summits\ai-summit\runs\2026-06-25_frame2-genre-002\app\04_reports\claude-review-followup.md`
- Claude rereview: `C:\Users\Rig5070\Documents\AI_Summits\ai-summit\runs\2026-06-25_frame2-genre-002\app\04_reports\claude-rereview-20260622.md`
- Claude Build 7 rereview: `C:\Users\Rig5070\Documents\AI_Summits\ai-summit\runs\2026-06-25_frame2-genre-002\app\04_reports\claude-rereview-build7-20260623.md`

## Preview
- Public HTTPS preview: https://new31005.github.io/ai-summit-gimme-20260622/
- Public repository: https://github.com/NEW31005/ai-summit-gimme-20260622
