import from byllm.lib { Model }
import from services.provider_catalog { get_provider }
import from requests { post }

glob llm: Model = Model(model_name="openai/gpt-4o-mini");

sem enhance_system_prompt = """You improve chat system prompts for a general-purpose assistant.
Return only the improved system prompt text.
Keep it concise, safe, and broadly useful.
Do not mention hidden policies, chain-of-thought, or internal reasoning.
If the input is already good, lightly refine it.
""";

def enhance_system_prompt(prompt_seed: str) -> str by llm(
    temperature=0.2,
    reason="Generate a concise, safe, reusable system prompt for a chat assistant based on the provided context."
);

def _normalize_messages(messages: list, system_prompt: str) -> list {
    full_messages: list = [];
    if system_prompt and system_prompt.strip() {
        full_messages.append({"role": "system", "content": system_prompt.strip()});
    }
    for msg in messages {
        role = str(msg["role"]) if msg and "role" in msg else "user";
        content = str(msg["content"]) if msg and "content" in msg else "";
        if content.strip() {
            full_messages.append({"role": role, "content": content});
        }
    }
    return full_messages;
}

def _stringify_content(value: Any) -> str {
    if value == None {
        return "";
    }
    if isinstance(value, str) {
        return value;
    }
    if isinstance(value, list) {
        parts: list[str] = [];
        for item in value {
            if isinstance(item, str) {
                if item.strip() {
                    parts.append(item);
                }
            } elif item and isinstance(item, dict) {
                if "text" in item and str(item["text"]).strip() {
                    parts.append(str(item["text"]));
                } elif "content" in item and str(item["content"]).strip() {
                    parts.append(str(item["content"]));
                }
            }
        }
        return "\n".join(parts);
    }
    if isinstance(value, dict) {
        if "text" in value and str(value["text"]).strip() {
            return str(value["text"]);
        }
        if "content" in value and str(value["content"]).strip() {
            return str(value["content"]);
        }
    }
    return str(value);
}

def _safe_prompt_seed(messages: list, system_prompt: str) -> str {
    preview: list[str] = [];
    recent = messages[-4:] if len(messages) > 4 else messages;
    for msg in recent {
        role = str(msg["role"]) if msg and "role" in msg else "user";
        content = str(msg["content"]) if msg and "content" in msg else "";
        content = content.strip();
        if content {
            preview.append(role + ": " + content[:500]);
        }
    }
    seed = "Current system prompt:\n" + (system_prompt.strip() if system_prompt else "") + "\n\nRecent conversation:\n" + "\n".join(preview);
    return seed[:4000];
}

def:pub build_system_prompt(system_prompt: str = "", messages: list = None, enhance: bool = False) -> dict {
    safe_messages = messages or [];
    base_prompt = system_prompt.strip();
    if not enhance {
        return {"ok": True, "data": {"system_prompt": base_prompt, "enhanced": False}};
    }

    seed = _safe_prompt_seed(safe_messages, base_prompt);
    improved = enhance_system_prompt(seed).strip();
    if not improved {
        improved = base_prompt;
    }
    return {
        "ok": True,
        "data": {
            "system_prompt": improved,
            "enhanced": True,
            "source": "by_llm"
        }
    };
}

def:pub send_chat_message(
    model_id: str,
    messages: list,
    api_key: str,
    provider: str,
    system_prompt: str,
    enhance_prompt: bool = False
) -> dict {
    if not api_key or not api_key.strip() {
        provider_meta = get_provider(provider);
        return {
            "ok": False,
            "error": "No API key provided. Add your " + str(provider_meta["name"]) + " key via the Keys panel.",
            "code": "MISSING_KEY"
        };
    }

    final_prompt = system_prompt;
    prompt_meta = {"enhanced": False};
    if enhance_prompt {
        prompt_result = build_system_prompt(system_prompt, messages, True);
        if prompt_result and prompt_result["ok"] and prompt_result["data"] {
            final_prompt = str(prompt_result["data"]["system_prompt"]);
            prompt_meta = prompt_result["data"];
        }
    }

    key = api_key.strip();
    result = {"ok": False, "error": "Unknown provider", "code": "UNKNOWN_PROVIDER"};
    if provider == "anthropic" {
        result = _call_anthropic(model_id, messages, key, final_prompt);
    } elif provider == "google" {
        result = _call_google(model_id, messages, key, final_prompt);
    } else {
        provider_meta = get_provider(provider);
        base_url = str(provider_meta["chat_url"]) if provider_meta and "chat_url" in provider_meta else "";
        if not base_url {
            return {"ok": False, "error": "Unknown provider: " + provider, "code": "UNKNOWN_PROVIDER"};
        }
        result = _call_openai_compatible(model_id, messages, key, base_url, final_prompt);
    }

    if result and result["ok"] and result["data"] {
        result["data"]["system_prompt"] = final_prompt;
        result["data"]["prompt_meta"] = prompt_meta;
    }
    return result;
}

