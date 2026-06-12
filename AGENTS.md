# AGENTS.md

## Project Overview

Voice assist is a small local Windows utility for Russian voice dictation. It opens a compact browser window, starts speech recognition automatically, shows the transcript in near real time, formats the recognized Russian text, copies the final result to the clipboard, and lets the user paste it into Codex or any other application manually.

The project intentionally uses a clipboard-first flow. It does not try to inject text directly into other applications, because earlier attempts were unreliable across windows and focus states.

## Technologies And Architecture

- Frontend: one standalone `voice-assist.html` file with HTML, CSS, and browser JavaScript.
- Speech recognition: browser Web Speech API through `SpeechRecognition` / `webkitSpeechRecognition`.
- Runtime shell: PowerShell scripts and small `.cmd` launchers for Windows.
- Local backend: `serve-voice-assist.ps1` runs a minimal `HttpListener` server on port `57832`.
- Clipboard integration: PowerShell uses `System.Windows.Forms.Clipboard` from an STA process.
- Hotkey listener: `Voice assist hotkey.ps1` registers a native Windows `Ctrl+Alt+D` hotkey through a small embedded C# `NativeWindow`.
- Browser launch: `start-voice-assist.ps1` starts Chrome in app mode when available, otherwise falls back to Edge or the default browser.

Architectural principles:

- Keep the project dependency-free and easy to run on Windows.
- Keep user-facing behavior local: no external services, no cloud API calls, no server beyond localhost.
- Prefer a small number of explicit scripts over build tooling.
- Keep dictation, formatting, and UI logic in the HTML file unless a real complexity threshold justifies extraction.
- Prefer clipboard copy over automatic insertion into arbitrary applications.

## Project Structure

- `voice-assist.html`: main user interface, dark theme, Web Speech API integration, hotkeys inside the dictation window, transcript editing, Russian text formatting, and `/copy` request on Done.
- `serve-voice-assist.ps1`: local HTTP server that serves `voice-assist.html` and handles `POST /copy` by writing text to the Windows clipboard.
- `start-voice-assist.ps1`: restarts the local server, waits briefly, and opens the dictation window in the browser.
- `Voice assist.cmd`: user-facing launcher for `start-voice-assist.ps1`.
- `Voice assist hotkey.ps1`: long-running global hotkey listener for `Ctrl+Alt+D`.
- `Voice assist hotkey.cmd`: launcher for the hotkey listener.
- `install-voice-assist.ps1`: creates or refreshes the desktop shortcut and Startup shortcut, then restarts the hotkey listener.
- `README.md`: user documentation for installation, usage, and behavior notes.
- `AGENTS.md`: living project knowledge base and development instructions for future agents.

There are no source subdirectories at the moment. Keep the flat structure unless the project grows enough to make grouping useful.

## Existing Documentation And Decision Files

- `README.md`: public/user-facing documentation. It explains installation, launch flow, controls, browser requirements, Russian auto-formatting, and clipboard behavior.
- `AGENTS.md`: internal development guide and evolving knowledge base.

No ADR files, architecture notes, changelog, or separate decision logs currently exist.

When functionality changes, update the related documentation in the same task:

- Update `README.md` for user-visible behavior, installation, controls, requirements, or limitations.
- Update `AGENTS.md` when architecture, project rules, testing approach, user preferences, or project learnings change.
- Add a dedicated decision note or ADR only if a future architectural decision becomes too large to preserve clearly in `AGENTS.md`.

## Development And Coding Rules

- Preserve UTF-8 text in HTML and Markdown files. The UI contains Russian text; inspect files with UTF-8-aware commands when needed.
- Keep PowerShell scripts compatible with Windows PowerShell. Avoid assuming PowerShell 7-only features.
- Clipboard work must happen from an STA-capable process.
- Keep the local server bound to localhost / `127.0.0.1`; do not expose it externally.
- Keep port `57832` unless there is a strong reason to change it, and update all launch/documentation references if it changes.
- Avoid adding package managers, bundlers, frameworks, or npm dependencies unless the project clearly outgrows the current simple shape.
- Do not reintroduce automatic text insertion into Codex or other apps. The accepted product behavior is copy-to-clipboard followed by manual paste.
- Do not replace dictated words during auto-formatting. Formatting may normalize spaces, punctuation, capitalization, sentence boundaries, and commas only.
- Keep window-level keyboard shortcuts from interfering with manual editing: when the transcript field is focused and editable, normal text editing should win.
- Preserve both regular `Enter` and numpad `Enter` support for Done when focus is not inside the editable transcript.
- Keep `Space` as the pause/start toggle inside the dictation window, while allowing literal spaces during manual transcript editing.
- If scripts are renamed or moved, update launchers, shortcuts, installer logic, README, and this file together.

