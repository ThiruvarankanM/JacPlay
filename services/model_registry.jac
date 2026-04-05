import from services.model_registry_svc { get_all_models, get_categories, search_models }
import from services.provider_catalog { get_providers }

def:pub fetch_model_catalog() -> dict {
    return {
        "ok": True,
        "models": get_all_models(),
        "categories": get_categories(),
        "providers": get_providers()
    };
}

def:pub search_model_catalog(query: str = "", category: str = "", provider: str = "") -> dict {
    return {
        "ok": True,
        "models": search_models(query, category, provider),
        "categories": get_categories(),
        "providers": get_providers()
    };
}
