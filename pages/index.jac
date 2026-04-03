"""JacPlay — Landing / home page."""

cl import from "@jac/runtime" { Link }
cl import from "lucide-react" {
    Sparkles, ArrowRight, Play, Zap, Brain, Code2, Eye,
    Shield, Cpu, Globe, GitCompare
}

cl {
    def ModelCategoryCard(props: Any) -> JsxElement {
        icon = props.icon;
        title = props.title;
        desc = props.desc;
        models = props.models;

        return <div className="group bg-card border border-border rounded-xl p-5 hover:border-primary/40 hover:shadow-lg hover:shadow-primary/5 transition-all duration-300">
            <div className="w-9 h-9 rounded-lg bg-primary/10 border border-primary/20 flex items-center justify-center text-primary mb-3 group-hover:bg-primary/15 transition-colors">
                {icon}
            </div>
            <h3 className="text-sm font-semibold text-foreground mb-1">{title}</h3>
            <p className="text-xs text-muted-foreground leading-relaxed mb-3">{desc}</p>
            <div className="flex flex-wrap gap-1.5">
                {models.map(lambda(m: Any) -> JsxElement {
                    return <span
                        key={m}
                        className="text-xs bg-muted text-muted-foreground rounded-full px-2 py-0.5"
                    >{m}</span>;
                })}
            </div>
        </div>;
    }

    def FeatureRow(props: Any) -> JsxElement {
        icon = props.icon;
        title = props.title;
        desc = props.desc;
        return <div className="flex gap-4 items-start">
            <div className="w-9 h-9 rounded-xl bg-primary/10 border border-primary/20 flex items-center justify-center text-primary flex-shrink-0 mt-0.5">
                {icon}
            </div>
            <div>
                <h4 className="text-sm font-semibold text-foreground mb-1">{title}</h4>
                <p className="text-xs text-muted-foreground leading-relaxed">{desc}</p>
            </div>
        </div>;
    }

    def:pub page -> JsxElement {
        return <div className="bg-background">

            <section className="relative overflow-hidden">
                <div className="absolute inset-0 bg-grid-pattern opacity-50"/>
                <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[700px] bg-primary/5 rounded-full blur-[140px] pointer-events-none"/>

                <div className="relative max-w-4xl mx-auto px-5 pt-24 pb-20 text-center">
                    <div className="inline-flex items-center gap-2 bg-primary/10 border border-primary/20 rounded-full px-4 py-1.5 mb-8">
                        <Sparkles size={12} className="text-primary"/>
                        <span className="text-xs font-medium text-primary">{"200+ Models · Built on Jaseci · Open Source"}</span>
                    </div>

                    <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold tracking-tight text-foreground mb-5 leading-[1.1]">
                        {"Play with any "}
                        <span className="text-primary">{"AI Model"}</span>
                        <br/>
                        {"you want"}
                    </h1>

                    <p className="text-base text-muted-foreground max-w-2xl mx-auto mb-10 leading-relaxed">
                        {"Chat with GPT-4o, Claude, Gemini, Llama, DeepSeek and 200+ more. Compare models side by side. Bring your own API key — we never store it."}
                    </p>

                    <div className="flex flex-col sm:flex-row items-center justify-center gap-3">
                        <Link
                            to="/play"
                            className="flex items-center gap-2 bg-primary hover:bg-primary/90 text-primary-foreground font-semibold px-7 py-3 rounded-xl transition-all shadow-lg shadow-primary/25 hover:shadow-primary/40 hover:scale-[1.02]"
                        >
                            <Play size={15} className="fill-current"/>
                            {"Start Playing"}
                            <ArrowRight size={15}/>
                        </Link>
                        <a
                            href="https://aistudio.google.com/app/apikey"
                            target="_blank"
                            rel="noopener noreferrer"
                            className="flex items-center gap-2 bg-muted hover:bg-accent border border-border hover:border-primary/30 text-foreground font-semibold px-7 py-3 rounded-xl transition-all"
                        >
                            <Zap size={15}/>
                            {"Get a Free API Key"}
                        </a>
                    </div>

                    <p className="mt-4 text-xs text-muted-foreground">
                        {"Free models available · No signup required · 100% open source"}
                    </p>
                </div>
            </section>

            <section className="max-w-5xl mx-auto px-5 py-20">
                <div className="text-center mb-12">
                    <h2 className="text-2xl font-bold text-foreground mb-3">{"Every type of model, in one place"}</h2>
                    <p className="text-sm text-muted-foreground">{"Use your own keys — direct to each provider, no middleman"}</p>
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                    <ModelCategoryCard
                        icon={<Sparkles size={16}/>}
                        title="Flagship Models"
                        desc="Best overall performance across writing, coding, reasoning and vision."
                        models={["GPT-4o", "Claude Opus", "Gemini 2.5 Pro"]}
                    />
                    <ModelCategoryCard
                        icon={<Brain size={16}/>}
                        title="Reasoning Models"
                        desc="Extended chain-of-thought for math, science and complex logic."
                        models={["o4-mini", "DeepSeek R1", "Flash Thinking"]}
                    />
                    <ModelCategoryCard
                        icon={<Code2 size={16}/>}
                        title="Coding Models"
                        desc="Optimized for code generation, debugging and architecture."
                        models={["Claude Sonnet", "GPT-4.1", "Qwen Coder"]}
                    />
                    <ModelCategoryCard
                        icon={<Zap size={16}/>}
                        title="Fast and Affordable"
                        desc="Low latency and low cost for high-volume everyday tasks."
                        models={["GPT-4o mini", "Haiku 4.5", "Llama 3.3"]}
                    />
                    <ModelCategoryCard
                        icon={<Eye size={16}/>}
                        title="Vision Models"
                        desc="Understand images, diagrams, screenshots and documents."
                        models={["GPT-4o", "Gemini Flash", "Claude Sonnet"]}
                    />
                    <ModelCategoryCard
                        icon={<GitCompare size={16}/>}
                        title="Side-by-Side Compare"
                        desc="Run the same prompt across multiple models simultaneously."
                        models={["Any model", "Parallel responses", "Easy diff"]}
                    />
                </div>
            </section>

            <section className="bg-card border-t border-b border-border py-20">
                <div className="max-w-4xl mx-auto px-5">
                    <div className="text-center mb-12">
                        <h2 className="text-2xl font-bold text-foreground mb-3">{"Everything you need for serious AI work"}</h2>
                        <p className="text-sm text-muted-foreground">{"Production-ready playground, not a toy"}</p>
                    </div>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-8">
                        <FeatureRow
                            icon={<Shield size={16}/>}
                            title="Your keys, your control"
                            desc="API keys stay in your browser (localStorage). They are never sent to our servers — only directly to the provider."
                        />
                        <FeatureRow
                            icon={<GitCompare size={16}/>}
                            title="Multi-model comparison"
                            desc="Add multiple model tabs and send the same message to all of them simultaneously. See who answers best."
                        />
                        <FeatureRow
                            icon={<Cpu size={16}/>}
                            title="System prompt control"
                            desc="Set a shared system prompt that applies to all active model sessions. Fine-tune behavior and persona."
                        />
                        <FeatureRow
                            icon={<Globe size={16}/>}
                            title="Direct to every provider"
                            desc="Use your own key for OpenAI, Anthropic, Google, DeepSeek, Mistral, Groq and more. No middleman, no markup."
                        />
                        <FeatureRow
                            icon={<Zap size={16}/>}
                            title="Built on the Jaseci stack"
                            desc="100% pure JAC — frontend, backend, and routing in one unified language. Open source and self-hostable."
                        />
                        <FeatureRow
                            icon={<Brain size={16}/>}
                            title="Rich markdown rendering"
                            desc="Responses with code blocks, tables, and formatting render beautifully with syntax highlighting."
                        />
                    </div>
                </div>
            </section>

            <section className="max-w-3xl mx-auto px-5 py-24 text-center">
                <h2 className="text-3xl font-bold text-foreground mb-4">{"Ready to explore the AI landscape?"}</h2>
                <p className="text-muted-foreground mb-8 max-w-xl mx-auto leading-relaxed">
                    {"Pick a model, paste your API key, and start chatting. Free models available with no key required."}
                </p>
                <Link
                    to="/play"
                    className="inline-flex items-center gap-2 bg-primary hover:bg-primary/90 text-primary-foreground font-semibold px-8 py-3.5 rounded-xl transition-all shadow-lg shadow-primary/25 hover:shadow-primary/40"
                >
                    <Play size={16} className="fill-current"/>
                    {"Open the Playground"}
                    <ArrowRight size={16}/>
                </Link>
            </section>

            <footer className="border-t border-border py-8">
                <div className="max-w-5xl mx-auto px-5 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-muted-foreground">
                    <div className="flex items-center gap-2">
                        <div className="w-5 h-5 rounded bg-primary flex items-center justify-center">
                            <Play size={9} className="text-primary-foreground fill-primary-foreground"/>
                        </div>
                        <span>{"JacPlay — Built with "}</span>
                        <a href="https://jaseci.org" target="_blank" rel="noopener noreferrer" className="text-foreground hover:text-primary transition-colors font-medium">{"Jac"}</a>
                        <span>{" by the community"}</span>
                    </div>
                    <div className="flex items-center gap-4">
                        <a href="https://github.com/jaseci-labs" target="_blank" rel="noopener noreferrer" className="hover:text-foreground transition-colors">{"GitHub"}</a>
                        <a href="https://jaseci.org" target="_blank" rel="noopener noreferrer" className="hover:text-foreground transition-colors">{"Jaseci"}</a>
                    </div>
                </div>
            </footer>
        </div>;
    }
}
