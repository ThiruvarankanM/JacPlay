glob _PROVIDERS: list[dict] = [
    {
        "id": "openai",
        "name": "OpenAI",
        "description": "GPT-4o, o4-mini, GPT-4.1 and more",
        "color": "#10a37f",
        "key_placeholder": "sk-proj-...",
        "key_help_text": "Get your key at platform.openai.com/api-keys",
        "key_help_url": "https://platform.openai.com/api-keys",
        "chat_url": "https://api.openai.com/v1/chat/completions",
        "validation_model": "gpt-4o-mini"
    },
    {
        "id": "anthropic",
        "name": "Anthropic",
        "description": "Claude Opus 4.6, Sonnet 4.6, Haiku 4.5",
        "color": "#e07842",
        "key_placeholder": "sk-ant-api03-...",
        "key_help_text": "Get your key at console.anthropic.com",
        "key_help_url": "https://console.anthropic.com/settings/keys",
        "chat_url": "https://api.anthropic.com/v1/messages",
        "validation_model": "claude-haiku-4-5-20251001"
    },
    {
        "id": "google",
        "name": "Google AI",
        "description": "Gemini 2.5 Pro, Flash and more",
        "color": "#4285f4",
        "key_placeholder": "AIzaSy...",
        "key_help_text": "Free key at aistudio.google.com",
        "key_help_url": "https://aistudio.google.com/app/apikey",
        "chat_url": "https://generativelanguage.googleapis.com",
        "validation_model": "gemini-2.0-flash-001"
    },
    {
        "id": "deepseek",
        "name": "DeepSeek",
        "description": "DeepSeek R1 and V3 models",
        "color": "#0ea5e9",
        "key_placeholder": "sk-...",
        "key_help_text": "Get your key at platform.deepseek.com",
        "key_help_url": "https://platform.deepseek.com/api_keys",
        "chat_url": "https://api.deepseek.com/v1/chat/completions",
        "validation_model": "deepseek-chat"
    },
    {
        "id": "mistral",
        "name": "Mistral AI",
        "description": "Mistral Large, Small, Codestral",
        "color": "#ff7000",
        "key_placeholder": "...",
        "key_help_text": "Get your key at console.mistral.ai",
        "key_help_url": "https://console.mistral.ai/api-keys",
        "chat_url": "https://api.mistral.ai/v1/chat/completions",
        "validation_model": "mistral-small-latest"
    },
    {
        "id": "groq",
        "name": "Groq",
        "description": "Llama 3.3, Gemma at blazing speed",
        "color": "#f97316",
        "key_placeholder": "gsk_...",
        "key_help_text": "Free key at console.groq.com/keys",
        "key_help_url": "https://console.groq.com/keys",
        "chat_url": "https://api.groq.com/openai/v1/chat/completions",
        "validation_model": "llama-3.1-8b-instant"
    },
    {
        "id": "cohere",
        "name": "Cohere",
        "description": "Command R+ and Command models",
        "color": "#39594d",
        "key_placeholder": "...",
        "key_help_text": "Free key at dashboard.cohere.com",
        "key_help_url": "https://dashboard.cohere.com/api-keys",
        "chat_url": "https://api.cohere.com/compatibility/v1/chat/completions",
        "validation_model": "command-r"
    }
];

def:pub get_providers() -> list[dict] {
    return _PROVIDERS;
}

def:pub fetch_providers() -> list[dict] {
    return _PROVIDERS;
}

def:pub get_provider(provider_id: str) -> dict {
    for provider in _PROVIDERS {
        if provider["id"] == provider_id {
            return provider;
        }
    }
    return {
        "id": provider_id,
        "name": provider_id,
        "description": "",
        "color": "#7c3aed",
        "key_placeholder": "...",
        "key_help_text": "Get your API key",
        "key_help_url": "#",
        "chat_url": "",
        "validation_model": ""
    };
}
