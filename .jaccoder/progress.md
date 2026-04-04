# JacPlay progress

## Plan
1. Repair shared app store so homepage and play page read/write the same API key and theme state.
2. Add API key validation flow in the key modal and quick prompt using `validate_api_key`.
3. Verify key rows support save, change, and remove after successful validation.
4. Start the app and browser-validate the UI, then do a focused modal interaction check.

## Files touched
- `store/app_store.cl.jac`
- `components/api_key_modal.cl.jac`

## Issues / constraints
- Must avoid `.jac/` compiled output.
- Jac frontend tooling blocks direct React imports, so the app store was repaired using Jac client state patterns instead of React context.
- Existing `chat_store.cl.jac` still uses direct React imports, but this task is focused on app store/key management unless build validation forces broader fixes.

## Learnings
- Jac docs require `jac_docs()` before code changes because older React-style patterns are often invalid.
- Shared client state can be exposed through a module-level `glob` updated by a provider component when React context is unavailable.
- `sv import` validation calls from `.cl.jac` should use positional args and async handlers.
- Store functions returned from `useAppStore()` are safest to access with dict indexing (`store["setApiKey"]`) for consistency across pages/components.
