"""Model picker modal — search and browse all available models."""

cl import from "lucide-react" { X, Search, Sparkles, Brain, Code2, Zap, Eye, Drama, Check }
cl import from .ui.button { Button }
cl import from .ui.badge { Badge }
cl import from .ui.utils { cn }

glob CATEGORY_ICONS: Any = {
    "flagship": "Sparkles",
    "reasoning": "Brain",
    "coding": "Code2",
    "fast": "Zap",
    "vision": "Eye",
    "roleplay": "Drama"
};

cl {
    def ModelCard(props: Any) -> JsxElement {
        model = props.model;
        isSelected = props.isSelected;
        onSelect = props.onSelect;

        return <button
            onClick={lambda() -> None { onSelect(model); }}
            className={cn(
                "w-full text-left rounded-xl border p-3.5 transition-all hover:shadow-md group",
                isSelected and "border-primary bg-primary/5 shadow-sm shadow-primary/10" or "border-border bg-card hover:border-primary/40 hover:bg-card"
            )}
        >
            <div className="flex items-start gap-3">
                <div
                    className="w-9 h-9 rounded-xl flex items-center justify-center text-white text-xs font-bold flex-shrink-0 shadow-sm"
                    style={{"backgroundColor": model["color"]}}
                >
                    {model["avatar"]}
                </div>

                <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 flex-wrap">
                        <span className="text-sm font-semibold text-foreground truncate">{model["name"]}</span>
                        {model["is_free"] and
                            <Badge variant="free">{"Free"}</Badge>
                        }
                        {isSelected and
                            <span className="ml-auto text-primary">
                                <Check size={14}/>
                            </span>
                        }
                    </div>
                    <p className="text-xs text-muted-foreground mt-0.5 leading-relaxed line-clamp-2">{model["description"]}</p>
                    <div className="flex items-center gap-1.5 mt-2 flex-wrap">
                        <span className="text-xs text-muted-foreground bg-muted rounded-full px-2 py-0.5">
                            {model["provider_display"]}
                        </span>
                        <span className="text-xs text-muted-foreground bg-muted rounded-full px-2 py-0.5">
                            {str(model["context_length"] / 1000) + "k ctx"}
                        </span>
                        {model["supports_vision"] and
                            <span className="text-xs text-primary bg-primary/10 rounded-full px-2 py-0.5 border border-primary/20">
                                {"Vision"}
                            </span>
                        }
                    </div>
                </div>
            </div>
        </button>;
    }

    def:pub ModelPicker(props: Any) -> JsxElement {
        onClose = props.onClose;
        onSelect = props.onSelect;
        models = props.models;
        categories = props.categories;
        activeSessions = props.activeSessions;

        has searchQuery: str = "";
        has activeCategory: str = "all";

        def getActiveModelIds -> Any {
            return activeSessions.map(lambda(s: Any) -> str { return s["model"]["id"]; });
        }

        def filteredModels -> Any {
            q = searchQuery.toLowerCase().trim();
            result = models;

            if activeCategory != "all" {
                result = result.filter(lambda(m: Any) -> bool {
                    return m["categories"].indexOf(activeCategory) >= 0;
                });
            }

            if q {
                result = result.filter(lambda(m: Any) -> bool {
                    nameMatch = m["name"].toLowerCase().indexOf(q) >= 0;
                    descMatch = m["description"].toLowerCase().indexOf(q) >= 0;
                    provMatch = (m["provider_display"] or "").toLowerCase().indexOf(q) >= 0;
                    return nameMatch or descMatch or provMatch;
                });
            }

            return result;
        }

        def handleSelect(model: Any) -> None {
            onSelect(model);
            onClose();
        }

        activeIds = getActiveModelIds();
        filtered = filteredModels();

        return <div className="fixed inset-0 z-50 flex items-center justify-center animate-fade-in">
            <div className="absolute inset-0 bg-background/70 backdrop-blur-sm" onClick={onClose}/>

            <div className="relative bg-background border border-border rounded-2xl shadow-2xl w-full max-w-2xl mx-4 max-h-[88vh] flex flex-col animate-slide-up">
                <div className="px-5 pt-5 pb-3 border-b border-border flex-shrink-0 space-y-3">
                    <div className="flex items-center justify-between">
                        <h2 className="text-base font-bold text-foreground">{"Choose a Model"}</h2>
                        <Button variant="ghost" size="icon-sm" onClick={onClose}>
                            <X size={15}/>
                        </Button>
                    </div>

                    <div className="relative">
                        <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none"/>
                        <input
                            type="text"
                            placeholder="Search models..."
                            value={searchQuery}
                            onChange={lambda(e: Any) -> None { searchQuery = str(e["target"]["value"]); }}
                            className="w-full h-9 pl-8 pr-3 rounded-lg border border-border bg-input text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring transition-colors"
                            autoFocus={True}
                        />
                    </div>

                    <div className="flex gap-1.5 overflow-x-auto pb-0.5 scrollbar-none">
                        <button
                            onClick={lambda() -> None { activeCategory = "all"; }}
                            className={cn(
                                "flex-shrink-0 text-xs font-medium px-3 py-1.5 rounded-lg transition-colors",
                                activeCategory == "all" and "bg-primary text-primary-foreground" or "bg-muted text-muted-foreground hover:text-foreground hover:bg-accent"
                            )}
                        >
                            {"All"}
                        </button>
                        {categories.map(lambda(cat: Any) -> JsxElement {
                            return <button
                                key={cat["id"]}
                                onClick={lambda() -> None { activeCategory = cat["id"]; }}
                                className={cn(
                                    "flex-shrink-0 text-xs font-medium px-3 py-1.5 rounded-lg transition-colors whitespace-nowrap",
                                    activeCategory == cat["id"] and "bg-primary text-primary-foreground" or "bg-muted text-muted-foreground hover:text-foreground hover:bg-accent"
                                )}
                            >
                                {cat["name"]}
                            </button>;
                        })}
                    </div>
                </div>

                <div className="flex-1 overflow-y-auto p-4">
                    {filtered.length == 0 and
                        <div className="text-center py-12 text-muted-foreground">
                            <Search size={32} className="mx-auto mb-3 opacity-30"/>
                            <p className="text-sm">{"No models found for "}<strong>{'"' + searchQuery + '"'}</strong></p>
                        </div>
                    }
                    <div className="grid grid-cols-1 gap-2">
                        {filtered.map(lambda(model: Any) -> JsxElement {
                            return <ModelCard
                                key={model["id"]}
                                model={model}
                                isSelected={activeIds.indexOf(model["id"]) >= 0}
                                onSelect={handleSelect}
                            />;
                        })}
                    </div>
                </div>

                <div className="px-5 py-3 border-t border-border bg-muted/20 rounded-b-2xl flex-shrink-0 flex items-center justify-between">
                    <p className="text-xs text-muted-foreground">
                        {str(filtered.length) + " model" + (filtered.length != 1 and "s" or "") + " available"}
                    </p>
                    <p className="text-xs text-muted-foreground">
                        {"Your key · Direct to provider"}
                    </p>
                </div>
            </div>
        </div>;
    }
}
