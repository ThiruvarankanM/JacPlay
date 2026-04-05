"""Chat panel — message list for a single session."""

import from "lucide-react" { Trash2, Cpu, DollarSign, Clock3 }
import from .chat_message { ChatMessage, LoadingMessage, ErrorMessage }
import from .ui.button { Button }
import from .ui.utils { cn }

cl {
    def formatLatency(ms: Any) -> str {
        value = int(ms or 0);
        if value <= 0 { return "—"; }
        return str(round(value / 1000, 1)) + "s";
    }

    def formatCost(cost: Any) -> str {
        value = float(cost or 0.0);
        if value <= 0.0 { return "$0.00"; }
        if value < 0.01 {
            return "$" + str(round(value, 4));
        }
        return "$" + str(round(value, 2));
    }

    def:pub ChatPanel(props: Any) -> JsxElement {
        session = props.session or {};
        onClear = props.onClear;
        onRegenerate = props.onRegenerate;
        onEditMessage = props.onEditMessage;

        model = session["model"] or {};
        messages = session["messages"] or [];
        isLoading = session["isLoading"] or False;
        error = session["error"];
        modelColor = model["color"] or "#7c3aed";
        modelAvatar = model["avatar"] or "AI";
        totals = session["totals"] or {};
        metrics = session["metrics"] or {};
        totalTokens = int((totals and "tokens" in totals and totals["tokens"]) or session["totalTokens"] or 0);
        totalCost = float((totals and "cost_usd" in totals and totals["cost_usd"]) or (metrics and "cost_usd" in metrics and metrics["cost_usd"]) or 0.0);
        avgLatency = int((totals and "avg_latency_ms" in totals and totals["avg_latency_ms"]) or (metrics and "avg_latency_ms" in metrics and metrics["avg_latency_ms"]) or 0);

        has messagesEndRef: Any = None;

        def scrollToBottom(behavior: str = "auto") -> None {
            if messagesEndRef and messagesEndRef.scrollIntoView {
                messagesEndRef.scrollIntoView({"behavior": behavior});
            }
        }

        can with entry {
            scrollToBottom();
        }

        can with [messages] entry {
            scrollToBottom("auto");
        }

        hasContent = len(messages) > 0 or isLoading;

        def handleRegenerate -> None {
            if onRegenerate {
                onRegenerate();
            }
        }

        def handleEditMessage(messageId: str, content: str) -> None {
            if onEditMessage {
                onEditMessage(messageId, content);
            }
        }

        return <div className="flex flex-col h-full">
            <div className="flex items-center justify-between px-4 py-3 border-b border-border bg-card flex-shrink-0 gap-3">
                <div className="flex items-center gap-3 min-w-0">
                    <div
                        className="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0 shadow-md"
                        style={{"backgroundColor": modelColor}}
                    >
                        {modelAvatar}
                    </div>
                    <div className="min-w-0">
                        <p className="text-sm font-semibold text-foreground leading-tight truncate">{model["name"] or "Model"}</p>
                        <p className="text-xs text-muted-foreground mt-0.5 leading-tight truncate">{model["provider_display"] or model["provider"] or "Provider"}</p>
                    </div>
                </div>
                <div className="flex items-center gap-2 flex-wrap justify-end">
                    <div className="flex items-center gap-1.5 text-xs text-muted-foreground bg-muted/60 px-2.5 py-1 rounded-full">
                        <Cpu size={11}/>
                        <span className="font-medium">{str(totalTokens) + " tokens"}</span>
                    </div>
                    <div className="flex items-center gap-1.5 text-xs text-muted-foreground bg-muted/60 px-2.5 py-1 rounded-full">
                        <DollarSign size={11}/>
                        <span className="font-medium">{formatCost(totalCost)}</span>
                    </div>
                    <div className="flex items-center gap-1.5 text-xs text-muted-foreground bg-muted/60 px-2.5 py-1 rounded-full">
                        <Clock3 size={11}/>
                        <span className="font-medium">{formatLatency(avgLatency)}</span>
                    </div>
                    {len(messages) > 0 and
                        <Button
                            variant="ghost"
                            size="icon-sm"
                            onClick={onClear}
                            title="Clear chat"
                            className="text-muted-foreground hover:text-destructive"
                        >
                            <Trash2 size={13}/>
                        </Button>
                    }
                </div>
            </div>

            <div className="flex-1 overflow-y-auto px-5 pt-5 pb-3">
                {not hasContent and
                    <div className="hero-bg h-full flex flex-col items-center justify-center text-center gap-4 py-16 bg-grid-pattern">
                        <div className="animate-float">
                            <div
                                className="w-16 h-16 rounded-2xl flex items-center justify-center text-white text-xl font-bold"
                                style={{
                                    "backgroundColor": modelColor,
                                    "boxShadow": "0 0 0 5px " + modelColor + "25, 0 0 24px " + modelColor + "50, 0 8px 24px #00000025"
                                }}
                            >
                                {modelAvatar}
                            </div>
                        </div>
                        <div>
                            <p className="text-base font-bold text-foreground tracking-tight">{model["name"] or "Model"}</p>
                            <p className="text-sm text-muted-foreground mt-1 max-w-48 leading-relaxed">{model["description"] or "Ready to chat."}</p>
                        </div>
                        <div className="flex flex-wrap justify-center gap-2">
                            <div className="text-xs bg-muted/80 border border-border/60 px-3 py-1.5 rounded-full text-muted-foreground font-medium">
                                {str(model["context_length"] or 0) + " ctx"}
                            </div>
                            {model["supports_vision"] and
                                <div className="text-xs bg-primary/10 text-primary px-3 py-1.5 rounded-full border border-primary/25 font-medium">
                                    {"Vision"}
                                </div>
                            }
                            {model["is_free"] and
                                <div className="text-xs bg-success/10 text-success px-3 py-1.5 rounded-full border border-success/25 font-medium">
                                    {"Free"}
                                </div>
                            }
                        </div>
                    </div>
                }

                {messages.map(lambda(msg: Any) -> JsxElement {
                    if not msg { return <></>; }
                    return <ChatMessage
                        key={msg["id"] or msg["role"] + str(Math.random())}
                        msg={msg}
                        modelColor={modelColor}
                        modelAvatar={modelAvatar}
                        onRegenerate={(msg["role"] == "assistant" and not msg["pending"]) and handleRegenerate or None}
                        onEdit={handleEditMessage}
                    />;
                })}

                {isLoading and
                    <LoadingMessage modelColor={modelColor} modelAvatar={modelAvatar}/>
                }

                {error and not isLoading and
                    <ErrorMessage error={error}/>
                }

                <div ref={lambda(el: Any) -> None { messagesEndRef = el; }}/>
            </div>
        </div>;
    }
}
