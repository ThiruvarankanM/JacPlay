"""Chat panel — message list for a single session."""

cl import from "react" { useRef }
cl import from "lucide-react" { Trash2, Cpu }
cl import from .chat_message { ChatMessage, LoadingMessage, ErrorMessage }
cl import from .ui.button { Button }
cl import from .ui.utils { cn }

cl {
    def:pub ChatPanel(props: Any) -> JsxElement {
        session = props.session;
        onClear = props.onClear;

        model = session["model"];
        messages = session["messages"];
        isLoading = session["isLoading"];
        error = session["error"];
        modelColor = model["color"] or "#7c3aed";
        modelAvatar = model["avatar"] or "AI";

        messagesEndRef = useRef(None);

        def scrollToBottom -> None {
            if messagesEndRef["current"] {
                messagesEndRef["current"].scrollIntoView({"behavior": "smooth"});
            }
        }

        scrollToBottom();

        hasContent = messages.length > 0 or isLoading;

        return <div className="flex flex-col h-full">
            <div className="flex items-center justify-between px-4 py-3 border-b border-border bg-card flex-shrink-0">
                <div className="flex items-center gap-3">
                    <div
                        className="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0 shadow-md"
                        style={{"backgroundColor": modelColor}}
                    >
                        {modelAvatar}
                    </div>
                    <div>
                        <p className="text-sm font-semibold text-foreground leading-tight">{model["name"]}</p>
                        <p className="text-xs text-muted-foreground mt-0.5 leading-tight">{model["provider_display"] or model["provider"]}</p>
                    </div>
                </div>
                <div className="flex items-center gap-2">
                    {(session["totalTokens"] or 0) > 0 and
                        <div className="flex items-center gap-1.5 text-xs text-muted-foreground bg-muted/60 px-2.5 py-1 rounded-full">
                            <Cpu size={11}/>
                            <span className="font-medium">{str(session["totalTokens"]) + " tokens"}</span>
                        </div>
                    }
                    {messages.length > 0 and
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
                            <p className="text-base font-bold text-foreground tracking-tight">{model["name"]}</p>
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
                    return <ChatMessage
                        key={msg["id"] or msg["role"] + str(Math.random())}
                        msg={msg}
                        modelColor={modelColor}
                        modelAvatar={modelAvatar}
                    />;
                })}

                {isLoading and
                    <LoadingMessage modelColor={modelColor} modelAvatar={modelAvatar}/>
                }

                {error and not isLoading and
                    <ErrorMessage error={error}/>
                }

                <div ref={messagesEndRef}/>
            </div>
        </div>;
    }
}
