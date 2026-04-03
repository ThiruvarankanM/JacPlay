"""Spinner loading indicator."""

cl import from .utils { cn }

cl {
    def:pub Spinner(props: Any) -> JsxElement {
        size = props.size or "default";

        sizeCls = "size-4 border-2";
        if size == "sm"  { sizeCls = "size-3 border-[1.5px]"; }
        elif size == "lg" { sizeCls = "size-6 border-2"; }

        return <span
            className={cn(
                "animate-spin rounded-full border-current border-t-transparent inline-block",
                sizeCls,
                props.className
            )}
            role="status"
            aria-label="Loading"
        />;
    }

    def:pub TypingIndicator(props: Any) -> JsxElement {
        return <div className="flex items-center gap-1 py-1">
            <span className="typing-dot"/>
            <span className="typing-dot"/>
            <span className="typing-dot"/>
        </div>;
    }
}
