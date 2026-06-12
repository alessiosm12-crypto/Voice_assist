# Voice assist

Voice assist opens a small dictation window with `Ctrl+Alt+D`.

## Install or refresh the hotkey

```powershell
.\install-voice-assist.ps1
```

## Use

1. Press `Ctrl+Alt+D`.
2. Dictation starts automatically when the window opens.
3. Dictate text.
4. Click `Done` to review locally checked punctuation.
5. Edit the preview if needed, then click `Copy`.
6. Paste the copied text anywhere with `Ctrl+V`.

Inside the dictation window, `Space` toggles recognition. When paused, the transcript field becomes editable. `Enter` or numpad `Enter` runs `Done` when the transcript field is not focused. In the review step, `Enter` or numpad `Enter` copies the reviewed text when the transcript field is not focused. The `Start dictation` button is still available as a fallback if the browser blocks automatic start.

Voice assist automatically formats Russian text: it normalizes spacing, adds sentence punctuation, capitalizes sentence starts, and adds basic commas for common Russian punctuation patterns: introductory words, adversative conjunctions, explanatory turns, compound subordinating conjunctions, subordinate clauses, and `который` forms. Short recognized fragments are joined softly with commas or spaces instead of being split into many tiny sentences. It does not replace dictated words.

Before copying, Voice assist shows a review step with an additional local punctuation pass. This check is heuristic and runs only in the browser; it does not send text to external grammar or AI services.

Voice assist also has a local user dictionary for names, companies, and domain terms. Pause dictation, select the corrected word or phrase in the transcript, then click `В словарь`. Saved terms are stored in this browser with `localStorage` and are used as conservative post-processing for similar recognized words. This does not train or change the browser Web Speech API model.

## Notes

- Voice recognition uses the browser Web Speech API.
- Use Google Chrome or Microsoft Edge.
- The final text is copied to the clipboard; automatic insertion into other apps is intentionally disabled.
