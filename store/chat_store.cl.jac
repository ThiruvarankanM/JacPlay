cl import from "react" { createContext, useContext }
import from ..hooks.chat_api { sendChatMessage }

glob ChatCtx: Any = createContext(None);

# ── Helpers ──────────────────────────────────────────────────────────────────

def _safeNow() -> int {
    if typeof(Date) != "undefined" and Date.now {
        return int(Date.now());
    }
    return 0;
}

def _storageGet(key: str) -> Any {
    if typeof(window) == "undefined" or not window.localStorage { return None; }
    return window.localStorage.getItem(key);
}

def _storageSet(key: str, val: str) -> None {
    if typeof(window) == "undefined" or not window.localStorage { return; }
    window.localStorage.setItem(key, val);
}

def _storageRemove(key: str) -> None {
    if typeof(window) == "undefined" or not window.localStorage { return; }
    window.localStorage.removeItem(key);
}

def _normUsage(usage: Any) -> Any {
    if not usage {
        return {"prompt_tokens": 0, "completion_tokens": 0, "total_tokens": 0};
    }
    return {
        "prompt_tokens":    int((usage and "prompt_tokens"    in usage and usage["prompt_tokens"])    or 0),
        "completion_tokens": int((usage and "completion_tokens" in usage and usage["completion_tokens"]) or 0),
        "total_tokens":     int((usage and "total_tokens"     in usage and usage["total_tokens"])     or 0)
    };
}

def _makeMsg(id: str, role: str, content: str, extra: Any) -> Any {
    base = {
        "id": id,
        "role": role,
        "content": content,
        "status": "sent",
        "pending": False,
        "usage": _normUsage(None),
        "elapsed": 0,
        "metrics": {"latency_ms": 0, "estimated_cost_usd": 0.0}
    };
    return {**base, **(extra or {})};
}

def _makeSession(id: str, model: Any) -> Any {
    return {
        "id": id,
        "model": model or {},
        "messages": [],
        "isLoading": False,
        "error": None,
        "tokenUsage": _normUsage(None),
        "totalTokens": 0,
        "promptMeta": {"enhanced": False}
    };
}

def _replaceSess(sessions: list, sessionId: str, next: Any) -> list {
    out: list = [];
    for s in sessions or [] {
        if not s { continue; }
        out.append(next if s["id"] == sessionId else s);
    }
    return out;
}

def _replaceMsg(messages: list, msgId: str, next: Any) -> list {
    out: list = [];
    for m in messages or [] {
        if not m { continue; }
        out.append(next if m["id"] == msgId else m);
    }
    return out;
}

def _loadSessions(raw: Any) -> list {
    if not raw { return []; }
    try {
        parsed = JSON.parse(raw);
        return [s for s in (parsed or []) if s];
    } except Exception {
        return [];
    }
}

# ── Provider ──────────────────────────────────────────────────────────────────

