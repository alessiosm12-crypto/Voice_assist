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
4. Click `Done`.
5. Paste the copied text anywhere with `Ctrl+V`.

Inside the dictation window, `Ctrl+Shift+M` toggles recognition. The `Start dictation` button is still available as a fallback if the browser blocks automatic start.

## Notes

- Voice recognition uses the browser Web Speech API.
- Use Google Chrome or Microsoft Edge.
- The final text is copied to the clipboard; automatic insertion into other apps is intentionally disabled.
