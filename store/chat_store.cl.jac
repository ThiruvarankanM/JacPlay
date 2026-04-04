"""Chat store — manages chat sessions (one per active model tab)."""

cl import from "react" { createContext, useContext, useRef }

glob ChatCtx: Any = createContext(None);

def:pub ChatProvider(props: Any) -> JsxElement {
    has sessions: Any = [];        # array of session objects
    has activeTabId: str = "";     # currently visible tab
    has systemPrompt: str = "";    # shared system prompt
    has inputText: str = "";       # current message draft
    has useFunctionApi: bool = False;  # runtime compatibility switch for API routing

    # Ref always points to the latest sessions — used inside async callbacks
    # to avoid stale closure where `sessions` reads the render-time snapshot.
    sessionsRef = useRef([]);
    sessionsRef["current"] = sessions;

    def _makeId -> str {
        return "s_" + str(Date.now()) + "_" + str(Math.floor(Math.random() * 10000));
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
            "totalTokens": 0
        };
        sessions = sessions.concat([newSession]);
        activeTabId = id;
        return id;
    }

    def removeSession(sessionId: str) -> None {
        remaining = sessions.filter(lambda(s: Any) -> bool { return s["id"] != sessionId; });
        sessions = remaining;
        if activeTabId == sessionId {
            if remaining.length > 0 {
                activeTabId = remaining[remaining.length - 1]["id"];
            } else {
                activeTabId = "";
            }
        }
    }

    def setActiveTab(sessionId: str) -> None {
        activeTabId = sessionId;
    }

    def clearSession(sessionId: str) -> None {
        sessions = sessions.map(lambda(s: Any) -> Any {
            if s["id"] == sessionId {
                return {
                    "id": s["id"],
                    "model": s["model"],
                    "messages": [],
                    "isLoading": False,
                    "error": None,
                    "tokenUsage": None,
                    "totalTokens": 0
                };
            }
            return s;
        });
    }

    def updateSystemPrompt(prompt: str) -> None {
        systemPrompt = prompt;
    }

    def updateInputText(text: str) -> None {
        inputText = text;
    }

    def sendMessage(content: str, apiKeyGetter: Any) -> None {
        if sessions.length == 0 { return; }
        if not content.trim() { return; }

        trimmed = content.trim();

        # Add user message to all sessions & mark loading
        # Store in local var first — sessions setState is async so we need
        # the updated list immediately for the fetch calls below.
        updatedSessions = sessions.map(lambda(s: Any) -> Any {
            updatedMessages = s["messages"].concat([{
                "role": "user",
                "content": trimmed,
                "id": _makeId()
            }]);
            return {
                "id": s["id"],
                "model": s["model"],
                "messages": updatedMessages,
                "isLoading": True,
                "error": None,
                "tokenUsage": s["tokenUsage"],
                "totalTokens": s["totalTokens"] or 0
            };
        });
        sessions = updatedSessions;

        inputText = "";

        # Fire async call per session (fire-and-forget for parallelism)
        updatedSessions.forEach(lambda(sess: Any) -> None {
            model = sess["model"];
            provider = model["provider"] or "openai";
            apiKey = apiKeyGetter(provider);

            # Build message array including system prompt
            msgList = [];
            if systemPrompt and systemPrompt.trim() {
                msgList = msgList.concat([{"role": "system", "content": systemPrompt.trim()}]);
            }
            msgList = msgList.concat(sess["messages"]);

            sessId = sess["id"];

            async def _requestChat(reqBody: Any) -> Any {
                if useFunctionApi {
                    fnResp = await fetch("/function/api_chat", {
                        "method": "POST",
                        "headers": {"Content-Type": "application/json"},
                        "body": JSON.stringify(reqBody)
                    });
                    return await fnResp.json();
                }

                respObj = await fetch("/api/chat", {
                    "method": "POST",
                    "headers": {"Content-Type": "application/json"},
                    "body": JSON.stringify(reqBody)
                });

                statusCode = int(respObj["status"] or 0);
                if statusCode == 404 {
                    useFunctionApi = True;
                    fnResp = await fetch("/function/api_chat", {
                        "method": "POST",
                        "headers": {"Content-Type": "application/json"},
                        "body": JSON.stringify(reqBody)
                    });
                    return await fnResp.json();
                }

                contentType = str(respObj["headers"].get("content-type") or "").toLowerCase();
                if contentType.indexOf("application/json") >= 0 {
                    return await respObj.json();
                }

                # Jac runtime fallback: switch once, then keep using function route.
                useFunctionApi = True;
                fnResp = await fetch("/function/api_chat", {
                    "method": "POST",
                    "headers": {"Content-Type": "application/json"},
                    "body": JSON.stringify(reqBody)
                });
                return await fnResp.json();
            }

            async def _doFetch -> None {
                startTime = int(Date.now());
                reqBody = {
                    "model_id": model["id"],
                    "messages": msgList,
                    "api_key": apiKey,
                    "provider": provider,
                    "system_prompt": ""
                };
                respJson = await _requestChat(reqBody);
                result = respJson["data"] and respJson["data"]["result"] or respJson["data"] or respJson;

                elapsed = int(Date.now()) - startTime;
                if result["ok"] {
                    assistantContent = result["data"]["content"] or "";
                    usage = result["data"]["usage"] or None;
                    sessions = sessionsRef["current"].map(lambda(s: Any) -> Any {
                        if s["id"] == sessId {
                            msgs = s["messages"].concat([{
                                "role": "assistant",
                                "content": assistantContent,
                                "id": _makeId(),
                                "usage": usage,
                                "elapsed": elapsed
                            }]);
                            prevTotal = s["totalTokens"] or 0;
                            addedTokens = usage and usage["total_tokens"] or 0;
                            return {
                                "id": s["id"],
                                "model": s["model"],
                                "messages": msgs,
                                "isLoading": False,
                                "error": None,
                                "tokenUsage": usage,
                                "totalTokens": int(prevTotal) + int(addedTokens)
                            };
                        }
                        return s;
                    });
                } else {
                    errMsg = result["error"] or "Failed to get response from model.";
                    sessions = sessionsRef["current"].map(lambda(s: Any) -> Any {
                        if s["id"] == sessId {
                            return {
                                "id": s["id"],
                                "model": s["model"],
                                "messages": s["messages"],
                                "isLoading": False,
                                "error": errMsg,
                                "tokenUsage": None
                            };
                        }
                        return s;
                    });
                }
            }
            _doFetch();
        });
    }

    store = {
        "sessions": sessions,
        "activeTabId": activeTabId,
        "systemPrompt": systemPrompt,
        "inputText": inputText,
        "addSession": addSession,
        "removeSession": removeSession,
        "setActiveTab": setActiveTab,
        "clearSession": clearSession,
        "updateSystemPrompt": updateSystemPrompt,
        "updateInputText": updateInputText,
        "sendMessage": sendMessage
    };

    return <ChatCtx.Provider value={store}>{props.children}</ChatCtx.Provider>;
}

def:pub useChatStore() -> Any {
    return useContext(ChatCtx);
}
