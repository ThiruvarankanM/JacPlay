"""
Returns the full model list directly without graph operations so it works
reliably on any fresh clone without needing a seeded graph database.
"""

import from .provider_catalog { get_providers }

glob _CATEGORIES: list[dict] = [
    {"id": "flagship",  "name": "Flagship Models",       "description": "Best overall performance across all tasks"},
    {"id": "reasoning", "name": "Reasoning Models",      "description": "Deep logical thinking, math and science"},
    {"id": "coding",    "name": "Best Coding Models",    "description": "Optimized for code generation and debugging"},
    {"id": "fast",      "name": "Fast and Affordable",   "description": "Low latency and cost-efficient for everyday use"},
    {"id": "vision",    "name": "Vision Models",         "description": "Understand images, diagrams and screenshots"},
    {"id": "roleplay",  "name": "Roleplay and Creative", "description": "Character play, storytelling and creative writing"}
];

glob _MODELS: list[dict] = [
    {"id": "gpt-4o",           "name": "GPT-4o",           "short_name": "GPT-4o",       "provider": "openai",    "provider_display": "OpenAI",     "categories": ["flagship","coding","vision"],            "supports_vision": True,  "is_free": False, "context_length": 128000,  "color": "#10a37f", "avatar": "G",  "description": "OpenAI flagship multimodal model. Excellent at reasoning, coding and vision."},
    {"id": "gpt-4o-mini",      "name": "GPT-4o mini",      "short_name": "4o mini",      "provider": "openai",    "provider_display": "OpenAI",     "categories": ["fast"],                                 "supports_vision": True,  "is_free": False, "context_length": 128000,  "color": "#10a37f", "avatar": "G",  "description": "Small, fast and capable. Best value for everyday tasks from OpenAI."},
    {"id": "gpt-4.1",          "name": "GPT-4.1",          "short_name": "GPT-4.1",      "provider": "openai",    "provider_display": "OpenAI",     "categories": ["flagship","coding"],                    "supports_vision": True,  "is_free": False, "context_length": 1047576, "color": "#10a37f", "avatar": "G",  "description": "OpenAI frontier model with 1M token context. Optimized for coding and instruction following."},
    {"id": "o4-mini",          "name": "o4-mini",          "short_name": "o4-mini",      "provider": "openai",    "provider_display": "OpenAI",     "categories": ["reasoning","coding"],                   "supports_vision": False, "is_free": False, "context_length": 200000,  "color": "#10a37f", "avatar": "o4", "description": "Fast and capable reasoning model from OpenAI. Strong at math, science and complex logic."},
    {"id": "o3-mini",          "name": "o3-mini",          "short_name": "o3-mini",      "provider": "openai",    "provider_display": "OpenAI",     "categories": ["reasoning"],                            "supports_vision": False, "is_free": False, "context_length": 200000,  "color": "#10a37f", "avatar": "o3", "description": "Cost-efficient reasoning model with strong STEM and logic capabilities."},

    {"id": "claude-opus-4-6",           "name": "Claude Opus 4.6",   "short_name": "Opus 4.6",   "provider": "anthropic", "provider_display": "Anthropic",  "categories": ["flagship","coding","vision"],            "supports_vision": True,  "is_free": False, "context_length": 200000,  "color": "#e07842", "avatar": "C",  "description": "Anthropic most intelligent model. Exceptional at nuanced analysis and complex reasoning."},
    {"id": "claude-sonnet-4-6",         "name": "Claude Sonnet 4.6", "short_name": "Sonnet 4.6", "provider": "anthropic", "provider_display": "Anthropic",  "categories": ["flagship","coding","reasoning","vision"], "supports_vision": True,  "is_free": False, "context_length": 200000,  "color": "#e07842", "avatar": "C",  "description": "Ideal balance of intelligence and speed. Great at coding, writing and analysis."},
    {"id": "claude-haiku-4-5-20251001", "name": "Claude Haiku 4.5", "short_name": "Haiku 4.5",  "provider": "anthropic", "provider_display": "Anthropic",  "categories": ["fast"],                                 "supports_vision": True,  "is_free": False, "context_length": 200000,  "color": "#e07842", "avatar": "C",  "description": "Anthropic fastest model. Perfect for high-throughput, low-latency tasks."},

    {"id": "gemini-2.5-pro-preview",   "name": "Gemini 2.5 Pro",   "short_name": "Gemini 2.5 Pro", "provider": "google", "provider_display": "Google", "categories": ["flagship","coding","vision"],  "supports_vision": True,  "is_free": False, "context_length": 1000000, "color": "#4285f4", "avatar": "Ge", "description": "Google most capable model with 1M token context. Excellent for complex tasks and vision."},
    {"id": "gemini-2.5-flash-preview", "name": "Gemini 2.5 Flash", "short_name": "Flash 2.5",     "provider": "google", "provider_display": "Google", "categories": ["fast","reasoning"],            "supports_vision": True,  "is_free": False, "context_length": 1000000, "color": "#4285f4", "avatar": "Gf", "description": "Fast and capable multimodal model. Excellent price-performance with long context."},
    {"id": "gemini-2.0-flash-001",     "name": "Gemini 2.0 Flash", "short_name": "Flash 2.0",     "provider": "google", "provider_display": "Google", "categories": ["fast","vision"],               "supports_vision": True,  "is_free": False, "context_length": 1000000, "color": "#4285f4", "avatar": "Gf", "description": "Google efficient multimodal model with real-time capabilities and tool use."},

    {"id": "deepseek-reasoner", "name": "DeepSeek R1", "short_name": "R1", "provider": "deepseek", "provider_display": "DeepSeek", "categories": ["reasoning","coding"], "supports_vision": False, "is_free": False, "context_length": 64000, "color": "#0ea5e9", "avatar": "DR", "description": "Open-source reasoning model with visible chain-of-thought."},
    {"id": "deepseek-chat",     "name": "DeepSeek V3", "short_name": "V3", "provider": "deepseek", "provider_display": "DeepSeek", "categories": ["flagship","coding"],  "supports_vision": False, "is_free": False, "context_length": 64000, "color": "#0ea5e9", "avatar": "DV", "description": "DeepSeek powerful open-source chat model. Strong coding at low cost."},

    {"id": "mistral-large-latest", "name": "Mistral Large", "short_name": "Mistral Large", "provider": "mistral", "provider_display": "Mistral AI", "categories": ["flagship","coding"], "supports_vision": False, "is_free": False, "context_length": 131072, "color": "#ff7000", "avatar": "M",  "description": "Mistral most capable model. Strong multilingual support and coding."},
    {"id": "mistral-small-latest", "name": "Mistral Small", "short_name": "Mistral Small", "provider": "mistral", "provider_display": "Mistral AI", "categories": ["fast"],             "supports_vision": False, "is_free": False, "context_length": 131072, "color": "#ff7000", "avatar": "Ms", "description": "Fast and efficient from Mistral. Great for everyday tasks and batch processing."},
    {"id": "codestral-latest",     "name": "Codestral",     "short_name": "Codestral",     "provider": "mistral", "provider_display": "Mistral AI", "categories": ["coding"],           "supports_vision": False, "is_free": False, "context_length": 131072, "color": "#ff7000", "avatar": "Mc", "description": "Mistral dedicated code model. Trained on 80+ programming languages."},

    {"id": "llama-3.3-70b-versatile", "name": "Llama 3.3 70B", "short_name": "Llama 3.3", "provider": "groq", "provider_display": "Groq", "categories": ["fast","flagship"], "supports_vision": False, "is_free": False, "context_length": 131072, "color": "#f97316", "avatar": "L", "description": "Meta 70B open-source model served at blazing speed via Groq LPU inference."},
    {"id": "llama-3.1-8b-instant",   "name": "Llama 3.1 8B",  "short_name": "Llama 8B",  "provider": "groq", "provider_display": "Groq", "categories": ["fast"],            "supports_vision": False, "is_free": False, "context_length": 131072, "color": "#f97316", "avatar": "L", "description": "Ultra-fast 8B model via Groq. Ideal for real-time and lightweight tasks."},

    {"id": "command-r-plus", "name": "Command R+", "short_name": "Command R+", "provider": "cohere", "provider_display": "Cohere", "categories": ["flagship","roleplay"], "supports_vision": False, "is_free": False, "context_length": 128000, "color": "#39594d", "avatar": "Co", "description": "Cohere most capable model. Excellent at RAG, tool use and long-form generation."}
];

def:pub get_all_models() -> list[dict] {
    return _MODELS;
}

def:pub get_categories() -> list[dict] {
    return _CATEGORIES;
}

def:pub search_models(query: str = "", category: str = "", provider: str = "") -> list[dict] {
    q: str = query.lower() if query else "";
    filtered: list[dict] = [];
    for m in _MODELS {
        if category and category not in m["categories"] { continue; }
        if provider and m["provider"] != provider { continue; }
        if q {
            if q not in m["name"].lower() and q not in m["id"].lower() and q not in m["description"].lower() {
                continue;
            }
        }
        filtered.append(m);
    }
    return filtered;
}
