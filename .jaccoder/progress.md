# Project: JacPlay
## Status: DONE
## Plan
1. [x] Audit source for critical bugs, dead code, and duplicate legacy files.
2. [x] Fix prompt enhancement, browser API guards, and brittle page logic.
3. [x] Remove unused legacy backend/route files and simplify endpoint registration.
4. [x] Validate Jac syntax/types, run app, and verify browser render.
## Files
- `main.jac` — kept endpoint registration clean and aligned with active service modules.
- `pages/play.jac` — fixed prompt enhancement input and session cleanup logic.
- `components/chat_message.cl.jac` — safer copy flow, safer markdown rendering, fixed edit input event access.
- `pages/index.jac` — guarded browser-only window usage.
- `services/chat_service.jac` / `services/model_registry.jac` — reduced to active compatibility facades only.
## Issues
- Prompt enhancement was receiving session objects instead of message objects.
- Legacy impl files and duplicate not-found route were dead code and removed.
- Client code used unguarded browser globals (`navigator`, `window`, `setTimeout`).
## Learnings
- Keep one active backend surface and remove stale impl files quickly to avoid drift.
- Guard browser APIs in Jac client code to prevent blank-page/runtime failures.
- Sanitizing model output before markdown rendering is a safer default.
## Last Action
Validated syntax, restarted the app, and confirmed `/play` renders successfully at `http://127.0.0.1:8001/play`.