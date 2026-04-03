"""Root layout — sticky navbar + theme toggle."""

cl import from "@jac/runtime" { Outlet, Link }
cl import from "lucide-react" { Sun, Moon, Key, Github, Play }
cl import from ..store.app_store { AppProvider, useAppStore }
cl import from ..store.chat_store { ChatProvider }
cl import from ..components.api_key_modal { ApiKeyModal }

cl {
    glob PROVIDERS = [
        {"id": "openai",    "name": "OpenAI",      "description": "GPT-4o, o4-mini, GPT-4.1 and more",        "color": "#10a37f", "key_placeholder": "sk-proj-...",      "key_help_text": "Get your key at platform.openai.com/api-keys", "key_help_url": "https://platform.openai.com/api-keys"},
        {"id": "anthropic", "name": "Anthropic",   "description": "Claude Opus 4.6, Sonnet 4.6, Haiku 4.5",   "color": "#e07842", "key_placeholder": "sk-ant-api03-...", "key_help_text": "Get your key at console.anthropic.com",          "key_help_url": "https://console.anthropic.com/settings/keys"},
        {"id": "google",    "name": "Google AI",   "description": "Gemini 2.5 Pro, Flash and more",            "color": "#4285f4", "key_placeholder": "AIzaSy...",        "key_help_text": "Free key at aistudio.google.com",               "key_help_url": "https://aistudio.google.com/app/apikey"},
        {"id": "deepseek",  "name": "DeepSeek",    "description": "DeepSeek R1 and V3 models",                 "color": "#0ea5e9", "key_placeholder": "sk-...",           "key_help_text": "Get your key at platform.deepseek.com",         "key_help_url": "https://platform.deepseek.com/api_keys"},
        {"id": "mistral",   "name": "Mistral AI",  "description": "Mistral Large, Small, Codestral",           "color": "#ff7000", "key_placeholder": "...",              "key_help_text": "Get your key at console.mistral.ai",            "key_help_url": "https://console.mistral.ai/api-keys"},
        {"id": "groq",      "name": "Groq",        "description": "Llama 3.3, Gemma at blazing speed",         "color": "#f97316", "key_placeholder": "gsk_...",          "key_help_text": "Free key at console.groq.com/keys",             "key_help_url": "https://console.groq.com/keys"},
        {"id": "cohere",    "name": "Cohere",      "description": "Command R+ and Command models",             "color": "#39594d", "key_placeholder": "...",              "key_help_text": "Free key at dashboard.cohere.com",              "key_help_url": "https://dashboard.cohere.com/api-keys"}
    ];

    def NavBar(props: Any) -> JsxElement {
        store = useAppStore();
        showKeys = props["showKeys"];
        setShowKeys = props["setShowKeys"];
        isDark = store["isDark"];

        return <header className="navbar-root sticky top-0 z-40 h-14 flex-shrink-0">
            <div className="max-w-screen-xl mx-auto px-5 h-full flex items-center justify-between">
                <div className="flex items-center gap-6">
                    <Link to="/" className="flex items-center gap-2.5 hover:opacity-90 transition-opacity">
                        <div className="brand-logo w-8 h-8 rounded-xl flex items-center justify-center shadow-lg">
                            <Play size={13} className="text-white fill-white ml-0.5"/>
                        </div>
                        <span className="font-bold text-lg tracking-tight leading-none brand-wordmark">{"JacPlay"}</span>
                    </Link>
                    <nav className="hidden sm:flex items-center gap-0.5">
                        <Link to="/" className="px-3.5 py-2 rounded-lg text-sm font-medium text-muted-foreground hover:text-foreground hover:bg-muted/70 transition-colors">
                            {"Home"}
                        </Link>
                        <Link to="/play" className="px-3.5 py-2 rounded-lg text-sm font-medium text-muted-foreground hover:text-foreground hover:bg-muted/70 transition-colors">
                            {"Playground"}
                        </Link>
                    </nav>
                </div>
                <div className="flex items-center gap-1">
                    <button
                        onClick={lambda() -> None { setShowKeys(not showKeys); }}
                        className="flex items-center gap-2 px-3.5 py-2 rounded-lg text-sm font-medium text-muted-foreground hover:text-foreground hover:bg-muted transition-colors"
                        title="Manage API Keys"
                    >
                        <Key size={14}/>
                        <span className="hidden sm:inline">{"Keys"}</span>
                    </button>
                    <a
                        href="https://github.com/jaseci-labs"
                        target="_blank"
                        rel="noopener noreferrer"
                        className="hidden sm:flex items-center gap-2 px-3.5 py-2 rounded-lg text-sm font-medium text-muted-foreground hover:text-foreground hover:bg-muted transition-colors"
                    >
                        <Github size={14}/>
                        <span>{"GitHub"}</span>
                    </a>
                    <button
                        onClick={store["toggleTheme"]}
                        className="p-2.5 rounded-lg text-muted-foreground hover:text-foreground hover:bg-muted transition-colors ml-0.5"
                        title={isDark and "Switch to light mode" or "Switch to dark mode"}
                    >
                        {isDark and <Sun size={16}/> or <Moon size={16}/>}
                    </button>
                </div>
            </div>
        </header>;
    }

    def Shell(props: Any) -> JsxElement {
        has showKeys: bool = False;

        return <div className="min-h-screen flex flex-col bg-background text-foreground">
            <NavBar
                showKeys={showKeys}
                setShowKeys={lambda(_: Any) -> None { showKeys = not showKeys; }}
            />
            <div className="flex-1 flex flex-col">
                <Outlet/>
            </div>
            {showKeys and
                <ApiKeyModal
                    providers={PROVIDERS}
                    onClose={lambda() -> None { showKeys = False; }}
                />
            }
        </div>;
    }

    def:pub layout -> JsxElement {
        return <AppProvider>
            <ChatProvider>
                <Shell/>
            </ChatProvider>
        </AppProvider>;
    }
}
