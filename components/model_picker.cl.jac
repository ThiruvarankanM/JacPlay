
cl import from "lucide-react" { X, Search, Sparkles, Brain, Code2, Zap, Eye, Drama, Check, SlidersHorizontal }
cl import from .ui.button { Button }
cl import from .ui.badge { Badge }
cl import from .ui.utils { cn }

cl {
    def formatCtx(value: Any) -> str {
        ctx = int(value or 0);
        if ctx >= 1000000 {
            return str(round(ctx / 1000000, 1)) + "M ctx";
        }
        return str(round(ctx / 1000, 0)) + "k ctx";
    }

    def formatPrice(model: Any) -> str {
        inputCost = float(model["input_cost_per_million"] or 0.0);
        outputCost = float(model["output_cost_per_million"] or 0.0);
        if inputCost <= 0.0 and outputCost <= 0.0 {
            return "Custom";
        }
        return "$" + str(round(inputCost, 2)) + "/$" + str(round(outputCost, 2));
    }

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
                        {model["is_free"] and <Badge variant="free">{"Free"}</Badge>}
                        {isSelected and
                            <span className="ml-auto text-primary">
                                <Check size={14}/>
                            </span>
                        }
                    </div>
                    <p className="text-xs text-muted-foreground mt-0.5 leading-relaxed line-clamp-2">{model["description"]}</p>
                    <div className="flex items-center gap-1.5 mt-2 flex-wrap">
                        <span className="text-xs text-muted-foreground bg-muted rounded-full px-2 py-0.5">{model["provider_display"]}</span>
                        <span className="text-xs text-muted-foreground bg-muted rounded-full px-2 py-0.5">{formatCtx(model["context_length"])}</span>
                        <span className="text-xs text-muted-foreground bg-muted rounded-full px-2 py-0.5">{formatPrice(model) + " / 1M"}</span>
                        {model["supports_vision"] and
                            <span className="text-xs text-primary bg-primary/10 rounded-full px-2 py-0.5 border border-primary/20">{"Vision"}</span>
                        }
                        {model["categories"] and model["categories"].map(lambda(cat: Any) -> JsxElement {
                            return <span key={str(cat)} className="text-xs text-muted-foreground/80 bg-muted/70 rounded-full px-2 py-0.5">{str(cat)}</span>;
                        })}
                    </div>
                </div>
            </div>
        </button>;
    }

    def:pub ModelPicker(props: Any) -> JsxElement {
        onClose = props.onClose;
        onSelect = props.onSelect;
        models = props.models or [];
        categories = props.categories or [];
        activeSessions = props.activeSessions or [];

        has searchQuery: str = "";
        has activeCategory: str = "all";
        has activeProvider: str = "all";
        has sortBy: str = "recommended";
        has visionOnly: bool = False;

        def getActiveModelIds -> Any {
            return activeSessions.map(lambda(s: Any) -> str { return s["model"]["id"]; });
        }

        def getProviders -> Any {
            seen = {};
            result = [];
            for model in models {
                provider = model["provider"] or "unknown";
                if provider in seen { continue; }
                seen[provider] = True;
                result.append({"id": provider, "name": model["provider_display"] or provider});
            }
            return result;
        }

        def sortModels(items: Any) -> Any {
            if sortBy == "fastest" {
                return items.sort(lambda(a: Any, b: Any) -> int { return int(b["speed_tier"] or 0) - int(a["speed_tier"] or 0); });
            }
            if sortBy == "cheapest" {
                return items.sort(lambda(a: Any, b: Any) -> int {
                    aCost = float(a["input_cost_per_million"] or 0.0) + float(a["output_cost_per_million"] or 0.0);
                    bCost = float(b["input_cost_per_million"] or 0.0) + float(b["output_cost_per_million"] or 0.0);
                    return int((aCost - bCost) * 1000);
                });
            }
            if sortBy == "context" {
                return items.sort(lambda(a: Any, b: Any) -> int { return int(b["context_length"] or 0) - int(a["context_length"] or 0); });
            }
            return items.sort(lambda(a: Any, b: Any) -> int { return int(b["recommended_rank"] or 0) - int(a["recommended_rank"] or 0); });
        }

        def filteredModels -> Any {
            q = searchQuery.toLowerCase().trim();
            result = models.filter(lambda(m: Any) -> bool {
                if activeCategory != "all" and m["categories"].indexOf(activeCategory) < 0 { return False; }
                if activeProvider != "all" and m["provider"] != activeProvider { return False; }
                if visionOnly and not m["supports_vision"] { return False; }
                if q {
                    nameMatch = m["name"].toLowerCase().indexOf(q) >= 0;
                    descMatch = m["description"].toLowerCase().indexOf(q) >= 0;
                    provMatch = (m["provider_display"] or "").toLowerCase().indexOf(q) >= 0;
                    catMatch = (m["categories"] or []).join(" ").toLowerCase().indexOf(q) >= 0;
                    return nameMatch or descMatch or provMatch or catMatch;
                }
                return True;
            });
            return sortModels(result.slice());
        }

        def handleSelect(model: Any) -> None {
            onSelect(model);
        }

        activeIds = getActiveModelIds();
        filtered = filteredModels();
        providers = getProviders();

        return <div className="fixed inset-0 z-50 flex items-center justify-center animate-fade-in">
            <div className="absolute inset-0 bg-background/70 backdrop-blur-sm" onClick={onClose}/>

            <div className="relative bg-background border border-border rounded-2xl shadow-2xl w-full max-w-4xl mx-4 max-h-[88vh] flex flex-col animate-slide-up">
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
                            placeholder="Search models, providers, capabilities..."
                            value={searchQuery}
                            onChange={lambda(e: Any) -> None { searchQuery = str(e.target.value); }}
                            className="w-full h-9 pl-8 pr-3 rounded-lg border border-border bg-input text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring transition-colors"
                            autoFocus={True}
                        />
                    </div>

                    <div className="flex flex-wrap gap-2 items-center">
                        <div className="flex items-center gap-1 text-xs text-muted-foreground mr-1">
                            <SlidersHorizontal size={12}/>
                            {"Filters"}
                        </div>
                        <select value={activeProvider} onChange={lambda(e: Any) -> None { activeProvider = str(e.target.value); }} className="h-8 rounded-lg border border-border bg-input px-2.5 text-xs text-foreground">
                            <option value="all">{"All providers"}</option>
                            {providers.map(lambda(provider: Any) -> JsxElement {
                                return <option key={provider["id"]} value={provider["id"]}>{provider["name"]}</option>;
                            })}
                        </select>
                        <select value={sortBy} onChange={lambda(e: Any) -> None { sortBy = str(e.target.value); }} className="h-8 rounded-lg border border-border bg-input px-2.5 text-xs text-foreground">
                            <option value="recommended">{"Recommended"}</option>
                            <option value="fastest">{"Fastest"}</option>
                            <option value="cheapest">{"Cheapest"}</option>
                            <option value="context">{"Largest context"}</option>
                        </select>
                        <button
                            onClick={lambda() -> None { visionOnly = not visionOnly; }}
                            className={cn(
                                "h-8 px-3 rounded-lg text-xs border transition-colors",
                                visionOnly and "border-primary bg-primary/10 text-primary" or "border-border bg-input text-muted-foreground"
                            )}
                        >
                            {"Vision only"}
                        </button>
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
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
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
                        {"Your key · Direct to provider · Sorted " + sortBy}
                    </p>
                </div>
            </div>
        </div>;
    }
}
