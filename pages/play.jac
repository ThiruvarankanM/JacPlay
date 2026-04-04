"""JacPlay — Main chat playground page."""

cl import from "lucide-react" {
    Plus, X, Send, Settings2, Key, MessageSquare,
    Trash2, ShieldCheck, AlertCircle
}
cl import from ..store.chat_store { useChatStore }
cl import from ..store.app_store { useAppStore }
cl import from ..components.chat_panel { ChatPanel }
cl import from ..components.model_picker { ModelPicker }
cl import from ..components.api_key_modal { ApiKeyModal, QuickKeyPrompt }
cl import from ..components.ui.button { Button }
cl import from ..components.ui.utils { cn }

cl {
    # Static provider metadata — must live inside cl{} to be compiled as client JS
    glob PROVIDERS = [
        {
            "id": "openai",
            "name": "OpenAI",
            "description": "GPT-4o, o4-mini, GPT-4.1 and more",
            "color": "#10a37f",
            "key_placeholder": "sk-proj-...",
            "key_help_text": "Get your key at platform.openai.com/api-keys",
            "key_help_url": "https://platform.openai.com/api-keys"
        },
        {
            "id": "anthropic",
            "name": "Anthropic",
            "description": "Claude Opus 4.6, Sonnet 4.6, Haiku 4.5",
            "color": "#e07842",
            "key_placeholder": "sk-ant-api03-...",
            "key_help_text": "Get your key at console.anthropic.com",
            "key_help_url": "https://console.anthropic.com/settings/keys"
        },
        {
            "id": "google",
            "name": "Google AI",
            "description": "Gemini 2.5 Pro, Flash and more",
            "color": "#4285f4",
            "key_placeholder": "AIzaSy...",
            "key_help_text": "Free key at aistudio.google.com",
            "key_help_url": "https://aistudio.google.com/app/apikey"
        },
        {
            "id": "deepseek",
            "name": "DeepSeek",
            "description": "DeepSeek R1 and V3 models",
            "color": "#0ea5e9",
            "key_placeholder": "sk-...",
            "key_help_text": "Get your key at platform.deepseek.com",
            "key_help_url": "https://platform.deepseek.com/api_keys"
        },
        {
            "id": "mistral",
            "name": "Mistral AI",
            "description": "Mistral Large, Small, Codestral",
            "color": "#ff7000",
            "key_placeholder": "...",
            "key_help_text": "Get your key at console.mistral.ai",
            "key_help_url": "https://console.mistral.ai/api-keys"
        },
        {
            "id": "groq",
            "name": "Groq",
            "description": "Llama 3.3, Gemma at blazing speed",
            "color": "#f97316",
            "key_placeholder": "gsk_...",
            "key_help_text": "Free key at console.groq.com/keys",
            "key_help_url": "https://console.groq.com/keys"
        },
        {
            "id": "cohere",
            "name": "Cohere",
            "description": "Command R+ and Command models",
            "color": "#39594d",
            "key_placeholder": "...",
            "key_help_text": "Free key at dashboard.cohere.com",
            "key_help_url": "https://dashboard.cohere.com/api-keys"
        }
    ];

    def getProviderById(providerId: str) -> dict {
        for p in PROVIDERS {
            if p["id"] == providerId { return p; }
        }
        return {"id": providerId, "name": providerId, "color": "#7c3aed", "key_placeholder": "...", "key_help_text": "Get your API key", "key_help_url": "#"};
    }

    def ModelTab(props: Any) -> JsxElement {
        session = props.session;
        isActive = props.isActive;
        onActivate = props.onActivate;
        onClose = props.onClose;
        hasKey = props.hasKey;

        model = session["model"];

        return <button
            onClick={lambda() -> None { onActivate(session["id"]); }}
            className={cn(
                "flex items-center gap-2 px-3 py-2 rounded-xl text-sm font-medium transition-all group flex-shrink-0 max-w-52",
                isActive and "tab-active" or "text-muted-foreground hover:text-foreground hover:bg-muted/80 border border-transparent"
            )}
        >
            <div
                className="w-5 h-5 rounded-full flex items-center justify-center text-white font-bold flex-shrink-0"
                style={{"backgroundColor": model["color"], "fontSize": "8px"}}
            >
                {(model["avatar"] or "A")[0]}
            </div>
            <span className="truncate">{model["short_name"] or model["name"]}</span>
            {session["isLoading"] and
                <span className="w-1.5 h-1.5 rounded-full bg-primary animate-pulse flex-shrink-0"/>
            }
            {not session["isLoading"] and not hasKey and
                <span className="w-1.5 h-1.5 rounded-full bg-destructive flex-shrink-0" title="API key missing"/>
            }
            {not session["isLoading"] and hasKey and session["error"] and
                <span className="w-1.5 h-1.5 rounded-full bg-amber-500 flex-shrink-0" title="Last request failed"/>
            }
            {not session["isLoading"] and hasKey and not session["error"] and session["messages"].length > 0 and
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 flex-shrink-0" title="OK"/>
            }
            <button
                onClick={lambda(e: Any) -> None {
                    e.stopPropagation();
                    onClose(session["id"]);
                }}
                className="ml-auto flex-shrink-0 opacity-0 group-hover:opacity-100 hover:text-destructive transition-all rounded-sm p-0.5"
            >
                <X size={10}/>
            </button>
        </button>;
    }

    def EmptyState(props: Any) -> JsxElement {
        onAddModel = props.onAddModel;

        return <div className="hero-bg flex-1 flex flex-col items-center justify-center text-center px-6 py-20 animate-fade-in bg-grid-pattern">
            <div className="animate-float mb-8">
                <div className="brand-logo-lg w-24 h-24 rounded-3xl flex items-center justify-center">
                    <MessageSquare size={38} className="text-white drop-shadow-md"/>
                </div>
            </div>
            <h2 className="text-2xl font-bold text-foreground mb-3 tracking-tight">{"Pick a model to start"}</h2>
            <p className="text-[0.9375rem] text-muted-foreground max-w-xs leading-relaxed mb-8">
                {"Compare GPT-4o, Claude, Gemini, DeepSeek and more — side by side in real time."}
            </p>
            <button
                onClick={onAddModel}
                className="btn-send flex items-center gap-2 px-6 py-3 rounded-xl text-white text-sm font-semibold"
            >
                <Plus size={17}/>
                {"Add your first model"}
            </button>
            <div className="flex flex-wrap justify-center gap-2 mt-8 max-w-sm">
                <span className="text-xs bg-muted/80 text-muted-foreground px-3 py-1.5 rounded-full font-medium border border-border/60">{"GPT-4o"}</span>
                <span className="text-xs bg-muted/80 text-muted-foreground px-3 py-1.5 rounded-full font-medium border border-border/60">{"Claude Opus 4.6"}</span>
                <span className="text-xs bg-muted/80 text-muted-foreground px-3 py-1.5 rounded-full font-medium border border-border/60">{"Gemini 2.5 Pro"}</span>
                <span className="text-xs bg-muted/80 text-muted-foreground px-3 py-1.5 rounded-full font-medium border border-border/60">{"DeepSeek R1"}</span>
                <span className="text-xs bg-muted/80 text-muted-foreground px-3 py-1.5 rounded-full font-medium border border-border/60">{"Mistral Large"}</span>
                <span className="text-[11px] bg-primary/15 text-primary px-3 py-1.5 rounded-full border border-primary/30 font-semibold">{"+ more"}</span>
            </div>
        </div>;
    }

    def InputBar(props: Any) -> JsxElement {
        chatStore = useChatStore();
        appStore = useAppStore();
        onAddModel = props.onAddModel;
        onOpenKeys = props.onOpenKeys;
        onKeyNeeded = props.onKeyNeeded;

        has showSystem: bool = False;
        has systemDraft: str = chatStore["systemPrompt"];

        def getMissingKeyProvider -> Any {
            sessions = chatStore["sessions"];
            for sess in sessions {
                provider = sess["model"]["provider"] or "openai";
                if not appStore.hasKey(provider) {
                    return getProviderById(provider);
                }
            }
            return None;
        }

        def handleSend -> None {
            text = chatStore["inputText"];
            if not text.trim() { return; }
            sessions = chatStore["sessions"];
            if sessions.length == 0 { return; }

            missingProvider = getMissingKeyProvider();
            if missingProvider {
                onKeyNeeded(missingProvider);
                return;
            }

            chatStore["sendMessage"](text, appStore.getKey);
        }

        def handleKeyDown(e: Any) -> None {
            if e.key == "Enter" and not e.shiftKey {
                e.preventDefault();
                handleSend();
            }
        }

        def saveSystemPrompt -> None {
            chatStore["updateSystemPrompt"](systemDraft);
            showSystem = False;
        }

        anyLoading = chatStore["sessions"].some(lambda(s: Any) -> bool { return s["isLoading"]; });
        hasSessions = chatStore["sessions"].length > 0;
        missingProv = getMissingKeyProvider();

        return <div className="input-bar flex-shrink-0">
            {showSystem and
                <div className="px-4 pt-3 border-b border-border">
                    <div className="flex items-center justify-between mb-2">
                        <span className="text-xs font-medium text-foreground flex items-center gap-1.5">
                            <Settings2 size={12} className="text-primary"/>
                            {"System Prompt"}
                        </span>
                        <div className="flex gap-1.5">
                            <Button size="sm" variant="ghost" onClick={lambda() -> None { showSystem = False; }}>{"Cancel"}</Button>
                            <Button size="sm" onClick={saveSystemPrompt}>{"Apply"}</Button>
                        </div>
                    </div>
                    <textarea
                        value={systemDraft}
                        onChange={lambda(e: Any) -> None { systemDraft = str(e["target"]["value"]); }}
                        placeholder="You are a helpful assistant..."
                        rows={3}
                        className="w-full rounded-lg border border-border bg-input px-3 py-2 text-xs text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring resize-none transition-colors mb-3"
                    />
                </div>
            }

            {missingProv and hasSessions and
                <div className="px-4 py-2 bg-amber-500/10 border-b border-amber-500/20 flex items-center justify-between gap-3">
                    <div className="flex items-center gap-2 text-xs text-amber-600 dark:text-amber-400">
                        <AlertCircle size={13}/>
                        <span>
                            <strong>{missingProv["name"]}</strong>
                            {" API key missing. Add it to send messages."}
                        </span>
                    </div>
                    <Button
                        size="sm"
                        variant="outline"
                        onClick={lambda() -> None { onKeyNeeded(missingProv); }}
                        className="text-xs flex-shrink-0"
                    >
                        <Key size={11}/>
                        {"Add Key"}
                    </Button>
                </div>
            }

            <div className="p-3 flex gap-2 items-end">
                <div className="flex gap-1 flex-shrink-0 pb-0.5">
                    <button
                        onClick={onAddModel}
                        className="p-2 rounded-lg text-muted-foreground hover:text-foreground hover:bg-muted transition-colors"
                        title="Add Model"
                    >
                        <Plus size={15}/>
                    </button>
                    <button
                        onClick={lambda() -> None { showSystem = not showSystem; systemDraft = chatStore["systemPrompt"]; }}
                        className={cn(
                            "p-2 rounded-lg transition-colors",
                            (chatStore["systemPrompt"] and chatStore["systemPrompt"].trim()) and "text-primary bg-primary/10" or "text-muted-foreground hover:text-foreground hover:bg-muted"
                        )}
                        title="System Prompt"
                    >
                        <Settings2 size={15}/>
                    </button>
                </div>

                <textarea
                    value={chatStore["inputText"]}
                    onChange={lambda(e: Any) -> None { chatStore["updateInputText"](str(e["target"]["value"])); }}
                    onKeyDown={handleKeyDown}
                    placeholder={hasSessions and "Message all models... (Enter to send, Shift+Enter for new line)" or "Add a model first to start chatting"}
                    disabled={not hasSessions or anyLoading}
                    rows={1}
                    className="flex-1 rounded-xl border border-border/80 bg-input px-4 py-3 text-[0.9375rem] text-foreground placeholder:text-muted-foreground/60 focus:outline-none focus:ring-2 focus:ring-ring resize-none disabled:opacity-40 transition-colors leading-relaxed"
                    style={{"minHeight": "46px", "maxHeight": "180px"}}
                />

                <button
                    onClick={handleSend}
                    disabled={not chatStore["inputText"].trim() or not hasSessions or anyLoading}
                    className="btn-send flex-shrink-0 w-11 h-11 rounded-xl flex items-center justify-center text-white"
                    title="Send"
                >
                    {anyLoading and
                        <span className="w-4 h-4 rounded-full border-2 border-white/60 border-t-white animate-spin"/>
                    }
                    {not anyLoading and <Send size={16}/>}
                </button>
            </div>

            <div className="px-4 pb-2 flex items-center justify-between">
                <p className="text-xs text-muted-foreground">
                    {hasSessions and
                        str(chatStore["sessions"].length) + " model" + (chatStore["sessions"].length != 1 and "s" or "") + " active"
                        or ""
                    }
                </p>
                <button
                    onClick={onOpenKeys}
                    className="flex items-center gap-1 text-xs text-muted-foreground hover:text-foreground transition-colors"
                >
                    <Key size={11}/>
                    {"Manage keys"}
                </button>
            </div>
        </div>;
    }

    def:pub page -> JsxElement {
        chatStore = useChatStore();
        appStore = useAppStore();

        has showPicker: bool = False;
        has showKeys: bool = False;
        has catalogModels: Any = [];
        has catalogCategories: Any = [];
        has catalogLoaded: bool = False;

        # Quick key prompt state — shown when a model is selected without its key
        has pendingModel: Any = None;
        has quickKeyProvider: Any = None;
        has showQuickKey: bool = False;

        def loadCatalog -> None {
            if catalogLoaded { return; }
            async def _fetch -> None {
                payloadObj = None;

                # Prefer REST route when available.
                resp = await fetch("/api/models");
                statusCode = int(resp["status"] or 0);
                contentType = str(resp["headers"].get("content-type") or "").toLowerCase();
                if statusCode != 404 and contentType.indexOf("application/json") >= 0 {
                    data = await resp.json();
                    root = data or {};
                    payloadObj = root;
                    if payloadObj["data"] { payloadObj = payloadObj["data"]; }
                    if payloadObj and payloadObj["result"] { payloadObj = payloadObj["result"]; }
                    if payloadObj and payloadObj["data"] and (payloadObj["data"]["models"] or payloadObj["data"]["categories"]) {
                        payloadObj = payloadObj["data"];
                    }
                }

                # Fallback for Jac runtimes that expose function routes instead of /api/*.
                if not payloadObj or not payloadObj["models"] {
                    fnResp = await fetch("/function/api_get_models", {
                        "method": "POST",
                        "headers": {"Content-Type": "application/json"},
                        "body": "{}"
                    });
                    fnData = await fnResp.json();
                    payloadObj = fnData and fnData["data"] and fnData["data"]["result"] or None;
                    if payloadObj and payloadObj["data"] and payloadObj["ok"] {
                        payloadObj = payloadObj["data"];
                    }
                }

                catalogModels = payloadObj and payloadObj["models"] or [];
                catalogCategories = payloadObj and payloadObj["categories"] or [];
                catalogLoaded = True;
            }
            _fetch();
        }

        def openPicker -> None {
            loadCatalog();
            showPicker = True;
        }

        def handleModelSelect(model: Any) -> None {
            provider = model["provider"] or "openai";

            if not appStore.hasKey(provider) {
                # Key missing — show focused prompt, hold model in pending state
                pendingModel = model;
                quickKeyProvider = getProviderById(provider);
                showQuickKey = True;
            } else {
                # Key present — add session immediately
                chatStore["addSession"](model);
            }
        }

        def handleQuickKeySaved -> None {
            # Key was just saved — now add the pending session
            showQuickKey = False;
            if pendingModel {
                chatStore["addSession"](pendingModel);
                pendingModel = None;
                quickKeyProvider = None;
            }
        }

        def handleQuickKeyCancel -> None {
            showQuickKey = False;
            pendingModel = None;
            quickKeyProvider = None;
        }

        def handleKeyNeeded(provider: Any) -> None {
            quickKeyProvider = provider;
            pendingModel = None;
            showQuickKey = True;
        }

        sessions = chatStore["sessions"];
        activeTabId = chatStore["activeTabId"];

        return <div className="flex flex-col h-[calc(100vh-56px)]">
            <div className="flex items-center gap-1.5 px-3 py-2.5 border-b border-border bg-muted/40 flex-shrink-0 overflow-x-auto">
                {sessions.map(lambda(sess: Any) -> JsxElement {
                    provider = sess["model"]["provider"] or "openai";
                    return <ModelTab
                        key={sess["id"]}
                        session={sess}
                        isActive={sess["id"] == activeTabId}
                        hasKey={appStore.hasKey(provider)}
                        onActivate={chatStore["setActiveTab"]}
                        onClose={chatStore["removeSession"]}
                    />;
                })}

                <button
                    onClick={openPicker}
                    className="flex items-center gap-1.5 px-3 py-2 rounded-xl text-sm font-medium text-muted-foreground hover:text-foreground hover:bg-muted/80 border border-dashed border-border/70 hover:border-primary/40 transition-all flex-shrink-0"
                >
                    <Plus size={12}/>
                    {"Add Model"}
                </button>

                {sessions.length > 0 and
                    <div className="ml-auto flex-shrink-0">
                        <button
                            onClick={lambda() -> None {
                                ids = sessions.map(lambda(s: Any) -> str { return s["id"]; });
                                ids.forEach(lambda(id: Any) -> None { chatStore["removeSession"](id); });
                            }}
                            className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg text-xs text-muted-foreground hover:text-destructive hover:bg-destructive/10 transition-colors"
                        >
                            <Trash2 size={11}/>
                            <span className="hidden sm:inline">{"Close all"}</span>
                        </button>
                    </div>
                }
            </div>

            <div className="flex-1 flex overflow-hidden">
                {sessions.length == 0 and
                    <EmptyState onAddModel={openPicker}/>
                }

                {sessions.length == 1 and
                    <div className="flex-1 flex flex-col overflow-hidden">
                        <ChatPanel
                            session={sessions[0]}
                            onClear={lambda() -> None { chatStore["clearSession"](sessions[0]["id"]); }}
                        />
                    </div>
                }

                {sessions.length > 1 and
                    <div className="flex-1 flex overflow-hidden divide-x divide-border">
                        {sessions.map(lambda(sess: Any) -> JsxElement {
                            widthCls = "w-1/2";
                            if sessions.length == 3 { widthCls = "w-1/3"; }
                            elif sessions.length >= 4 { widthCls = "min-w-80 flex-1"; }

                            return <div
                                key={sess["id"]}
                                className={"flex flex-col overflow-hidden " + widthCls}
                            >
                                <ChatPanel
                                    session={sess}
                                    onClear={lambda() -> None { chatStore["clearSession"](sess["id"]); }}
                                />
                            </div>;
                        })}
                    </div>
                }
            </div>

            <InputBar
                onAddModel={openPicker}
                onOpenKeys={lambda() -> None { showKeys = True; }}
                onKeyNeeded={handleKeyNeeded}
            />

            {showPicker and
                <ModelPicker
                    models={catalogModels}
                    categories={catalogCategories}
                    activeSessions={sessions}
                    onSelect={handleModelSelect}
                    onClose={lambda() -> None { showPicker = False; }}
                />
            }

            {showQuickKey and quickKeyProvider and
                <QuickKeyPrompt
                    provider={quickKeyProvider}
                    modelName={pendingModel and (pendingModel["name"] or "this model") or "the selected model"}
                    onSaved={handleQuickKeySaved}
                    onCancel={handleQuickKeyCancel}
                />
            }

            {showKeys and
                <ApiKeyModal
                    providers={PROVIDERS}
                    onClose={lambda() -> None { showKeys = False; }}
                />
            }
        </div>;
    }
}
