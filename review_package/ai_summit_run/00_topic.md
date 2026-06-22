# AI Summit Topic

- Title: frame2-genre-002
- Date: 2026-06-25
- Summit mode: thursday_original
- Build slot: thursday
- Builder rule: Codex direct implementation
- Idea frame: ② original/future-demand
- Topic genre No: 2
- Topic genre: AI生活補助
- Frame rotation: 1,2,2,1,1,2,2 across scheduled app runs; not permanently tied to weekday.
- Topic pool: `references/topic-pool.md`
- Created by: manual automation start
- Schedule policy: previous-day 21:00 Mahime bridge Champion checkpoint; target-day 02:00 selection check, final spec, and app build kickoff
- Chat policy: one app equals one Codex chat; pause after the 21:00 Mahime handoff and resume the same chat at 02:00
- Topic reason: Frame 2 uses original/future-demand ideation.

## Topic

枠② / 斬新・未来需要・独創性主体の案。
ジャンル No.2: AI生活補助

このジャンルで、これから需要が増える行動、AI時代に変化する生活/仕事/人間関係、まだ一般化していない強い体験、生成AI・エージェント・多AI連携・自動化・パーソナライズだから成立する新しい価値を狙う。

技術難度、制作コスト、法務/安全性の精査は初期選考では主な減点にしない。リスクは記録しつつ、世に出たらヒットするか、継続収益が成立するか、他にない強さがあるかを最優先にする。

ビルド担当枠: thursday
ビルドルール: Codex direct implementation
正式リリース前提はAndroid/iOSネイティブモバイルアプリ。Flutter Webはスマホから確認するための公開HTTPSプレビューであり、正式なWebアプリリリースではない。


## Mari Operating Note

- Read `references/topic-pool.md` and `references/browser-model-selection.md` before browser operation.
- Use the highest already-available model in ChatGPT, Claude, Gemini, and Grok; do not buy paid add-ons without Shinchan approval.
- Record visible model options, paid gates, selected model, and reason in `state/model-selection.md`.
- Record login, quota, payment, CAPTCHA, and UI retrieval issues in `state/browser-run-notes.md`.
- Treat hit potential and recurring monetization as the first finalist criteria.
- AI-powered concepts are welcome: generative AI, agents, multi-AI workflows, personalization, automation, and AI-era behavior changes should be used aggressively when they strengthen the idea.
- The not-AI-generated-looking requirement applies to UI/copy/visual polish, not to whether the app uses AI.
- Do not over-filter early for technical difficulty, production cost, legal nuance, or safety review; record risks until Shinchan chooses.
- Produce five finalists and let Shinchan choose the Champion by number.
- Use the OpenClaw/Mahime AI-Summit bridge as the primary Champion selection route; Codex notification is only an optional mirror.
- Monday build slot uses the Claude Code native desktop app `Code` tab/session for the build; do not use Claude Code CLI unless Shinchan explicitly approves CLI/OAuth for that run. Thursday build slot uses Codex direct implementation by default.
- Build under `C:\dev\` as a Flutter app whose official release target is Android/iOS native; deploy Flutter Web only as a public HTTPS preview.
- Localhost-only delivery is not complete.
