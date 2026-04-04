# JacPlay

JacPlay is a multi-model chat playground built with Jac. It lets you compare answers from different providers side by side, using your own API keys.

## What It Does

- Browse a built-in catalog of models.
- Add one or more models to the playground.
- Store API keys locally in your browser.
- Send the same prompt to multiple models at once.
- Compare the replies in parallel.

## Quick Start

```bash
pip install jaseci
cd /path/to/JacPlay
jac start main.jac
```

Open the app at `http://localhost:8000`.

If you do not see models at first, make sure you started Jac from the folder that contains `jac.toml`.

## First Run

1. Open the Playground page.
2. Click `Add Model`.
3. Pick a provider and save your API key.
4. Select a model and send a message.

API keys stay in your browser. They are not stored in the repo.

## Project Layout

- `main.jac` - app entry point and API endpoints.
- `pages/` - page routes and the main playground UI.
- `components/` - shared UI pieces such as the model picker, chat panel, and key modal.
- `store/` - client state for app settings and chat sessions.
- `services/` - model registry and provider routing logic.
- `data/` - static model/provider data used by the app.
- `.jac/client/compiled/` - generated client output. Do not edit these files directly.

## How It Works

1. The UI loads the model catalog from the backend.
2. A model selection creates a chat session for that provider.
3. When you send a message, Jac routes the request to the right provider implementation.
4. The provider response is shown in the chat panel.
5. If you open more than one model, Jac sends the same prompt to all active sessions in parallel.

## Adding Models

The source of truth for available models is `services/model_registry_svc.sv.jac`.

Add a model there, then restart the app. The model picker reads from that registry.

## Adding Providers

Provider-specific request handling lives in `services/impl/chat_service.impl.jac`.

To add a new provider, add its request/response mapping there and register it in the model list.

## Local Data

- API keys are stored in browser localStorage.
- Theme preference is also stored locally.
- Chat history stays in memory while the page is open.

## Development Notes

- Run `jac start main.jac` from the JacPlay project root.
- Use the browser Network tab to inspect model and chat requests.
- If you change `.jac` files, restart the server so the client bundle rebuilds.

## Tech Stack

- Jac
- React 18
- React Router
- Vite
- Tailwind CSS
- markdown rendering for chat messages

## License

MIT
