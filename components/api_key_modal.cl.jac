cl import from "lucide-react" { Key, X, Eye, EyeOff, Trash2, ShieldCheck, ExternalLink, Check, AlertCircle }
import from .ui.button { Button }
import from .ui.utils { cn }
import from ..store.app_store { useAppStore }

cl {
    def:pub QuickKeyPrompt(props: Any) -> JsxElement {
        provider = props.provider;
        modelName = props.modelName;
        onSaved = props.onSaved;
        onCancel = props.onCancel;

        store = useAppStore();

        has inputVal: str = "";
        has showKey: bool = False;
        has saving: bool = False;
        has error: str = "";
        has success: str = "";

        async def handleSave -> None {
            key = inputVal.trim();
            if not key {
                error = "Please enter an API key.";
                success = "";
                return;
            }
            saving = True;
            error = "";
            success = "Saving key...";
            store["setApiKey"](provider["id"], key);
            success = provider["name"] + " API key saved.";
            saving = False;
            onSaved();
        }

        def handleKeyDown(e: Any) -> None {
            if e.key == "Enter" { handleSave(); }
            if e.key == "Escape" { onCancel(); }
        }

        providerColor = provider["color"] or "#7c3aed";

        return <div className="fixed inset-0 z-50 flex items-center justify-center animate-fade-in">
            <div className="absolute inset-0 bg-background/80 backdrop-blur-sm" onClick={onCancel}/>

            <div className="relative bg-background border border-border rounded-2xl shadow-2xl w-full max-w-md mx-4 animate-slide-up overflow-hidden">
                <div className="h-1 w-full" style={{"backgroundColor": providerColor}}/>

                <div className="px-6 pt-5 pb-4">
                    <div className="flex items-center gap-3 mb-1">
                        <div
                            className="w-9 h-9 rounded-xl flex items-center justify-center text-white font-bold text-sm flex-shrink-0"
                            style={{"backgroundColor": providerColor}}
                        >
                            {provider["name"][0]}
                        </div>
                        <div>
                            <h2 className="text-sm font-bold text-foreground">
                                {"Enter your " + provider["name"] + " API key"}
                            </h2>
                            <p className="text-xs text-muted-foreground mt-0.5">
                                {"Required to use " + modelName}
                            </p>
                        </div>
                        <button onClick={onCancel} className="ml-auto text-muted-foreground hover:text-foreground transition-colors">
                            <X size={16}/>
                        </button>
                    </div>
                </div>

                <div className="px-6 pb-5 space-y-3">
                    <div className="relative">
                        <input
                            type={showKey and "text" or "password"}
                            value={inputVal}
                            onChange={lambda(e: Any) -> None { inputVal = str(e["target"]["value"]); error = ""; success = ""; }}
                            onKeyDown={handleKeyDown}
                            placeholder={provider["key_placeholder"] or "Paste your API key here"}
                            className={cn(
                                "w-full h-10 rounded-xl border bg-input px-4 pr-10 text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring transition-colors font-mono",
                                error and "border-destructive" or "border-border",
                                success and not error and "border-emerald-500"
                            )}
                            autoFocus={True}
                        />
                        <button
                            type="button"
                            onClick={lambda() -> None { showKey = not showKey; }}
                            className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                        >
                            {showKey and <EyeOff size={14}/> or <Eye size={14}/>}
                        </button>
                    </div>

                    {error and
                        <div className="flex items-center gap-1.5 text-xs text-destructive">
                            <AlertCircle size={12}/>
                            {error}
                        </div>
                    }

                    {success and not error and
                        <div className="flex items-center gap-1.5 text-xs text-emerald-600 dark:text-emerald-400">
                            <Check size={12}/>
                            {success}
                        </div>
                    }

                    <div className="flex items-start gap-2 bg-muted/50 rounded-xl p-3">
                        <ShieldCheck size={13} className="text-success mt-0.5 flex-shrink-0"/>
                        <p className="text-xs text-muted-foreground leading-relaxed">
                            {"Your key is stored only in your browser and sent directly to "}
                            <strong className="text-foreground">{provider["name"]}</strong>
                            {". We never see or store it."}
                        </p>
                    </div>

                    <div className="flex gap-2 pt-1">
                        <Button variant="ghost" onClick={onCancel} className="flex-1">
                            {"Cancel"}
                        </Button>
                        <Button
                            onClick={handleSave}
                            disabled={not inputVal.trim() or saving}
                            className="flex-1"
                        >
                            {saving and
                                <span className="w-3.5 h-3.5 rounded-full border-2 border-current border-t-transparent animate-spin"/>
                            }
                            {not saving and "Save Key"}
                        </Button>
                    </div>

                    <a
                        href={provider["key_help_url"] or "#"}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="flex items-center justify-center gap-1 text-xs text-primary hover:text-primary/80 transition-colors"
                    >
                        {provider["key_help_text"] or "Get your API key"}
                        <ExternalLink size={10}/>
                    </a>
                </div>
            </div>
        </div>;
    }

    def ProviderKeyRow(props: Any) -> JsxElement {
        provider = props.provider;
        keyValue = props.keyValue or "";
        onSave = props.onSave;
        onRemove = props.onRemove;

        hasKey = bool(keyValue.trim());

        has editing: bool = not hasKey;
        has inputVal: str = "";
        has showKey: bool = False;
        has saved: bool = False;
        has saving: bool = False;
        has error: str = "";
        has success: str = "";

        can with [hasKey] entry {
            if not hasKey {
                editing = True;
                inputVal = "";
                error = "";
                success = "";
            } elif not editing {
                inputVal = "";
            }
        }

        async def handleSave -> None {
            key = inputVal.trim();
            if not key {
                error = "Please enter an API key.";
                success = "";
                return;
            }
            saving = True;
            error = "";
            success = "Saving key...";
            onSave(provider["id"], key);
            saved = True;
            editing = False;
            inputVal = "";
            error = "";
            success = provider["name"] + " key saved.";
            setTimeout(lambda() -> None { saved = False; success = ""; }, 2000);
            saving = False;
        }

        def handleRemove -> None {
            onRemove(provider["id"]);
            editing = True;
            inputVal = "";
            showKey = False;
            saved = False;
            success = "";
            error = "";
        }

        def handleEdit -> None {
            editing = True;
            inputVal = "";
            error = "";
            success = "";
        }

        def handleCancelEdit -> None {
            editing = False;
            inputVal = "";
            showKey = False;
            error = "";
            success = "";
        }

        def handleKeyDown(e: Any) -> None {
            if e.key == "Enter" { handleSave(); }
        }

        providerColor = provider["color"] or "#7c3aed";

        return <div className="rounded-xl border border-border bg-card p-4 space-y-3">
            <div className="flex items-center justify-between gap-2">
                <div className="flex items-center gap-2.5 min-w-0">
                    <div
                        className="w-8 h-8 rounded-lg flex items-center justify-center text-white text-xs font-bold flex-shrink-0"
                        style={{"backgroundColor": providerColor}}
                    >
                        {provider["name"][0]}
                    </div>
                    <div className="min-w-0">
                        <p className="text-sm font-semibold text-foreground truncate">{provider["name"]}</p>
                        <p className="text-xs text-muted-foreground truncate">{provider["description"]}</p>
                    </div>
                </div>
                {hasKey and not editing and
                    <span className="flex items-center gap-1 text-xs text-success flex-shrink-0">
                        <ShieldCheck size={12}/>
                        {"Saved"}
                    </span>
                }
            </div>

            {success and not editing and
                <div className="flex items-center gap-1.5 text-xs text-emerald-600 dark:text-emerald-400">
                    <Check size={12}/>
                    {success}
                </div>
            }

            {editing and
                <div className="space-y-2">
                    <div className="flex gap-2">
                        <div className="flex-1 relative">
                            <input
                                type={showKey and "text" or "password"}
                                value={inputVal}
                                onChange={lambda(e: Any) -> None { inputVal = str(e["target"]["value"]); error = ""; success = ""; }}
                                onKeyDown={handleKeyDown}
                                placeholder={provider["key_placeholder"]}
                                className={cn(
                                    "w-full h-9 rounded-lg border bg-input px-3 pr-8 text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring transition-colors font-mono",
                                    error and "border-destructive" or "border-border",
                                    success and not error and "border-emerald-500"
                                )}
                                autoFocus={not hasKey}
                            />
                            <button
                                type="button"
                                onClick={lambda() -> None { showKey = not showKey; }}
                                className="absolute right-2 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                            >
                                {showKey and <EyeOff size={12}/> or <Eye size={12}/>}
                            </button>
                        </div>
                        <Button size="sm" onClick={handleSave} disabled={not inputVal.trim() or saving}>
                            {saving and <span className="w-3.5 h-3.5 rounded-full border-2 border-current border-t-transparent animate-spin"/>}
                            {not saving and (saved and <Check size={13}/> or "Save")}
                        </Button>
                        {hasKey and
                            <Button variant="ghost" size="icon-sm" onClick={handleCancelEdit}>
                                <X size={13}/>
                            </Button>
                        }
                    </div>

                    {error and
                        <div className="flex items-center gap-1.5 text-xs text-destructive">
                            <AlertCircle size={12}/>
                            {error}
                        </div>
                    }

                    {success and not error and
                        <div className="flex items-center gap-1.5 text-xs text-emerald-600 dark:text-emerald-400">
                            <Check size={12}/>
                            {success}
                        </div>
                    }

                    <a
                        href={provider["key_help_url"]}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex items-center gap-1 text-xs text-primary hover:text-primary/80 transition-colors"
                    >
                        {provider["key_help_text"]}
                        <ExternalLink size={10}/>
                    </a>
                </div>
            }

            {not editing and hasKey and
                <div className="flex items-center justify-between gap-2">
                    <div className="font-mono text-xs text-muted-foreground bg-muted rounded-lg px-3 py-1.5 flex-1">
                        {"••••••••••••••••••••"}
                    </div>
                    <div className="flex gap-1 flex-shrink-0">
                        <Button variant="outline" size="sm" onClick={handleEdit}>
                            {"Edit"}
                        </Button>
                        <Button
                            variant="destructive"
                            size="icon-sm"
                            onClick={handleRemove}
                            title="Remove key"
                        >
                            <Trash2 size={12}/>
                        </Button>
                    </div>
                </div>
            }
        </div>;
    }

    def:pub ApiKeyModal(props: Any) -> JsxElement {
        onClose = props.onClose;
        providers = props.providers;
        store = useAppStore();

        return <div className="fixed inset-0 z-50 flex items-center justify-center animate-fade-in">
            <div className="absolute inset-0 bg-background/80 backdrop-blur-sm" onClick={onClose}/>

            <div className="relative bg-background border border-border rounded-2xl shadow-2xl w-full max-w-lg mx-4 max-h-[90vh] flex flex-col animate-slide-up">
                <div className="flex items-center justify-between px-6 py-4 border-b border-border flex-shrink-0">
                    <div className="flex items-center gap-2.5">
                        <div className="w-8 h-8 rounded-lg bg-primary/10 border border-primary/20 flex items-center justify-center">
                            <Key size={15} className="text-primary"/>
                        </div>
                        <div>
                            <h2 className="text-sm font-bold text-foreground">{"API Keys"}</h2>
                            <p className="text-xs text-muted-foreground">{"Stored locally in your browser only"}</p>
                        </div>
                    </div>
                    <Button variant="ghost" size="icon-sm" onClick={onClose}>
                        <X size={15}/>
                    </Button>
                </div>

                <div className="overflow-y-auto flex-1 p-4 space-y-3">
                    {[<ProviderKeyRow
                        key={p["id"]}
                        provider={p}
                        keyValue={store["getKey"](p["id"])}
                        onSave={store["setApiKey"]}
                        onRemove={store["removeApiKey"]}
                    /> for p in providers]}
                </div>

                <div className="px-6 py-3 border-t border-border bg-muted/20 rounded-b-2xl flex-shrink-0">
                    <div className="flex items-center justify-center gap-1.5 text-xs text-muted-foreground">
                        <ShieldCheck size={12} className="text-success"/>
                        {"Keys are only in your browser — never sent to our servers."}
                    </div>
                </div>
            </div>
        </div>;
    }
}
