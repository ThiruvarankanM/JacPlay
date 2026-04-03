"""Button component — variant + size aware."""

cl import from .utils { cn }

cl {
    def:pub Button(props: Any) -> JsxElement {
        variant = props.variant or "default";
        size = props.size or "default";
        disabled = props.disabled or False;

        base = "inline-flex items-center justify-center gap-2 font-semibold rounded-xl transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 cursor-pointer select-none shrink-0";

        variantCls = "bg-primary text-primary-foreground hover:bg-primary/90 shadow-sm shadow-primary/20";
        if variant == "secondary" { variantCls = "bg-secondary text-secondary-foreground hover:bg-secondary/80 border border-border"; }
        elif variant == "outline"  { variantCls = "bg-transparent border border-border text-foreground hover:bg-muted"; }
        elif variant == "ghost"    { variantCls = "bg-transparent text-foreground hover:bg-muted"; }
        elif variant == "destructive" { variantCls = "bg-destructive/10 text-destructive border border-destructive/30 hover:bg-destructive/20"; }
        elif variant == "link"     { variantCls = "bg-transparent text-primary underline-offset-4 hover:underline p-0 h-auto"; }
        elif variant == "primary-ghost" { variantCls = "bg-transparent text-primary hover:bg-primary/10 border border-primary/30"; }

        sizeCls = "text-sm h-9 px-4";
        if size == "sm"      { sizeCls = "text-xs h-7 px-3 rounded-lg"; }
        elif size == "lg"    { sizeCls = "text-sm h-11 px-6"; }
        elif size == "xl"    { sizeCls = "text-base h-12 px-8"; }
        elif size == "icon"  { sizeCls = "size-9 p-0"; }
        elif size == "icon-sm" { sizeCls = "size-7 p-0 rounded-lg"; }

        restProps = {};
        excludeKeys = ["variant", "size", "className", "children", "disabled"];
        Object.keys(props).forEach(lambda(key: Any) -> None {
            if excludeKeys.indexOf(key) == -1 {
                restProps[key] = props[key];
            }
        });

        return <button
            className={cn(base, variantCls, sizeCls, props.className)}
            disabled={disabled}
            {...restProps}
        >
            {props.children}
        </button>;
    }
}
