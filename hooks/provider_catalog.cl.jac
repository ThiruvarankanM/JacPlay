cl import from ..store.app_store { useAppStore }

def:pub useProviderCatalog() -> dict {
    appStore = useAppStore();
    providers = appStore["providers"] or [];

    def getProviderById(providerId: str) -> Any {
        for p in providers {
            if p and p["id"] == providerId { return p; }
        }
        return {
            "id": providerId,
            "name": providerId,
            "description": "",
            "color": "#7c3aed",
            "key_placeholder": "...",
            "key_help_text": "Get your API key",
            "key_help_url": "#"
        };
    }

    return {
        "providers": providers,
        "getProviderById": getProviderById
    };
}
