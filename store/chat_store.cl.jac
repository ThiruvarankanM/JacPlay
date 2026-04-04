cl import from "react" { createContext, useContext }
import from ..hooks.chat_api { sendChatMessage }

glob ChatCtx: Any = createContext(None);

def:pub ChatProvider(props: Any) -> JsxElement {
    has sessions: Any = [];
    has activeTabId: str = "";
    has systemPrompt: str = "";
    has inputText: str = "";
    has shouldEnhancePrompt: bool = False;
    has requestTick: int = 0;

    def _makeId -> str {
        requestTick = requestTick + 1;
        return "s_" + str(requestTick);
    }

    def addSession(model: Any) -> str {
        id = _makeId();
        newSession = {
            "id": id,
            "model": model,
            "messages": [],
            "isLoading": False,
            "error": None,
            "tokenUsage": None,
            "totalTokens": 0,
            "promptMeta": {"enhanced": False}
        };
        sessions = sessions + [newSession];
        activeTabId = id;
        return id;
    }

    def removeSession(sessionId: str) {
        remaining = [s for s in sessions if s and s["id"] != sessionId];
        sessions = remaining;
        if activeTabId == sessionId {
            activeTabId = remaining[-1]["id"] if remaining else "";
        }
    }

    def setActiveTab(sessionId: str) {
        activeTabId = sessionId;
    }

    def clearSession(sessionId: str) {
        next_sessions = [];
        for s in sessions {
            if s and s["id"] == sessionId {
                next_sessions.append({
                    "id": s["id"],
                    "model": s["model"],
                    "messages": [],
                    "isLoading": False,
                    "error": None,
                    "tokenUsage": None,
                    "totalTokens": 0,
                    "promptMeta": {"enhanced": False}
                });
            } else {
                next_sessions.append(s);
            }
        }
        sessions = next_sessions;
    }

    def updateSystemPrompt(prompt: str) {
        systemPrompt = prompt;
    }

    def updateInputText(text: str) {
        inputText = text;
    }

    def updateEnhancePrompt(enabled: bool) {
        shouldEnhancePrompt = enabled;
    }

    async def sendMessage(content: str, apiKeyGetter: Any) {
        if not sessions or not content.strip() { return; }

        trimmed = content.strip();
        updated_sessions = [];
        for s in sessions {
            updated_messages = (s["messages"] or []) + [{
                "role": "user",
                "content": trimmed,
                "id": _makeId()
            }];
            updated_sessions.append({
                "id": s["id"],
                "model": s["model"],
                "messages": updated_messages,
                "isLoading": True,
                "error": None,
                "tokenUsage": s["tokenUsage"],
                "totalTokens": s["totalTokens"] or 0,
                "promptMeta": s["promptMeta"] or {"enhanced": False}
            });
        }
        sessions = updated_sessions;
        inputText = "";

        final_sessions = [];
        for sess in updated_sessions {
            model = sess["model"] or {};
            provider = model["provider"] if model and "provider" in model else "openai";
            api_key = apiKeyGetter(provider);
            started_at = Date.now();
            result = await sendChatMessage(
                model["id"] if model and "id" in model else "",
                sess["messages"],
                api_key,
                provider,
                systemPrompt,
                shouldEnhancePrompt
            );
            elapsed_ms = int(Date.now() - started_at);

            if result and result["ok"] {
                payload = result["data"] or {};
                usage = payload["usage"] or None;
                added_tokens = int(usage["total_tokens"]) if usage and "total_tokens" in usage else 0;
                final_sessions.append({
                    "id": sess["id"],
                    "model": sess["model"],
                    "messages": sess["messages"] + [{
                        "role": "assistant",
                        "content": payload["content"] if payload and "content" in payload else "",
                        "id": _makeId(),
                        "usage": usage,
                        "elapsed": elapsed_ms
                    }],
                    "isLoading": False,
                    "error": None,
                    "tokenUsage": usage,
                    "totalTokens": int(sess["totalTokens"] or 0) + added_tokens,
                    "promptMeta": payload["prompt_meta"] if payload and "prompt_meta" in payload else {"enhanced": False}
                });
            } else {
                final_sessions.append({
                    "id": sess["id"],
                    "model": sess["model"],
                    "messages": sess["messages"],
                    "isLoading": False,
                    "error": result["error"] if result and "error" in result else "Failed to get response from model.",
                    "tokenUsage": None,
                    "totalTokens": sess["totalTokens"] or 0,
                    "promptMeta": sess["promptMeta"] or {"enhanced": False}
                });
            }
        }
        sessions = final_sessions;
    }

    store = {
        "sessions": sessions,
        "activeTabId": activeTabId,
        "systemPrompt": systemPrompt,
        "inputText": inputText,
        "enhancePrompt": shouldEnhancePrompt,
        "addSession": addSession,
        "removeSession": removeSession,
        "setActiveTab": setActiveTab,
        "clearSession": clearSession,
        "updateSystemPrompt": updateSystemPrompt,
        "updateInputText": updateInputText,
        "setEnhancePrompt": updateEnhancePrompt,
        "sendMessage": sendMessage
    };

    return <ChatCtx.Provider value={store}>{props.children}</ChatCtx.Provider>;
}

def:pub useChatStore() -> Any {
    return useContext(ChatCtx);
}
