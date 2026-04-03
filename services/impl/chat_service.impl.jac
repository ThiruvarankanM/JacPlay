"""Chat service implementation — routes messages to each AI provider's native API."""

impl send_chat_message(
    model_id: str,
    messages: list,
    api_key: str,
    provider: str,
    system_prompt: str
) -> dict {
    if not api_key or not api_key.strip() {
        return {
            "ok": False,
            "error": "No API key provided. Add your " + provider.title() + " key via the Keys panel.",
            "code": "MISSING_KEY"
        };
    }

    key = api_key.strip();

    if provider == "anthropic" {
        return _call_anthropic(model_id, messages, key, system_prompt);
    } elif provider == "google" {
        return _call_google(model_id, messages, key, system_prompt);
    } else {
        provider_urls = {
            "openai":   "https://api.openai.com/v1/chat/completions",
            "deepseek": "https://api.deepseek.com/v1/chat/completions",
            "mistral":  "https://api.mistral.ai/v1/chat/completions",
            "groq":     "https://api.groq.com/openai/v1/chat/completions",
            "cohere":   "https://api.cohere.com/compatibility/v1/chat/completions"
        };
        if provider in provider_urls {
            return _call_openai_compatible(model_id, messages, key, provider_urls[provider], system_prompt);
        }
        return {"ok": False, "error": "Unknown provider: " + provider, "code": "UNKNOWN_PROVIDER"};
    }
}

impl validate_api_key(provider: str, api_key: str) -> dict {
    if not api_key or not api_key.strip() {
        return {"ok": False, "error": "API key cannot be empty"};
    }
    test_models = {
        "openai":    "gpt-4o-mini",
        "anthropic": "claude-haiku-4-5-20251001",
        "google":    "gemini-2.0-flash-001",
        "deepseek":  "deepseek-chat",
        "mistral":   "mistral-small-latest",
        "groq":      "llama-3.1-8b-instant",
        "cohere":    "command-r"
    };
    test_model = test_models.get(provider, "");
    if not test_model {
        return {"ok": False, "error": "Cannot validate unknown provider: " + provider};
    }
    result = send_chat_message(
        test_model,
        [{"role": "user", "content": "hi"}],
        api_key.strip(),
        provider,
        ""
    );
    if result["ok"] {
        return {"ok": True, "data": {"valid": True, "provider": provider}};
    }
    return {"ok": False, "error": result.get("error", "Invalid API key — check and try again.")};
}


def _call_openai_compatible(model_id: str, messages: list, api_key: str, base_url: str, system_prompt: str) -> dict {
    import requests as _req;

    full_messages = [];
    if system_prompt and system_prompt.strip() {
        full_messages.append({"role": "system", "content": system_prompt.strip()});
    }
    for msg in messages {
        full_messages.append({"role": msg["role"], "content": msg["content"]});
    }

    headers = {
        "Authorization": "Bearer " + api_key,
        "Content-Type": "application/json"
    };
    # o1/o3/o4 reasoning models use max_completion_tokens and don't support temperature
    is_reasoning = (
        model_id.startswith("o1") or
        model_id.startswith("o3") or
        model_id.startswith("o4")
    );
    payload = {"model": model_id, "messages": full_messages};
    if is_reasoning {
        payload["max_completion_tokens"] = 4096;
    } else {
        payload["max_tokens"] = 4096;
        payload["temperature"] = 0.7;
    }

    try {
        resp = _req.post(base_url, headers=headers, json=payload, timeout=120);
    } except Exception as e {
        return {"ok": False, "error": "Network error: " + str(e), "code": "NETWORK_ERROR"};
    }

    try {
        data = resp.json();
    } except Exception {
        return {"ok": False, "error": "Invalid response from provider", "code": "PARSE_ERROR"};
    }

    if resp.status_code != 200 {
        err = data.get("error", {});
        msg = err.get("message", "API error (status " + str(resp.status_code) + ")") if isinstance(err, dict) else str(err);
        return {"ok": False, "error": msg, "code": "API_ERROR", "status": resp.status_code};
    }

    choices = data.get("choices", []);
    if not choices {
        return {"ok": False, "error": "No response from model.", "code": "EMPTY_RESPONSE"};
    }

    content = choices[0].get("message", {}).get("content", "") or "";
    usage = data.get("usage", {});
    return {
        "ok": True,
        "data": {
            "content": content,
            "model": data.get("model", model_id),
            "usage": {
                "prompt_tokens":     usage.get("prompt_tokens", 0),
                "completion_tokens": usage.get("completion_tokens", 0),
                "total_tokens":      usage.get("total_tokens", 0)
            }
        }
    };
}


