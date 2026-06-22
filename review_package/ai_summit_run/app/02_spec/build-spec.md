# Gimme Build Spec

## Build Target
- Official product target: Android/iOS native mobile app
- Current delivery: Flutter Web public HTTPS preview for smartphone verification
- Local project path: `C:\dev\summit_2026_06_25_frame2_genre_002`

## Product Goal
Gimme helps a household see possible missed benefits, deductions, refunds, cancellation savings, and application deadlines. The preview must make the core loop tangible:

1. Check household conditions.
2. See likely reclaim opportunities sorted by amount and urgency.
3. Open a reclaim quest.
4. Complete preparation steps.
5. See recovered/claimable amount and subscription value.

## Required Screens
- Dashboard: current month claimable amount, completed amount, urgent deadlines, household summary.
- Opportunities: list of reclaim opportunities with amount, deadline, confidence, category, status.
- Quest Detail: step checklist, required documents, next action, status.
- Household: editable demo household profile that changes matching logic.
- Insights/Plan: recovered amount, upcoming deadlines, premium/subscription rationale.

## UX Rules
- Mobile-first at 375px.
- Must not look like an AI chatbot or generic dashboard.
- Use consumer-fintech trust cues: clear amounts, dates, progress, plain labels.
- Use mock data only; do not claim real eligibility or real filing.
- Show legal/safety caveat subtly: "申請前に自治体/専門家情報で確認".

## Data / State
- Use local persistence for completed quest steps and household profile.
- Use plausible mock opportunities.
- Matching can be deterministic rules based on household fields.

## Verification
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build web`
- Mobile-width browser check when possible
- Public HTTPS preview if hosting credentials are available
