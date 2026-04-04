cl import from "lucide-react" {
    ArrowRight, Bot, KeyRound, Layers3, Sparkles, ShieldCheck, Wand2,
    Sun, Moon, Github, ChevronRight, Key, CheckCircle2
}
cl import from ..store.app_store { useAppStore }
cl import from ..hooks.provider_catalog { useProviderCatalog }
cl import from ..components.api_key_modal { ApiKeyModal }
cl import from ..components.ui.button { Button }

cl {
    def HeaderAction(props: Any) -> JsxElement {
        icon = props.icon;
        label = props.label;
        onClick = props.onClick;
        badge = props.badge;

        return <button
            onClick={onClick}
            className="group inline-flex items-center gap-2 rounded-2xl border border-border/70 bg-background/70 px-4 py-2.5 text-sm font-medium text-muted-foreground backdrop-blur transition-all hover:-translate-y-0.5 hover:border-primary/30 hover:bg-card hover:text-foreground"
        >
            <span className="text-primary/80 group-hover:text-primary">{icon}</span>
            <span>{label}</span>
            {badge and
                <span className="rounded-full bg-primary/10 px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.18em] text-primary">
                    {badge}
                </span>
            }
        </button>;
    }

    def ThemeToggle(props: Any) -> JsxElement {
        isDark = props.isDark;
        onToggle = props.onToggle;

        return <button
            onClick={onToggle}
            className="inline-flex items-center gap-2 rounded-2xl border border-border/70 bg-background/70 px-4 py-2.5 text-sm font-medium text-muted-foreground backdrop-blur transition-all hover:-translate-y-0.5 hover:border-primary/30 hover:bg-card hover:text-foreground"
            title={isDark and "Switch to light mode" or "Switch to dark mode"}
        >
            <span className="text-primary/80">{isDark and <Sun size={17}/> or <Moon size={17}/>}</span>
            <span>{isDark and "Light mode" or "Dark mode"}</span>
        </button>;
    }

    def KeySummary(props: Any) -> JsxElement {
        count = props.count;
        return <div className="inline-flex items-center gap-2 rounded-full border border-emerald-500/20 bg-emerald-500/10 px-3 py-1 text-xs font-semibold text-emerald-600 dark:text-emerald-400">
            <CheckCircle2 size={13}/>
            <span>{str(count) + " key" + (count != 1 and "s" or "") + " ready"}</span>
        </div>;
    }

    def:pub page -> JsxElement {
        appStore = useAppStore();
        providerCatalog = useProviderCatalog();

        has showKeys: bool = False;

        def openKeys -> None {
            showKeys = True;
        }

        def closeKeys -> None {
            showKeys = False;
        }

        def openGithub -> None {
            window.open("https://github.com", "_blank", "noopener,noreferrer");
        }

        savedKeyCount = Object.keys(appStore["apiKeys"] or {}).filter(
            lambda(key: Any) -> bool { return bool((appStore["apiKeys"][key] or "").trim()); }
        ).length;

        return <div className="min-h-screen bg-background text-foreground">
            <section className="relative overflow-hidden border-b border-border bg-gradient-to-b from-primary/8 via-background to-background">
                <div className="absolute inset-0 bg-[radial-gradient(circle_at_top,rgba(99,102,241,0.18),transparent_38%)]" />
                <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-primary/40 to-transparent" />

                <div className="relative mx-auto max-w-7xl px-6 pb-16 pt-6 lg:px-10 lg:pb-20">
                    <div className="mb-14 flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
                        <div className="flex items-center gap-3">
                            <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-primary text-primary-foreground shadow-lg shadow-primary/25">
                                <Sparkles size={20} />
                            </div>
                            <div>
                                <p className="text-lg font-black tracking-tight text-foreground">{"JacPlay"}</p>
                                <p className="text-sm text-muted-foreground">{"AI playground built the Jac + Jaseci way"}</p>
                            </div>
                        </div>

                        <div className="flex flex-wrap items-center gap-3">
                            <HeaderAction
                                icon={<Key size={17}/>}
                                label={"Keys"}
                                badge={savedKeyCount > 0 and str(savedKeyCount) or ""}
                                onClick={openKeys}
                            />
                            <HeaderAction
                                icon={<Github size={17}/>}
                                label={"GitHub"}
                                onClick={openGithub}
                            />
                            <ThemeToggle
                                isDark={appStore["isDark"]}
                                onToggle={appStore["toggleTheme"]}
                            />
                        </div>
                    </div>

                    <div className="grid items-center gap-14 lg:grid-cols-[1.08fr_0.92fr]">
                        <div className="max-w-2xl">
                            <div className="mb-5 inline-flex items-center gap-2 rounded-full border border-primary/20 bg-primary/10 px-3 py-1 text-xs font-semibold text-primary">
                                <Sparkles size={14} />
                                <span>{"Built with Jac + Jaseci"}</span>
                            </div>

                            <h1 className="text-5xl font-black tracking-tight text-foreground sm:text-6xl lg:text-7xl">
                                {"Compare AI models with a proper playground UI"}
                            </h1>
                            <p className="mt-5 max-w-xl text-lg leading-8 text-muted-foreground sm:text-xl">
                                {"Open multiple LLMs side by side, manage provider keys cleanly, switch between light and dark mode, and test prompts in one polished Jac-native workspace."}
                            </p>

                            <div className="mt-8 flex flex-col gap-3 sm:flex-row">
                                <a href="/play" className="inline-flex items-center justify-center gap-2 rounded-2xl bg-primary px-6 py-3.5 text-sm font-semibold text-primary-foreground shadow-lg shadow-primary/20 transition-all hover:translate-y-[-1px] hover:bg-primary/90">
                                    <span>{"Open Playground"}</span>
                                    <ArrowRight size={16} />
                                </a>
                                <Button variant="outline" size="lg" onClick={openKeys} className="rounded-2xl">
                                    <KeyRound size={16}/>
                                    {"Manage API keys"}
                                </Button>
                            </div>

                            <div className="mt-6 flex flex-wrap items-center gap-3">
                                <KeySummary count={savedKeyCount}/>
                                <div className="inline-flex items-center gap-2 rounded-full border border-border bg-card/70 px-3 py-1 text-xs font-medium text-muted-foreground">
                                    {appStore["isDark"] and <Moon size={12}/> or <Sun size={12}/>}
                                    <span>{appStore["isDark"] and "Dark mode enabled" or "Light mode enabled"}</span>
                                </div>
                            </div>

                            <div className="mt-10 grid max-w-xl grid-cols-3 gap-3">
                                <div className="rounded-2xl border border-border bg-card/80 px-4 py-4 shadow-sm backdrop-blur">
                                    <div className="text-2xl font-black text-foreground">{"19+"}</div>
                                    <div className="mt-1 text-xs font-medium uppercase tracking-[0.18em] text-muted-foreground">{"Models"}</div>
                                </div>
                                <div className="rounded-2xl border border-border bg-card/80 px-4 py-4 shadow-sm backdrop-blur">
                                    <div className="text-2xl font-black text-foreground">{"5+"}</div>
                                    <div className="mt-1 text-xs font-medium uppercase tracking-[0.18em] text-muted-foreground">{"Providers"}</div>
                                </div>
                                <div className="rounded-2xl border border-border bg-card/80 px-4 py-4 shadow-sm backdrop-blur">
                                    <div className="text-2xl font-black text-foreground">{"Side-by-side"}</div>
                                    <div className="mt-1 text-xs font-medium uppercase tracking-[0.18em] text-muted-foreground">{"Mode"}</div>
                                </div>
                            </div>
                        </div>

                        <div className="relative">
                            <div className="rounded-[28px] border border-border bg-card/90 p-5 shadow-2xl shadow-primary/10 backdrop-blur">
                                <div className="mb-4 flex items-center justify-between border-b border-border pb-4">
                                    <div>
                                        <p className="text-sm font-semibold text-foreground">{"Live playground preview"}</p>
                                        <p className="text-xs text-muted-foreground">{"Keys, theme, and model compare all in one place"}</p>
                                    </div>
                                    <div className="inline-flex items-center gap-2 rounded-full bg-emerald-500/10 px-3 py-1 text-xs font-medium text-emerald-600 dark:text-emerald-400">
                                        <span className="h-2 w-2 rounded-full bg-emerald-500" />
                                        {"Ready"}
                                    </div>
                                </div>

                                <div className="space-y-4">
                                    <div className="rounded-2xl border border-border bg-background p-4">
                                        <div className="flex items-center justify-between gap-3">
                                            <div className="flex items-center gap-3">
                                                <div className="flex h-10 w-10 items-center justify-center rounded-2xl bg-primary/10 text-primary">
                                                    <Key size={18} />
                                                </div>
                                                <div>
                                                    <p className="text-sm font-semibold text-foreground">{"Keys panel"}</p>
                                                    <p className="text-xs text-muted-foreground">{"Add, change, or remove provider keys"}</p>
                                                </div>
                                            </div>
                                            <ChevronRight size={16} className="text-muted-foreground"/>
                                        </div>
                                    </div>

                                    <div className="grid gap-3 sm:grid-cols-2">
                                        <div className="rounded-2xl border border-border bg-background p-4">
                                            <div className="mb-3 flex items-center gap-3">
                                                <div className="flex h-10 w-10 items-center justify-center rounded-2xl bg-primary/10 text-primary">
                                                    <Bot size={18} />
                                                </div>
                                                <div>
                                                    <p className="text-sm font-semibold text-foreground">{"GPT-4o"}</p>
                                                    <p className="text-xs text-muted-foreground">{"Fast reasoning"}</p>
                                                </div>
                                            </div>
                                            <div className="rounded-xl bg-muted px-3 py-2 text-sm text-muted-foreground">
                                                {"Summarize this architecture and suggest improvements."}
                                            </div>
                                        </div>

                                        <div className="rounded-2xl border border-border bg-background p-4">
                                            <div className="mb-3 flex items-center gap-3">
                                                <div className="flex h-10 w-10 items-center justify-center rounded-2xl bg-violet-500/10 text-violet-600">
                                                    <Bot size={18} />
                                                </div>
                                                <div>
                                                    <p className="text-sm font-semibold text-foreground">{"Claude 3.5"}</p>
                                                    <p className="text-xs text-muted-foreground">{"Long-form analysis"}</p>
                                                </div>
                                            </div>
                                            <div className="rounded-xl bg-muted px-3 py-2 text-sm text-muted-foreground">
                                                {"Here’s a structured review with tradeoffs and next steps."}
                                            </div>
                                        </div>
                                    </div>

                                    <div className="rounded-2xl border border-dashed border-primary/30 bg-primary/5 p-4">
                                        <div className="flex items-start gap-3">
                                            <div className="mt-0.5 flex h-9 w-9 items-center justify-center rounded-xl bg-primary/10 text-primary">
                                                <ShieldCheck size={18} />
                                            </div>
                                            <div>
                                                <p className="text-sm font-semibold text-foreground">{"Provider-aware key handling"}</p>
                                                <p className="mt-1 text-sm leading-6 text-muted-foreground">
                                                    {"Click the Keys button anytime to add, update, or remove API keys without leaving the homepage."}
                                                </p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section id="features" className="mx-auto max-w-7xl px-6 py-20 lg:px-10">
                <div className="mb-10 max-w-2xl">
                    <p className="text-sm font-semibold uppercase tracking-[0.2em] text-primary">{"Why JacPlay"}</p>
                    <h2 className="mt-3 text-3xl font-black tracking-tight text-foreground sm:text-4xl">
                        {"A polished Jac homepage with the controls you wanted"}
                    </h2>
                    <p className="mt-4 text-base leading-7 text-muted-foreground">
                        {"The landing page now includes direct key management, theme switching, and a cleaner product-style header while keeping the main focus on opening the playground fast."}
                    </p>
                </div>

                <div className="grid gap-5 md:grid-cols-3">
                    <div className="rounded-3xl border border-border bg-card p-6 shadow-sm transition-all hover:-translate-y-1 hover:shadow-lg">
                        <div className="mb-4 flex h-11 w-11 items-center justify-center rounded-2xl bg-primary/10 text-primary">
                            <Layers3 size={18} />
                        </div>
                        <h3 className="text-lg font-bold text-foreground">{"Multi-model compare"}</h3>
                        <p className="mt-2 text-sm leading-6 text-muted-foreground">{"Open multiple model sessions side by side and compare responses in one workspace."}</p>
                    </div>

                    <div className="rounded-3xl border border-border bg-card p-6 shadow-sm transition-all hover:-translate-y-1 hover:shadow-lg">
                        <div className="mb-4 flex h-11 w-11 items-center justify-center rounded-2xl bg-primary/10 text-primary">
                            <KeyRound size={18} />
                        </div>
                        <h3 className="text-lg font-bold text-foreground">{"Key management"}</h3>
                        <p className="mt-2 text-sm leading-6 text-muted-foreground">{"Use the Keys panel to add, change, and remove provider API keys from one place."}</p>
                    </div>

                    <div className="rounded-3xl border border-border bg-card p-6 shadow-sm transition-all hover:-translate-y-1 hover:shadow-lg">
                        <div className="mb-4 flex h-11 w-11 items-center justify-center rounded-2xl bg-primary/10 text-primary">
                            <Wand2 size={18} />
                        </div>
                        <h3 className="text-lg font-bold text-foreground">{"Prompt enhancement"}</h3>
                        <p className="mt-2 text-sm leading-6 text-muted-foreground">{"Use Jac’s by llm() flow to refine system prompts before sending them to your selected models."}</p>
                    </div>
                </div>
            </section>

            {showKeys and
                <ApiKeyModal
                    providers={providerCatalog["providers"]}
                    onClose={closeKeys}
                />
            }
        </div>;
    }
}
