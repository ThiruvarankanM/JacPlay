"""404 — page not found."""

cl import from "@jac/runtime" { Link }
cl import from "lucide-react" { Play, ArrowLeft }

cl {
    def:pub page -> JsxElement {
        return <div className="flex flex-col items-center justify-center min-h-[70vh] text-center px-5">
            <div className="w-16 h-16 rounded-2xl bg-primary/10 border border-primary/20 flex items-center justify-center mb-6">
                <Play size={28} className="text-primary fill-primary"/>
            </div>
            <h1 className="text-4xl font-bold text-foreground mb-3">{"404"}</h1>
            <p className="text-muted-foreground mb-6 max-w-sm">{"This page doesn't exist. Head back to the playground."}</p>
            <Link
                to="/"
                className="flex items-center gap-2 bg-primary hover:bg-primary/90 text-primary-foreground font-semibold px-6 py-2.5 rounded-xl transition-all"
            >
                <ArrowLeft size={15}/>
                {"Back to Home"}
            </Link>
        </div>;
    }
}