def:pub ChatProvider(props: Any) -> JsxElement {
    has sessions: Any = [];
    has activeTabId: str = "";
    has systemPrompt: str = "";
    has inputText: str = "";
    has shouldEnhancePrompt: bool = False;
    has tick: int = 0;
    has hydrated: bool = False;

    def _id(prefix: str) -> str {
        tick = tick + 1;
        return prefix + "_" + str(_safeNow()) + "_" + str(tick);
    }

    def _getSession(sessionId: str) -> Any {
        for s in sessions or [] {
            if s and s["id"] == sessionId { return s; }
        }
        return None;
    }

    # ── Session actions ────────────────────────────────────────────────────

    def addSession(model: Any) -> str {
        id = _id("session");
        sessions = (sessions or []) + [_makeSession(id, model)];
        activeTabId = id;
        return id;
    }

    def removeSession(sessionId: str) -> None {
        remaining = [s for s in (sessions or []) if s and "id" in s and s["id"] != sessionId];
        sessions = remaining;
        if activeTabId == sessionId {
            nextActiveId = "";
            if remaining and len(remaining) > 0 {
                lastSession = remaining[len(remaining) - 1];
                if lastSession and "id" in lastSession {
                    nextActiveId = str(lastSession["id"]);
                }
            }
            activeTabId = nextActiveId;
        }
    }

    def setActiveTab(sessionId: str) -> None {
        activeTabId = sessionId;
    }

    def clearAllSessions -> None {
        sessions = [];
        activeTabId = "";
    }

    def clearSession(sessionId: str) -> None {
        target = _getSession(sessionId);
        if not target { return; }
        sessions = _replaceSess(sessions, sessionId, _makeSession(sessionId, target["model"]));
    }

    def updateSystemPrompt(prompt: str) -> None {
        systemPrompt = prompt;
    }

    def updateInputText(text: str) -> None {
        inputText = text;
    }

    def updateEnhancePrompt(enabled: bool) -> None {
        shouldEnhancePrompt = enabled;
    }

    def updateMessage(sessionId: str, messageId: str, content: str) -> None {
        target = _getSession(sessionId);
        if not target { return; }
        nextMsgs: list = [];
        for m in target["messages"] or [] {
            if not m { continue; }
            if m["id"] == messageId {
                nextMsgs.append({**m, "content": content, "status": "edited"});
            } else {
                nextMsgs.append(m);
            }
        }
        sessions = _replaceSess(sessions, sessionId, {**target, "messages": nextMsgs});
    }

    # ── Messaging ──────────────────────────────────────────────────────────
    # NOTE: All async funcs receive `curSessions` explicitly to avoid stale
    # React closure reads — setSessions() is async, so `sessions` in the
    # closure is always the value from the PREVIOUS render, not the latest.

    async def _runRequest(sessionId: str, curSessions: list, apiKeyGetter: Any) -> list {
        # Find target from the EXPLICITLY PASSED list, never from stale state
        target = None;
        for s in curSessions or [] {
            if s and s["id"] == sessionId { target = s; break; }
        }
        if not target { return curSessions; }

        model = target["model"] or {};
        provider = model["provider"] if model and "provider" in model else "openai";

        # Show loading immediately
        loadingSessions = _replaceSess(curSessions, sessionId, {
            **target, "isLoading": True, "error": None
        });
        sessions = loadingSessions;

        # Messages to send — taken from target (which came from curSessions, correct)
        msgsToSend = [m for m in (target["messages"] or []) if m and not m["pending"]];

        startedAt = _safeNow();
        result = await sendChatMessage(
            model["id"] if model and "id" in model else "",
            msgsToSend,
            apiKeyGetter(provider),
            provider,
            systemPrompt,
            shouldEnhancePrompt
        );
        elapsedMs = _safeNow() - startedAt;

        doneSessions = curSessions;
        if result and result["ok"] {
            payload = result["data"] or {};
            usage = _normUsage(payload["usage"] if payload and "usage" in payload else None);
            metrics = (payload and "metrics" in payload and payload["metrics"]) or {};
            doneSessions = _replaceSess(curSessions, sessionId, {
                **target,
                "messages": msgsToSend + [_makeMsg(_id("assistant"), "assistant",
                    str(payload["content"] if payload and "content" in payload else ""),
                    {
                        "status": "done",
                        "usage": usage,
                        "elapsed": elapsedMs,
                        "metrics": {
                            "latency_ms": int((metrics and "latency_ms" in metrics and metrics["latency_ms"]) or elapsedMs),
                            "estimated_cost_usd": float((metrics and "estimated_cost_usd" in metrics and metrics["estimated_cost_usd"]) or 0.0)
                        }
                    }
                )],
                "isLoading": False,
                "error": None,
                "tokenUsage": usage,
                "totalTokens": int(target["totalTokens"] or 0) + int(usage["total_tokens"] or 0),
                "promptMeta": payload["prompt_meta"] if payload and "prompt_meta" in payload else target["promptMeta"] or {"enhanced": False}
            });
        } else {
            doneSessions = _replaceSess(curSessions, sessionId, {
                **target,
                "messages": msgsToSend,
                "isLoading": False,
                "error": result["error"] if result and "error" in result else "Failed to get response from model."
            });
        }
        sessions = doneSessions;
        return doneSessions;
    }

    async def sendMessage(content: str, apiKeyGetter: Any) -> None {
        trimmed = content.strip();
        if not trimmed or not sessions or len(sessions) == 0 { return; }

        userMsgId = _id("user");
        # Build next state locally — don't rely on stale f"sessions"
        # Only append the new user message to sessions that have a valid model id.
        nextSessions: list = [];
        runnableIds: list = [];
        for s in sessions or [] {
            if not s { continue; }
            model = s["model"] if "model" in s and s["model"] else {};
            hasRunnableModel = model and "id" in model and str(model["id"]).strip();
            nextSess = {**s, "error": None};
            if hasRunnableModel {
                nextSess = {
                    **nextSess,
                    "messages": (s["messages"] or []) + [_makeMsg(userMsgId, "user", trimmed, {"status": "sent"})]
                };
                runnableIds.append(str(s["id"]));
            }
            nextSessions.append(nextSess);
        }
        sessions = nextSessions;
        inputText = "";

        # Chain requests only for runnable sessions.
        curSessions = nextSessions;
        for sessId in runnableIds {
            curSessions = await _runRequest(sessId, curSessions, apiKeyGetter);
        }
    }

    async def regenerateSession(sessionId: str, apiKeyGetter: Any) -> None {
        # Capture state synchronously BEFORE any await
        curSessions = sessions or [];
        target = None;
        for s in curSessions {
            if s and s["id"] == sessionId { target = s; break; }
        }
        if not target { return; }
        baseMessages = [m for m in (target["messages"] or []) if m and not m["pending"]];
        if baseMessages and baseMessages[-1]["role"] == "assistant" {
            baseMessages = baseMessages[:-1];
        }
        curSessions = _replaceSess(curSessions, sessionId, {**target, "messages": baseMessages, "error": None});
        sessions = curSessions;
        await _runRequest(sessionId, curSessions, apiKeyGetter);
    }

    async def editAndResend(sessionId: str, messageId: str, content: str, apiKeyGetter: Any) -> None {
        curSessions = sessions or [];
        target = None;
        for s in curSessions {
            if s and s["id"] == sessionId { target = s; break; }
        }
        if not target { return; }
        rebuilt: list = [];
        for m in target["messages"] or [] {
            if not m or m["pending"] { continue; }
            if m["id"] == messageId {
                rebuilt.append({**m, "content": content, "status": "edited"});
                break;
            }
            rebuilt.append(m);
        }
        curSessions = _replaceSess(curSessions, sessionId, {**target, "messages": rebuilt, "error": None});
        sessions = curSessions;
        await _runRequest(sessionId, curSessions, apiKeyGetter);
    }

    # ── localStorage hydration ─────────────────────────────────────────────

    async can with entry {
        saved = _loadSessions(_storageGet("jacplay_chat_sessions"));
        if saved { sessions = saved; }
        savedTab = _storageGet("jacplay_chat_active_tab");
        if savedTab { activeTabId = str(savedTab); }
        savedPrompt = _storageGet("jacplay_chat_system_prompt");
        if savedPrompt { systemPrompt = str(savedPrompt); }
        savedEnhance = _storageGet("jacplay_chat_enhance_prompt");
        if savedEnhance { shouldEnhancePrompt = savedEnhance == "true"; }
        hydrated = True;
    }

    can with [sessions] entry {
        if not hydrated { return; }
        if sessions and len(sessions) > 0 {
            _storageSet("jacplay_chat_sessions", JSON.stringify(sessions));
        } else {
            _storageRemove("jacplay_chat_sessions");
        }
    }

    can with [activeTabId] entry {
        if not hydrated { return; }
        if activeTabId { _storageSet("jacplay_chat_active_tab", activeTabId); }
        else { _storageRemove("jacplay_chat_active_tab"); }
    }

    can with [systemPrompt] entry {
        if not hydrated { return; }
        if systemPrompt { _storageSet("jacplay_chat_system_prompt", systemPrompt); }
        else { _storageRemove("jacplay_chat_system_prompt"); }
    }

    can with [shouldEnhancePrompt] entry {
        if not hydrated { return; }
        _storageSet("jacplay_chat_enhance_prompt", "true" if shouldEnhancePrompt else "false");
    }

    # ── Build context value (runs every render with fresh closures) ────────

    store = {
        "sessions":           sessions,
        "activeTabId":        activeTabId,
        "systemPrompt":       systemPrompt,
        "inputText":          inputText,
        "enhancePrompt":      shouldEnhancePrompt,
        "hydrated":           hydrated,
        "addSession":         addSession,
        "removeSession":      removeSession,
        "clearAllSessions":   clearAllSessions,
        "setActiveTab":       setActiveTab,
        "clearSession":       clearSession,
        "updateSystemPrompt": updateSystemPrompt,
        "updateInputText":    updateInputText,
        "setEnhancePrompt":   updateEnhancePrompt,
        "updateMessage":      updateMessage,
        "sendMessage":        sendMessage,
        "regenerateSession":  regenerateSession,
        "editAndResend":      editAndResend
    };

    return <ChatCtx.Provider value={store}>{props.children}</ChatCtx.Provider>;
}

def:pub useChatStore() -> Any {
    return useContext(ChatCtx);
}