def:pub validate_api_key(provider: str, api_key: str) -> dict {
    key = api_key.strip() if api_key else "";
    if not key {
        return {"ok": False, "error": "API key cannot be empty"};
    }

    provider_meta = get_provider(provider);
    test_model = str(provider_meta["validation_model"]) if provider_meta and "validation_model" in provider_meta else "";
    if not test_model {
        return {"ok": False, "error": "Cannot validate unknown provider: " + provider};
    }

    result = send_chat_message(test_model, [{"role": "user", "content": "hi"}], key, provider, "", False);
    if result and result["ok"] {
        return {"ok": True, "data": {"valid": True, "provider": provider, "mode": "live"}};
    }

    err = str(result["error"]) if result and "error" in result else "";
    status = int(result["status"]) if result and "status" in result else 0;
    lower_err = err.lower();

    auth_failed = (
        status == 401 or
        status == 403 or
        "invalid api key" in lower_err or
        "incorrect api key" in lower_err or
        "authentication" in lower_err or
        "unauthorized" in lower_err or
        "invalid x-api-key" in lower_err or
        "api key not valid" in lower_err or
        "permission denied" in lower_err
    );

    if auth_failed {
        return {"ok": False, "error": err or "Invalid API key. Check and try again.", "code": "INVALID_KEY"};
    }

    return {
        "ok": True,
        "data": {
            "valid": True,
            "provider": provider,
            "mode": "format_only",
            "warning": err or "Key format looks valid, but live verification could not be completed right now."
        }
    };
}

def _call_openai_compatible(model_id: str, messages: list, api_key: str, base_url: str, system_prompt: str) -> dict {
    full_messages = _normalize_messages(messages, system_prompt);
    headers = {
        "Authorization": "Bearer " + api_key,
        "Content-Type": "application/json"
    };
    is_reasoning = model_id.startswith("o1") or model_id.startswith("o3") or model_id.startswith("o4");
    payload = {"model": model_id, "messages": full_messages};
    if is_reasoning {
        payload = {"model": model_id, "messages": full_messages, "max_completion_tokens": 4096};
    } else {
        payload = {"model": model_id, "messages": full_messages, "max_tokens": 4096, "temperature": 0.7};
    }

    resp = post(base_url, headers=headers, json=payload, timeout=120);
    data = resp.json();
    status_code = int(resp.status_code);
    if status_code != 200 {
        err = data["error"] if data and "error" in data else {};
        msg = err["message"] if err and "message" in err else "API error (status " + str(status_code) + ")";
        lower_msg = str(msg).lower();
        if status_code == 401 or status_code == 403 or "invalid api key" in lower_msg or "incorrect api key" in lower_msg or "unauthorized" in lower_msg or "authentication" in lower_msg {
            return {
                "ok": False,
                "error": "Invalid API key for this provider. Update it from the Keys panel and try again.",
                "code": "INVALID_KEY",
                "status": status_code,
                "action": "ADD_KEY"
            };
        }
        return {"ok": False, "error": str(msg), "code": "API_ERROR", "status": status_code};
    }

    choices = data["choices"] if data and "choices" in data else [];
    if not choices {
        return {"ok": False, "error": "No response from model.", "code": "EMPTY_RESPONSE"};
    }

    message = choices[0]["message"] if choices[0] and "message" in choices[0] else {};
    usage = data["usage"] if data and "usage" in data else {};
    content = _stringify_content(message["content"]) if message and "content" in message else "";
    if not content.strip() {
        return {
            "ok": False,
            "error": "Provider returned an empty message for this model.",
            "code": "EMPTY_RESPONSE",
            "status": status_code,
            "details": choices[0]
        };
    }
    return {
        "ok": True,
        "data": {
            "content": content,
            "model": data["model"] if data and "model" in data else model_id,
            "usage": {
                "prompt_tokens": usage["prompt_tokens"] if usage and "prompt_tokens" in usage else 0,
                "completion_tokens": usage["completion_tokens"] if usage and "completion_tokens" in usage else 0,
                "total_tokens": usage["total_tokens"] if usage and "total_tokens" in usage else 0
            }
        }
    };
}

