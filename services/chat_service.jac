"""Chat service interface — send messages to AI models."""

def:pub send_chat_message(
    model_id: str,
    messages: list,
    api_key: str,
    provider: str,
    system_prompt: str
) -> dict;

def:pub validate_api_key(provider: str, api_key: str) -> dict;
