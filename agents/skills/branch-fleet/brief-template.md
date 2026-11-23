# Shared rules for branch agents (template)

Copy to the session scratchpad, fill in every `<…>`, delete lines that don't apply, then point each agent
at the copy.

---

# Rules for this batch

Several agents work in parallel, each on its own branches. Your prompt lists your issues, branch names
and base. Goal: **small, clean, focused branches ready for PRs**.

## Isolation

- Another agent may be working in `<main checkout>` (branch `<branch>`). Never edit it, switch its
  branch, stash there, or touch its build dir (`<target dir>`). Don't touch other agents' branches or
  worktrees.
- Work only in your worktree: `git -C <repo> worktree add <repo>/.claude/worktrees/<name> -b <branch> <base>`.
  Further branches in the same worktree: commit, then `git switch -c <branch> <base>`.
- `git fetch --no-prune` only.
- Don't push or open PRs.

## Resources (<cores> cores, <RAM> GB RAM, ~<disk> GB free, shared by ~<n> builders)

- `<env, e.g. CARGO_INCREMENTAL=0 CARGO_BUILD_JOBS=2>` for every build.
- Build only what you touch; full gates only on touched packages.
- If disk gets low, clean only inside your worktree and say so in the report.

## Conventions

- Read `<CLAUDE.md files>` and the memory index `<path>/MEMORY.md` plus every linked memory relevant to
  your change; they are the user's standing feedback and override anything here.
- Decisions already made by the user (do not relitigate): `<list>`.
- Simplest change that works; match surrounding code; no explanatory comments unless the surrounding
  code uses them there.
- Tests: concise, happy path + the edge case the change is about, in the repo's existing test layout.
  Build first, then run tests under `timeout <N>` with output to a log file. A test that needs longer is a
  bug to report. Prove the key test fails without the fix.
- Commits: atomic; subject `type(scope): summary`, ≤50 chars; blank line; `<trailer per repo policy,
  with your own model ID>`;
  **no body**. No `Co-Authored-By`/`Signed-off-by` unless the repo requires it.
- Fold follow-up fixes into the commit they belong to (`git commit --fixup` + autosquash); keep each
  commit building on its own.

## Gates

`<format check>`, `<lint on touched packages>`, `<docs build>`, `<relevant tests>`.

## Review loop

After gates pass: run the `code-review` skill (args `high <worktree path> (branch <b> vs <base>)`; `medium`
for later rounds). Fix real findings (folded), re-run gates, repeat until a round finds nothing real
(max 3 rounds).
Skip findings that contradict a decision above or are out of scope, and note why.

## When done

Remove your worktree (`git worktree remove --force <path>`; the branch stays).

Final report, short: per branch → head + `git log --oneline <base>..<branch>`, one-paragraph summary,
gate/test results (real output; failures stated plainly), review rounds (fixed/skipped), open questions
or decisions for the user. If you hit a fundamental blocker, stop and report it instead of hacking
around it.
