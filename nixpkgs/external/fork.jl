#!@julia@/bin/julia

try
    m = match(
        r"origin\s+.+github.com/(?<owner>.+)/(?<repo>.+).git",
        read(
            pipeline(
                `@git@/bin/git remote -v`,
                `@busybox@/bin/grep -E 'origin[[:space:]]+.*github.com/.* \(push\)'`,
            ),
            String,
        ),
    )
    if m[:owner] == "@username@"
        error("`origin` is already owned by `@username@`")
    end
    map(
        run,
        [
            `@git@/bin/git remote rename origin upstream`
            `@git@/bin/git remote add origin https://github.com/rvolosatovs/$(m[:repo]).git`
            `@git@/bin/git remote set-url origin --push ssh://git@github.com/rvolosatovs/$(m[:repo]).git`
        ],
    )
catch err
    @error("failed to fork repo: $err")
end