def _call_anthropic(model_id: str, messages: list, api_key: str, system_prompt: str) -> dict {
    sys_content = system_prompt.strip() if system_prompt else "";
    chat_messages: list = [];
    for msg in messages {
        if msg and "role" in msg and msg["role"] == "system" {
            sys_content = str(msg["content"]) if "content" in msg else sys_content;
        } else {
            chat_messages.append({
                "role": msg["role"] if msg and "role" in msg else "user",
                "content": msg["content"] if msg and "content" in msg else ""
            });
        }
    }
    if not chat_messages {
        return {"ok": False, "error": "No messages to send.", "code": "EMPTY_MESSAGES"};
    }

    headers = {
        "x-api-key": api_key,
        "anthropic-version": "2023-06-01",
        "Content-Type": "application/json"
    };
    payload = {"model": model_id, "max_tokens": 4096, "messages": chat_messages};
    if sys_content {
        payload = {"model": model_id, "max_tokens": 4096, "messages": chat_messages, "system": sys_content};
    }

    resp = post("https://api.anthropic.com/v1/messages", headers=headers, json=payload, timeout=120);
    data = resp.json();
    status_code = int(resp.status_code);
    if status_code != 200 {
        err = data["error"] if data and "error" in data else {};
        msg = err["message"] if err and "message" in err else "Anthropic error (status " + str(status_code) + ")";
        lower_msg = str(msg).lower();
        if status_code == 401 or status_code == 403 or "invalid api key" in lower_msg or "unauthorized" in lower_msg or "authentication" in lower_msg or "invalid x-api-key" in lower_msg {
            return {
                "ok": False,
                "error": "Invalid API key for this provider. Update it from the Keys panel and try again.",
                "code": "INVALID_KEY",
                "status": status_code,
                "action": "ADD_KEY"
            };
        }
        return {"ok": False, "error": str(msg), "code": "API_ERROR", "status": status_code};
    }

    blocks = data["content"] if data and "content" in data else [];
    usage = data["usage"] if data and "usage" in data else {};
    content = _stringify_content(blocks);
    if not content.strip() {
        return {
            "ok": False,
            "error": "Anthropic returned an empty message for this model.",
            "code": "EMPTY_RESPONSE",
            "status": status_code,
            "details": data
        };
    }
    input_tokens = int(usage["input_tokens"]) if usage and "input_tokens" in usage else 0;
    output_tokens = int(usage["output_tokens"]) if usage and "output_tokens" in usage else 0;
    return {
        "ok": True,
        "data": {
            "content": content,
            "model": data["model"] if data and "model" in data else model_id,
            "usage": {
                "prompt_tokens": input_tokens,
                "completion_tokens": output_tokens,
                "total_tokens": input_tokens + output_tokens
            }
        }
    };
}

def _call_google(model_id: str, messages: list, api_key: str, system_prompt: str) -> dict {
    clean_id = model_id[7:] if model_id.startswith("google/") else model_id;
    url = "https://generativelanguage.googleapis.com/v1beta/models/" + clean_id + ":generateContent?key=" + api_key;

    contents: list = [];
    for msg in messages {
        if msg and "role" in msg and msg["role"] == "system" {
            continue;
        }
        role = "user" if msg and "role" in msg and msg["role"] == "user" else "model";
        text = msg["content"] if msg and "content" in msg else "";
        contents.append({"role": role, "parts": [{"text": text}]});
    }
    if not contents {
        return {"ok": False, "error": "No messages to send.", "code": "EMPTY_MESSAGES"};
    }

    payload = {"contents": contents};
    if system_prompt and system_prompt.strip() {
        payload = {"contents": contents, "systemInstruction": {"parts": [{"text": system_prompt.strip()}]}};
    }

    resp = post(url, headers={"Content-Type": "application/json"}, json=payload, timeout=120);
    data = resp.json();
    status_code = int(resp.status_code);
    if status_code != 200 {
        err = data["error"] if data and "error" in data else {};
        msg = err["message"] if err and "message" in err else "Google AI error (status " + str(status_code) + ")";
        lower_msg = str(msg).lower();
        if status_code == 401 or status_code == 403 or "api key not valid" in lower_msg or "invalid api key" in lower_msg or "unauthorized" in lower_msg or "authentication" in lower_msg {
            return {
                "ok": False,
                "error": "Invalid API key for this provider. Update it from the Keys panel and try again.",
                "code": "INVALID_KEY",
                "status": status_code,
                "action": "ADD_KEY"
            };
        }
        return {"ok": False, "error": str(msg), "code": "API_ERROR", "status": status_code};
    }

    candidates = data["candidates"] if data and "candidates" in data else [];
    if not candidates {
        return {"ok": False, "error": "No response from Google AI.", "code": "EMPTY_RESPONSE"};
    }

    candidate = candidates[0] if candidates else {};
    content_obj = candidate["content"] if candidate and "content" in candidate else {};
    parts = content_obj["parts"] if content_obj and "parts" in content_obj else [];
    content = _stringify_content(parts);
    if not content.strip() {
        return {
            "ok": False,
            "error": "Google AI returned an empty message for this model.",
            "code": "EMPTY_RESPONSE",
            "status": status_code,
            "details": candidate
        };
    }
    meta = data["usageMetadata"] if data and "usageMetadata" in data else {};
    return {
        "ok": True,
        "data": {
            "content": content,
            "model": clean_id,
            "usage": {
                "prompt_tokens": meta["promptTokenCount"] if meta and "promptTokenCount" in meta else 0,
                "completion_tokens": meta["candidatesTokenCount"] if meta and "candidatesTokenCount" in meta else 0,
                "total_tokens": meta["totalTokenCount"] if meta and "totalTokenCount" in meta else 0
            }
        }
    };
}