## New Feature Design Rules

- Start from the user's actual workflow: open with hotkey, dictate immediately, pause/edit when needed, press Done, paste manually.
- Favor direct controls and predictable keyboard behavior over hidden state.
- For UI changes, keep the dark compact tool design. Avoid landing pages, decorative sections, or large explanatory text inside the app.
- New features should not require network access beyond browser speech recognition support.
- Any text-processing feature must be conservative: prefer fewer changes over surprising rewrites.
- Russian punctuation formatting is heuristic. Treat it as assistive cleanup, not as a full grammar engine.
- If adding more language intelligence, keep a clear switch or boundary so the app does not silently change user wording.
- If adding more endpoints to the local server, keep them narrow, local-only, and documented.

## Testing Requirements

There is no automated test suite currently.

For every meaningful change, perform at least these checks:

- Run `git diff --check`.
- Verify the local page responds: `Invoke-WebRequest -UseBasicParsing http://127.0.0.1:57832/`.
- If the server is not running, start the app through `Voice assist.cmd` or `start-voice-assist.ps1` and repeat the check.
- For UI or keyboard changes, manually verify in Chrome or Edge:
  - `Ctrl+Alt+D` opens the window through the hotkey listener.
  - Dictation starts automatically when the window opens.
  - `Space` toggles pause/start outside transcript editing.
  - Manual editing works while paused.
  - Regular `Enter` and numpad `Enter` run Done when the transcript field is not focused.
  - Done copies formatted text to the clipboard and closes the window.
- For Russian formatting changes, test representative phrases for:
  - sentence capitalization;
  - soft sentence splitting;
  - commas before adversative conjunctions;
  - introductory words;
  - compound subordinating conjunctions such as `потому что` and `перед тем как`;
  - no replacement of dictated words.

If a check cannot be run, say so explicitly in the final response and explain the remaining risk.

## Documentation Requirements

- Keep `README.md` concise and user-facing.
- Keep `AGENTS.md` practical and project-specific; do not let it become generic boilerplate.
- Update documentation in the same change as code when behavior changes.
- Mention user-visible keyboard shortcuts, browser requirements, clipboard behavior, and limitations.
- When adding scripts, endpoints, launch modes, or installation steps, document their purpose.
- When changing Russian formatting rules, document the level of support as heuristic rather than perfect grammar parsing.

## User Preferences

- The user prefers practical implementation over long planning and expects Codex to make the change, test it, and push when appropriate.
- The user iterates through hands-on feedback: "doesn't insert", "works", "remove this", "rename this", "make it darker", and similar direct adjustments.
- The accepted workflow is clipboard-based: after Done, text is copied and the user pastes it manually into any target window.
- The user values hotkey-driven operation and minimal mouse use.
- The user prefers Russian-language behavior and Russian text formatting that follows common Russian punctuation norms.
- The user prefers a modern dark UI without unnecessary hints or clutter.
- The user wants the project kept clean: English folder/project naming, only necessary files, and GitHub-ready contents.
- The user wants project knowledge to accumulate in documentation after meaningful tasks.

## Project Learnings

- Direct insertion into the Codex window was unreliable, so the project moved to a robust copy-to-clipboard model.
- Global `Ctrl+Alt+D` is implemented independently from Windows shortcut hotkeys via `RegisterHotKey`, because desktop shortcut hotkeys were not reliable enough by themselves.
- The hotkey listener must be installed into Startup and kept running for global launch behavior.
- Moving the project folder can break shortcuts and hotkey paths; rerun `install-voice-assist.ps1` after moving the folder.
- Web Speech API support requires Chrome or Edge and may block automatic start in some browser states; the Start button remains as a fallback.
- Numpad Enter must be handled explicitly with `event.code === "NumpadEnter"` in addition to normal Enter behavior.
- Manual editing is allowed only while paused; while recording, the transcript is read-only to avoid conflicts with live recognition updates.
- Russian punctuation uses regex-based heuristics. JavaScript `\b` is unreliable for Cyrillic word boundaries, so punctuation rules should use explicit whitespace/end/punctuation lookaheads instead.
- Compound conjunctions need protection before applying single-word subordinate rules, otherwise phrases like `потому что` can become incorrectly split as `потому, что`.
- Node.js is not installed on the user's machine at the time of writing, so avoid requiring Node-based tooling unless explicitly introduced and documented.

## Ongoing Task Checklist

After each significant task:

1. Check whether `README.md` needs an update.
2. Check whether `AGENTS.md` needs an update.
3. Update `User Preferences` when the user's behavior or preferences become clearer.
4. Update `Project Learnings` when a technical decision, limitation, or fix becomes reusable knowledge.
5. Run the relevant checks from `Testing Requirements`.
6. Briefly summarize changed files, checks performed, and any skipped checks.
