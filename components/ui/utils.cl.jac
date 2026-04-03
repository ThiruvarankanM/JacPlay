"""cn() utility — merges Tailwind class names with conflict resolution."""

cl import from "clsx" { clsx }
cl import from "tailwind-merge" { twMerge }

def:pub cn(inputs: Any) -> str {
    args = [].slice.call(arguments);
    return twMerge(clsx(args));
}
