"""Textarea component — auto-grow capable."""

cl import from .utils { cn }

cl {
    def:pub Textarea(props: Any) -> JsxElement {
        restProps = {};
        excludeKeys = ["className", "label", "error", "hint"];
        Object.keys(props).forEach(lambda(key: Any) -> None {
            if excludeKeys.indexOf(key) == -1 {
                restProps[key] = props[key];
            }
        });

        return <div className="flex flex-col gap-1.5 w-full">
            {props.label and
                <label className="text-xs font-medium text-foreground">{props.label}</label>
            }
            <textarea
                className={cn(
                    "flex w-full rounded-lg border border-border bg-input px-3 py-2 text-sm text-foreground placeholder:text-muted-foreground",
                    "focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-1 focus:ring-offset-background",
                    "disabled:opacity-50 disabled:cursor-not-allowed transition-colors resize-none",
                    props.error and "border-destructive",
                    props.className
                )}
                {...restProps}
            />
            {props.error and <p className="text-xs text-destructive">{props.error}</p>}
            {props.hint and not props.error and
                <p className="text-xs text-muted-foreground">{props.hint}</p>
            }
        </div>;
    }
}
