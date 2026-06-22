# Gimme Deploy Note

## Public Preview
- URL: https://new31005.github.io/ai-summit-gimme-20260622/
- Provider: GitHub Pages
- Repository: https://github.com/NEW31005/ai-summit-gimme-20260622
- Deploy source: `C:\dev\ai-summit-gimme-20260622-pages`
- Deploy command used: `gh repo create NEW31005/ai-summit-gimme-20260622 --public --source C:\dev\ai-summit-gimme-20260622-pages --remote origin --push`, then GitHub Pages enabled from `main` `/`.

## Important
The first Cloudflare temporary deploy appeared to succeed but later resolved to `100::` and failed external HTTPS checks, so it is not the delivery URL.

GitHub Pages required rebuilding Flutter Web with `--base-href /ai-summit-gimme-20260622/`. After republishing, mobile-width browser verification passed at 390 x 844.
