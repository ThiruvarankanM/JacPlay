"""Badge component."""

cl import from .utils { cn }

cl {
    def:pub Badge(props: Any) -> JsxElement {
        variant = props.variant or "default";

        base = "inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-medium border transition-colors";

        variantCls = "bg-primary/10 text-primary border-primary/20";
        if variant == "secondary" { variantCls = "bg-secondary text-secondary-foreground border-border"; }
        elif variant == "outline"  { variantCls = "bg-transparent text-foreground border-border"; }
        elif variant == "success"  { variantCls = "bg-success/10 text-success border-success/20"; }
        elif variant == "destructive" { variantCls = "bg-destructive/10 text-destructive border-destructive/20"; }
        elif variant == "free"     { variantCls = "bg-success/10 text-success border-success/20"; }
        elif variant == "muted"    { variantCls = "bg-muted text-muted-foreground border-transparent"; }

        return <span className={cn(base, variantCls, props.className)}>
            {props.children}
        </span>;
    }
}
