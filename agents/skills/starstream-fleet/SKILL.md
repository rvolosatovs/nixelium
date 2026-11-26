---
name: starstream-fleet
description: Resume the in-flight Starstream PR fleet (open PRs, local stacks, issue drafts, open decisions) from ~/starstream-issues/fleet/HANDOFF.md. Use when the user wants to continue landing Starstream branches/PRs, asks "what's next", "what's the status" or "what's ready" for Starstream work.
---

# Resume the Starstream fleet

1. Read `~/starstream-issues/fleet/HANDOFF.md` fully. It has the PR and branch table (bases,
   stacks), the next steps, decisions already made (don't relitigate) and open decisions.
2. Load the `branch-fleet` skill for the orchestration rules (fresh subagents, review loop,
   verification, rebasing, push snippets).
3. Re-verify live state before saying anything: run `~/starstream-issues/fleet/status.sh`
   (fetches `upstream` with `--no-prune`, prints `upstream/main`, every unmerged local branch with
   head, commits ahead and matching PR, and worktrees). When a PR head differs, check which side
   is newer before proposing a push: the user also pushes from elsewhere.
   `git -C ~/starstream-issues log --oneline -10` shows what the last sessions recorded.
4. Work **one step at a time**. Say which step is next, give the user the exact commands, and
   wait. Upstream squash-merges, so after a merge rebase dependent branches with
   `git rebase --onto upstream/main <old base tip> <branch>`, keeping a `backup/` ref first,
   re-run their gates, and give the push line.
5. Delegated code work: brief fresh agents with `~/starstream-issues/fleet/agent-rules.md` plus
   the branch, its head, and what's decided. Always pass `model` (`opus`, or `sonnet` for
   mechanical work, per branch-fleet §2).
6. `~/starstream-issues` is a git repo and replaces branch-fleet's scratchpad files: `HANDOFF.md`
   is the fleet state, `agent-rules.md` the brief, and `NN-slug.md` files are issue drafts the
   user files by hand. Keep `HANDOFF.md` current (PR table, next step, decisions) and commit after
   every change, following the README's "How this repo works". Record new user decisions in
   memory as well. Only you write there; agents report.
7. wRPC gaps found in Starstream go to `~/wrpc-issues` (commit only your own files there); the
   wRPC fleet is resumed separately with `/wrpc-fleet`.
