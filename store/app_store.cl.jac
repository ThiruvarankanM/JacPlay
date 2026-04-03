"""Global app store — theme, API keys (localStorage), providers."""

cl import from "react" { createContext, useContext }

glob AppCtx: Any = createContext(None);

def:pub AppProvider(props: Any) -> JsxElement {
    # Theme: read from localStorage or detect system pref
    def getInitialTheme -> bool {
        stored = localStorage.getItem("jacplay_theme");
        if stored { return stored == "dark"; }
        return window.matchMedia and window.matchMedia("(prefers-color-scheme: dark)").matches or True;
    }

    has isDark: bool = getInitialTheme();

    # API keys per provider — stored in localStorage
    def getStoredKeys -> Any {
        raw = localStorage.getItem("jacplay_api_keys");
        if raw {
            parsed = JSON.parse(raw);
            return parsed;
        }
        return {};
    }

    has apiKeys: Any = getStoredKeys();

    # Apply initial theme class on html element
    def applyTheme(dark: bool) -> None {
        if dark {
            document.documentElement.classList.remove("light");
            document.documentElement.classList.add("dark");
        } else {
            document.documentElement.classList.remove("dark");
            document.documentElement.classList.add("light");
        }
    }

    # Call once to init
    applyTheme(isDark);

    def toggleTheme -> None {
        newDark = not isDark;
        isDark = newDark;
        applyTheme(newDark);
        localStorage.setItem("jacplay_theme", newDark and "dark" or "light");
    }

    def setApiKey(provider: str, key: str) -> None {
        current = getStoredKeys();
        current[provider] = key;
        localStorage.setItem("jacplay_api_keys", JSON.stringify(current));
        apiKeys = current;
    }

    def removeApiKey(provider: str) -> None {
        current = getStoredKeys();
        del current[provider];
        localStorage.setItem("jacplay_api_keys", JSON.stringify(current));
        apiKeys = current;
    }

    def hasKey(provider: str) -> bool {
        k = apiKeys[provider] or "";
        return k.length > 0;
    }

    def getKey(provider: str) -> str {
        return apiKeys[provider] or "";
    }

    store = {
        "isDark": isDark,
        "toggleTheme": toggleTheme,
        "apiKeys": apiKeys,
        "setApiKey": setApiKey,
        "removeApiKey": removeApiKey,
        "hasKey": hasKey,
        "getKey": getKey
    };

    return <AppCtx.Provider value={store}>{props.children}</AppCtx.Provider>;
}

def:pub useAppStore() -> Any {
    return useContext(AppCtx);
}
