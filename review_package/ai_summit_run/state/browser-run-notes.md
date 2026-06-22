# Browser Run Notes

## Manual Run
- Automation did not trigger; this was run manually from Codex.
- Run path: `C:\Users\Rig5070\Documents\AI_Summits\ai-summit\runs\2026-06-25_frame2-genre-002`
- Topic: Frame 2 / AI生活補助

## Prompt Handling
- Round 1 used the normal generated prompt.
- Round 2 full prompt with raw evidence was stored locally, but browser submission used a compact prompt because ChatGPT long input was unstable.
- Round 3 and Round 4 used compact evidence summaries.

## Provider Notes
- ChatGPT: long prompt handling required compression for Round 2.
- Claude: contenteditable input did not reliably expose inserted text to DOM inspection; native typing fallback worked.
- Gemini: send button sometimes failed or delayed; Enter/retry prompt resolved it.
- Grok: response extraction sometimes included prompt echoes; files were cleaned after capture.

## Output
- Final Shinchan decision packet: `final/top5_for_shinchan.md`
- Mahime bridge packet: `final/openclaw_mahime_message.md`
