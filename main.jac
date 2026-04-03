"""JacPlay — AI Model Playground. App entry + REST API endpoints."""

import from http { HTTPMethod }
import from services.chat_service { send_chat_message, validate_api_key }
import from services.model_registry { get_all_models, get_categories, get_providers, search_models }

cl import "./global.css";

cl {
    """App shell — wraps children in themed container."""
    def:pub app(props: dict) -> JsxElement {
        return <div className="min-h-screen bg-background text-foreground">{props.children}</div>;
    }
}


"""GET /api/models — return full model catalog."""
@restspec(method=HTTPMethod.GET, path="/api/models")
def:pub api_get_models() -> dict {
    models = get_all_models();
    categories = get_categories();
    providers = get_providers();
    return {"ok": True, "data": {"models": models, "categories": categories, "providers": providers}};
}


"""GET /api/models/search — server-side search/filter."""
@restspec(method=HTTPMethod.GET, path="/api/models/search")
def:pub api_search_models(query: str = "", category: str = "", provider: str = "") -> dict {
    models = search_models(query=query, category=category, provider=provider);
    return {"ok": True, "data": {"models": models}};
}


"""POST /api/chat — proxy message to any model via its provider."""
@restspec(method=HTTPMethod.POST, path="/api/chat")
def:pub api_chat(
    model_id: str = "",
    messages: list = [],
    api_key: str = "",
    provider: str = "openai",
    system_prompt: str = ""
) -> dict {
    if not model_id {
        return {"ok": False, "error": "model_id is required", "code": "MISSING_INPUT"};
    }
    if not api_key {
        return {"ok": False, "error": "api_key is required", "code": "MISSING_KEY"};
    }
    if not messages {
        return {"ok": False, "error": "messages is required", "code": "MISSING_INPUT"};
    }
    return send_chat_message(model_id, messages, api_key, provider, system_prompt);
}


"""POST /api/validate-key — check if an API key is valid for a provider."""
@restspec(method=HTTPMethod.POST, path="/api/validate-key")
def:pub api_validate_key(
    provider: str = "",
    api_key: str = ""
) -> dict {
    if not provider or not api_key {
        return {"ok": False, "error": "provider and api_key are required", "code": "MISSING_INPUT"};
    }
    return validate_api_key(provider, api_key);
}
