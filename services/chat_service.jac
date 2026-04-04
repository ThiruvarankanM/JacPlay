"""Chat service interface — send messages to AI models."""

def:pub send_chat_message(
    model_id: str,
    messages: list,
    api_key: str,
    provider: str,
    system_prompt: str,
    enhance_prompt: bool = False
) -> dict;

def:pub validate_api_key(provider: str, api_key: str) -> dict;

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

import from services.provider_catalog { get_provider }
import from requests { post }
import from byllm.lib { Model }

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
