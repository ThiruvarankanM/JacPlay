cl import from "@jac/runtime" { Outlet }
cl import from ..store.app_store { AppProvider }
cl import from ..store.chat_store { ChatProvider }

cl def:pub layout -> JsxElement {
    return <AppProvider>
        <ChatProvider>
            <div className="min-h-screen bg-background text-foreground">
                <Outlet />
            </div>
        </ChatProvider>
    </AppProvider>;
}