def _call_anthropic(model_id: str, messages: list, api_key: str, system_prompt: str) -> dict {
    import requests as _req;

    sys_content = system_prompt.strip() if system_prompt else "";
    chat_messages = [];
    for msg in messages {
        if msg.get("role") == "system" {
            sys_content = msg.get("content", "");
        } else {
            chat_messages.append({"role": msg["role"], "content": msg["content"]});
        }
    }
    if not chat_messages {
        return {"ok": False, "error": "No messages to send.", "code": "EMPTY_MESSAGES"};
    }

    headers = {
        "x-api-key":         api_key,
        "anthropic-version": "2023-06-01",
        "Content-Type":      "application/json"
    };
    payload = {"model": model_id, "max_tokens": 4096, "messages": chat_messages};
    if sys_content {
        payload["system"] = sys_content;
    }

    try {
        resp = _req.post("https://api.anthropic.com/v1/messages", headers=headers, json=payload, timeout=120);
    } except Exception as e {
        return {"ok": False, "error": "Network error: " + str(e), "code": "NETWORK_ERROR"};
    }

    try {
        data = resp.json();
    } except Exception {
        return {"ok": False, "error": "Invalid response from Anthropic", "code": "PARSE_ERROR"};
    }

    if resp.status_code != 200 {
        err = data.get("error", {});
        msg = err.get("message", "Anthropic error (status " + str(resp.status_code) + ")") if isinstance(err, dict) else str(err);
        return {"ok": False, "error": msg, "code": "API_ERROR"};
    }

    blocks = data.get("content", []);
    content = blocks[0].get("text", "") if blocks else "";
    usage = data.get("usage", {});
    return {
        "ok": True,
        "data": {
            "content": content,
            "model": data.get("model", model_id),
            "usage": {
                "prompt_tokens":     usage.get("input_tokens", 0),
                "completion_tokens": usage.get("output_tokens", 0),
                "total_tokens":      usage.get("input_tokens", 0) + usage.get("output_tokens", 0)
            }
        }
    };
}


def _call_google(model_id: str, messages: list, api_key: str, system_prompt: str) -> dict {
    import requests as _req;

    clean_id = model_id[7:] if model_id.startswith("google/") else model_id;
    url = (
        "https://generativelanguage.googleapis.com/v1beta/models/"
        + clean_id + ":generateContent?key=" + api_key
    );

    contents = [];
    for msg in messages {
        if msg.get("role") == "system" {
            continue;
        }
        role = "user" if msg.get("role") == "user" else "model";
        contents.append({"role": role, "parts": [{"text": msg.get("content", "")}]});
    }
    if not contents {
        return {"ok": False, "error": "No messages to send.", "code": "EMPTY_MESSAGES"};
    }

    payload = {"contents": contents};
    if system_prompt and system_prompt.strip() {
        payload["systemInstruction"] = {"parts": [{"text": system_prompt.strip()}]};
    }

    try {
        resp = _req.post(url, headers={"Content-Type": "application/json"}, json=payload, timeout=120);
    } except Exception as e {
        return {"ok": False, "error": "Network error: " + str(e), "code": "NETWORK_ERROR"};
    }

    try {
        data = resp.json();
    } except Exception {
        return {"ok": False, "error": "Invalid response from Google AI", "code": "PARSE_ERROR"};
    }

    if resp.status_code != 200 {
        err = data.get("error", {});
        msg = err.get("message", "Google AI error (status " + str(resp.status_code) + ")") if isinstance(err, dict) else str(err);
        return {"ok": False, "error": msg, "code": "API_ERROR"};
    }

    candidates = data.get("candidates", []);
    if not candidates {
        return {"ok": False, "error": "No response from Google AI.", "code": "EMPTY_RESPONSE"};
    }

    parts = candidates[0].get("content", {}).get("parts", []);
    content = parts[0].get("text", "") if parts else "";
    meta = data.get("usageMetadata", {});
    return {
        "ok": True,
        "data": {
            "content": content,
            "model": clean_id,
            "usage": {
                "prompt_tokens":     meta.get("promptTokenCount", 0),
                "completion_tokens": meta.get("candidatesTokenCount", 0),
                "total_tokens":      meta.get("totalTokenCount", 0)
            }
        }
    };
}
