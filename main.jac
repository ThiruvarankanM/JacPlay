import from services.provider_catalog { fetch_providers }
import from services.chat_service { send_chat_message, validate_api_key, build_system_prompt }
import from services.model_registry { fetch_model_catalog, search_model_catalog }

cl import ".global.css";

cl def:pub app(props: dict) -> JsxElement {
    return props.children;
}
