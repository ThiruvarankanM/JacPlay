sv import from ..services.provider_catalog { fetch_providers }

cl {
    glob __jacplay_app_store: Any = None;

    def safeGetItem(key: str) -> Any {
        if typeof(window) == "undefined" or not window.localStorage {
            return None;
        }
        return window.localStorage.getItem(key);
    }

    def safeSetItem(key: str, value: str) -> None {
        if typeof(window) == "undefined" or not window.localStorage {
            return;
        }
        window.localStorage.setItem(key, value);
    }

    def getInitialTheme -> bool {
        stored = safeGetItem("jacplay_theme");
        if stored == "dark" { return True; }
        if stored == "light" { return False; }
        if typeof(window) != "undefined" and window.matchMedia {
            return bool(window.matchMedia("(prefers-color-scheme: dark)").matches);
        }
        return False;
    }

    def getStoredKeys -> Any {
        raw = safeGetItem("jacplay_api_keys");
        if not raw {
            return {};
        }
        try {
            parsed = JSON.parse(raw);
            return parsed or {};
        } except Exception {
            return {};
        }
    }

    def:pub AppProvider(props: Any) -> JsxElement {
        has isDark: bool = False;
        has apiKeys: Any = {};
        has providers: Any = [];
        has hydrated: bool = False;

        def applyTheme(dark: bool) -> None {
            if typeof(document) == "undefined" {
                return;
            }
            root = document.documentElement;
            if dark {
                root.classList.remove("light");
                root.classList.add("dark");
                root.style.colorScheme = "dark";
            } else {
                root.classList.remove("dark");
                root.classList.add("light");
                root.style.colorScheme = "light";
            }
        }

        def syncStoreSnapshot -> None {
            __jacplay_app_store = {
                "isDark": isDark,
                "toggleTheme": toggleTheme,
                "setTheme": setTheme,
                "apiKeys": apiKeys,
                "providers": providers,
                "setApiKey": setApiKey,
                "removeApiKey": removeApiKey,
                "hasKey": hasKey,
                "getKey": getKey,
                "hydrated": hydrated
            };
        }

        async can with entry {
            isDark = getInitialTheme();
            apiKeys = getStoredKeys();
            try {
                providers = await fetch_providers() or [];
            } except Exception {
                providers = [];
            }
            hydrated = True;
            applyTheme(isDark);
            syncStoreSnapshot();
        }

        can with [isDark] entry {
            if not hydrated { return; }
            applyTheme(isDark);
            safeSetItem("jacplay_theme", isDark and "dark" or "light");
            syncStoreSnapshot();
        }

        can with [apiKeys] entry {
            if not hydrated { return; }
            safeSetItem("jacplay_api_keys", JSON.stringify(apiKeys or {}));
            syncStoreSnapshot();
        }

        def toggleTheme -> None {
            isDark = not isDark;
        }

        def setTheme(mode: str) -> None {
            isDark = mode == "dark";
        }

        def setApiKey(provider: str, key: str) -> None {
            cleanProvider = provider.strip();
            cleanKey = key.strip();
            if not cleanProvider or not cleanKey {
                return;
            }
            nextKeys = {**(apiKeys or {})};
            nextKeys[cleanProvider] = cleanKey;
            apiKeys = nextKeys;
        }

        def removeApiKey(provider: str) -> None {
            cleanProvider = provider.strip();
            nextKeys = {**(apiKeys or {})};
            if cleanProvider in nextKeys {
                nextKeys.pop(cleanProvider);
            }
            apiKeys = nextKeys;
        }

        def hasKey(provider: str) -> bool {
            return bool((apiKeys[provider] or "").trim());
        }

        def getKey(provider: str) -> str {
            return apiKeys[provider] or "";
        }

        syncStoreSnapshot();

        return props.children;
    }

    def:pub useAppStore() -> Any {
        return __jacplay_app_store or {
            "isDark": False,
            "toggleTheme": lambda() -> None {},
            "setTheme": lambda(mode: str) -> None {},
            "apiKeys": {},
            "providers": [],
            "setApiKey": lambda(provider: str, key: str) -> None {},
            "removeApiKey": lambda(provider: str) -> None {},
            "hasKey": lambda(provider: str) -> bool { return False; },
            "getKey": lambda(provider: str) -> str { return ""; },
            "hydrated": False
        };
    }
}
