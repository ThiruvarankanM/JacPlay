import from services.provider_catalog { fetch_providers }
import from services.chat_service { send_chat_message, validate_api_key, build_system_prompt }
import from services.model_registry { fetch_model_catalog, search_model_catalog }

cl import ".global.css";

cl import from "@jac/runtime" { Router, Routes, Route }

cl import from .pages.layout { layout as Layout }
cl import from .pages.index { page as IndexPage }
cl import from .pages.play { page as PlayPage }
cl import from .pages.not_found { page as NotFoundPage }

cl def:pub app(props: dict) -> JsxElement {
    return <Router>
        <Routes>
            <Route path="/" element={<Layout/>}>
                <Route index element={<IndexPage/>} />
                <Route path="play" element={<PlayPage/>} />
                <Route path="*" element={<NotFoundPage/>} />
            </Route>
        </Routes>
    </Router>;
}
