# Claude Rereview Follow-up / 2026-06-22

## Position

Shinchan's correction was valid. The build target was not a verification MVP; it was a best-effort complete app. The previous defense of a lower bar was incorrect.

## Main Fixes

- `daysLeft` is no longer hardcoded. Deadlines are real `DateTime` values and remaining days are derived from the current date.
- City input is connected to local benefit profiles, source labels, and range changes.
- Free/Plus gating is functional. Free users see top candidates and blurred/teaser value; Plus unlocks all candidates, detailed basis, steps, and documents.
- Subscription saving estimates use monthly total, contract count, unused count, and stale months.
- Application-prepared amount and actual recovered amount are separate product concepts.
- AI statement scan now exists as a local parser/API-ready flow that extracts recurring charges and updates household subscription inputs.
- Android/iOS display names are `Gimme`; stale `com/example/gimme` folders were removed.
- Review package source sync excludes `.dart_tool`, `.gradle`, `.kotlin`, `.idea`, `.wrangler`, and `build`.

## Verification

- `flutter analyze`: pass
- `flutter test`: pass, 9 tests
- `flutter build web --base-href /ai-summit-gimme-20260622/`: pass
- `flutter build apk --debug`: pass
- Mobile visual QA: pass at 390 x 844 through Chrome DevTools emulation with no horizontal overflow

## Remaining Honest Limits

- Real government/tax data integrations are still not connected.
- Real in-app purchases are represented as a native-ready preview unlock, not store billing.
- The AI statement scan is local mock/API-ready logic, not a paid external LLM/API call.
