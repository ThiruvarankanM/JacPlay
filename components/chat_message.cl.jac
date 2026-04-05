
cl import from "lucide-react" { User, Copy, Check, RotateCcw, Pencil, DollarSign, Clock3 }
cl import from "marked" { marked }
cl import from .ui.button { Button }
cl import from .ui.spinner { TypingIndicator }
cl import from .ui.utils { cn }

cl {
    def safeTimeout(callback: Any, delay: int) -> None {
        if typeof(setTimeout) != "undefined" {
            setTimeout(callback, delay);
        }
    }

    def escapeHtml(value: str) -> str {
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;").replace("'", "&#39;");
    }

    def formatSeconds(ms: Any) -> str {
        value = int(ms or 0);
        if value <= 0 { return ""; }
        return str(round(value / 1000, 1)) + "s";
    }

    def formatCost(cost: Any) -> str {
        value = float(cost or 0.0);
        if value <= 0.0 { return ""; }
        if value < 0.01 {
            return "$" + str(round(value, 4));
        }
        return "$" + str(round(value, 2));
    }

    def:pub ChatMessage(props: Any) -> JsxElement {
        msg = props.msg;
        modelColor = props.modelColor or "#7c3aed";
        modelAvatar = props.modelAvatar or "AI";
        onRegenerate = props.onRegenerate;
        onEdit = props.onEdit;

        has copied: bool = False;
        has editing: bool = False;
        has editText: str = str(msg["content"] or "");

        def copyContent -> None {
            if typeof(navigator) == "undefined" or not navigator.clipboard or not navigator.clipboard.writeText {
                return;
            }
            navigator.clipboard.writeText(msg["content"] or "");
            copied = True;
            safeTimeout(lambda() -> None { copied = False; }, 2000);
        }

        def startEdit -> None {
            editText = str(msg["content"] or "");
            editing = True;
        }

        def cancelEdit -> None {
            editing = False;
            editText = str(msg["content"] or "");
        }

        def saveEdit -> None {
            if onEdit and editText.trim() {
                onEdit(msg["id"], editText.trim());
            }
            editing = False;
        }

        isUser = msg["role"] == "user";

        if isUser {
            return <div className="flex justify-end mb-5 animate-fade-in">
                <div className="flex items-end gap-2.5 max-w-[78%]">
                    <div className="group relative w-full">
                        <div className="msg-bubble-user px-4 py-3 text-[0.9375rem] leading-relaxed font-medium">
                            {editing and
                                <div className="space-y-2">
                                    <textarea
                                        value={editText}
                                        onChange={lambda(e: Any) -> None { editText = str(e.target.value); }}
                                        rows={4}
                                        className="w-full rounded-lg border border-white/20 bg-white/10 px-3 py-2 text-sm text-white placeholder:text-white/60 focus:outline-none focus:ring-2 focus:ring-white/30 resize-none"
                                    />
                                    <div className="flex items-center justify-end gap-2">
                                        <Button size="sm" variant="ghost" onClick={cancelEdit}>{"Cancel"}</Button>
                                        <Button size="sm" onClick={saveEdit}>{"Save & resend"}</Button>
                                    </div>
                                </div>
                            }
                            {not editing and msg["content"]}
                        </div>
                        {not editing and
                            <div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity flex items-center gap-1">
                                <button
                                    onClick={startEdit}
                                    className="p-1 rounded-md bg-white/15 hover:bg-white/30 text-white"
                                    title="Edit and resend"
                                >
                                    <Pencil size={10}/>
                                </button>
                                <button
                                    onClick={copyContent}
                                    className="p-1 rounded-md bg-white/15 hover:bg-white/30 text-white"
                                    title="Copy"
                                >
                                    {copied and <Check size={10}/> or <Copy size={10}/>}
                                </button>
                            </div>
                        }
                    </div>
                    <div className="w-8 h-8 rounded-full bg-muted border border-border flex items-center justify-center flex-shrink-0">
                        <User size={14} className="text-muted-foreground"/>
                    </div>
                </div>
            </div>;
        }

        parsedHtml = marked.parse(escapeHtml(str(msg["content"] or "")));

        msgUsage = msg["usage"] or {};
        msgMetrics = msg["metrics"] or {};
        metricTotal = int(msgUsage["total_tokens"] or 0);
        metricLatency = formatSeconds(msgMetrics["latency_ms"] or msg["elapsed"] or 0);
        metricCost = formatCost(msgMetrics["estimated_cost_usd"] or 0.0);
        hasMetrics = metricTotal > 0 or metricLatency or metricCost;

        return <div className="flex justify-start mb-5 animate-fade-in">
            <div className="flex items-end gap-2.5 max-w-[86%]">
                <div
                    className="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 text-white text-xs font-bold shadow-md"
                    style={{"backgroundColor": modelColor}}
                >
                    {modelAvatar}
                </div>
                <div className="flex flex-col gap-1">
                    <div className="group relative">
                        <div className="msg-bubble-ai px-4 py-3.5">
                            <div
                                className="chat-markdown"
                                dangerouslySetInnerHTML={{"__html": parsedHtml}}
                            />
                        </div>
                        <div className="absolute top-2.5 right-2.5 opacity-0 group-hover:opacity-100 transition-opacity flex items-center gap-1">
                            {onRegenerate and
                                <button
                                    onClick={onRegenerate}
                                    className="p-1.5 rounded-lg bg-muted/80 hover:bg-accent text-muted-foreground hover:text-foreground backdrop-blur-sm"
                                    title="Regenerate"
                                >
                                    <RotateCcw size={11}/>
                                </button>
                            }
                            <button
                                onClick={copyContent}
                                className="p-1.5 rounded-lg bg-muted/80 hover:bg-accent text-muted-foreground hover:text-foreground backdrop-blur-sm"
                                title="Copy"
                            >
                                {copied and <Check size={11}/> or <Copy size={11}/>}
                            </button>
                        </div>
                    </div>
                    {hasMetrics and
                        <span className="text-[11px] text-muted-foreground/70 px-1 self-start flex items-center gap-2 font-medium flex-wrap">
                            {metricTotal > 0 and
                                <span className="inline-flex items-center gap-1">
                                    <Check size={10}/>
                                    {str(metricTotal) + " tokens"}
                                </span>
                            }
                            {metricLatency and
                                <span className="inline-flex items-center gap-1">
                                    <Clock3 size={10}/>
                                    {metricLatency}
                                </span>
                            }
                            {metricCost and
                                <span className="inline-flex items-center gap-1">
                                    <DollarSign size={10}/>
                                    {metricCost}
                                </span>
                            }
                        </span>
                    }
                </div>
            </div>
        </div>;
    }

    def:pub LoadingMessage(props: Any) -> JsxElement {
        modelColor = props.modelColor or "#7c3aed";
        modelAvatar = props.modelAvatar or "AI";

        return <div className="flex justify-start mb-5 animate-fade-in">
            <div className="flex items-end gap-2.5">
                <div
                    className="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 text-white text-xs font-bold shadow-md"
                    style={{"backgroundColor": modelColor}}
                >
                    {modelAvatar}
                </div>
                <div className="msg-bubble-ai px-4 py-3.5 min-w-28">
                    <TypingIndicator/>
                </div>
            </div>
        </div>;
    }

    def:pub ErrorMessage(props: Any) -> JsxElement {
        return <div className="flex justify-start mb-4 animate-fade-in">
            <div className="bg-destructive/10 border border-destructive/30 rounded-xl px-4 py-3 text-sm text-destructive max-w-[85%]">
                <span className="font-semibold">{"Error: "}</span>
                {props.error}
            </div>
        </div>;
    }
}
