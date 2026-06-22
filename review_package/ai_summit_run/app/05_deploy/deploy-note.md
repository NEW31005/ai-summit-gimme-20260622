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
