cl import from "@jac/runtime" { Link }
cl import from "lucide-react" { Play, ArrowLeft }

cl def:pub page -> JsxElement {
    return <div className="min-h-screen bg-background text-foreground flex items-center justify-center px-6">
        <div className="max-w-lg w-full text-center">
            <div className="mx-auto w-14 h-14 rounded-2xl bg-primary/10 border border-primary/20 flex items-center justify-center mb-6">
                <Play size={22} className="text-primary"/>
            </div>
            <h1 className="text-3xl font-bold tracking-tight">{"Page not found"}</h1>
            <p className="mt-3 text-sm text-muted-foreground leading-relaxed">
                {"That route doesn’t exist. Head back to the home page or jump into the playground."}
            </p>
            <div className="mt-8 flex items-center justify-center gap-3">
                <Link to="/" className="inline-flex items-center gap-2 rounded-xl border border-border bg-card px-4 py-2 text-sm font-semibold hover:bg-accent">
                    <ArrowLeft size={14}/>
                    {"Home"}
                </Link>
                <Link to="/play" className="inline-flex items-center gap-2 rounded-xl bg-primary text-primary-foreground px-4 py-2 text-sm font-semibold hover:opacity-90">
                    <Play size={14}/>
                    {"Play"}
                </Link>
            </div>
        </div>
    </div>;
}
