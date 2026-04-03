"""Chat message bubble — user and assistant variants."""

cl import from "lucide-react" { User, Copy, Check, RotateCcw }
cl import from "marked" { marked }
cl import from .ui.button { Button }
cl import from .ui.spinner { TypingIndicator }
cl import from .ui.utils { cn }

cl {
    def:pub ChatMessage(props: Any) -> JsxElement {
        msg = props.msg;
        modelColor = props.modelColor or "#7c3aed";
        modelAvatar = props.modelAvatar or "AI";

        has copied: bool = False;

        def copyContent -> None {
            navigator.clipboard.writeText(msg["content"] or "");
            copied = True;
            setTimeout(lambda() -> None { copied = False; }, 2000);
        }

        isUser = msg["role"] == "user";

        if isUser {
            return <div className="flex justify-end mb-5 animate-fade-in">
                <div className="flex items-end gap-2.5 max-w-[78%]">
                    <div className="group relative">
                        <div className="msg-bubble-user px-4 py-3 text-[0.9375rem] leading-relaxed font-medium">
                            {msg["content"]}
                        </div>
                        <button
                            onClick={copyContent}
                            className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity p-1 rounded-md bg-white/15 hover:bg-white/30 text-white"
                            title="Copy"
                        >
                            {copied and <Check size={10}/> or <Copy size={10}/>}
                        </button>
                    </div>
                    <div className="w-8 h-8 rounded-full bg-muted border border-border flex items-center justify-center flex-shrink-0">
                        <User size={14} className="text-muted-foreground"/>
                    </div>
                </div>
            </div>;
        }

        # Assistant message
        parsedHtml = marked.parse(msg["content"] or "");

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
                        <button
                            onClick={copyContent}
                            className="absolute top-2.5 right-2.5 opacity-0 group-hover:opacity-100 transition-opacity p-1.5 rounded-lg bg-muted/80 hover:bg-accent text-muted-foreground hover:text-foreground backdrop-blur-sm"
                            title="Copy"
                        >
                            {copied and <Check size={11}/> or <Copy size={11}/>}
                        </button>
                    </div>
                    {(msg["usage"] or msg["elapsed"]) and
                        <span className="text-[11px] text-muted-foreground/50 px-1 self-start flex items-center gap-1.5 font-medium">
                            {msg["usage"] and str(msg["usage"]["completion_tokens"]) + " tokens"}
                            {msg["usage"] and msg["elapsed"] and
                                <span className="opacity-60">{"·"}</span>
                            }
                            {msg["elapsed"] and str(round(int(msg["elapsed"]) / 1000, 1)) + "s"}
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
                <div className="msg-bubble-ai px-4 py-3.5">
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
