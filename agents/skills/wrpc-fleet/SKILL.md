---
name: wrpc-fleet
description: Resume the in-flight wRPC PR fleet (unpushed branches, landing plan, open decisions) from ~/wrpc-issues/fleet/HANDOFF.md. Use when the user wants to continue landing wRPC branches/PRs, asks "what's next", "what's the status" or "what's ready" for wRPC work.
---

# Resume the wRPC fleet

1. Read `~/wrpc-issues/fleet/HANDOFF.md` fully. It has the branch table (bases, heads, targets),
   expected conflicts, the step-by-step landing plan, decisions already made (don't relitigate)
   and open decisions.
2. Load the `branch-fleet` skill for the orchestration rules (fresh subagents, review loop,
   verification, merge-queue rebasing, push snippets).
3. Re-verify live state before saying anything: run `~/wrpc-issues/fleet/status.sh` (fetches
   `--no-prune`, prints `origin/main`, every unmerged local branch with head, commits ahead and
   matching open PR, and worktrees). Check the merge queue and fork PRs (#488) by hand.
   `git -C ~/wrpc-issues log --oneline -10` shows what the last sessions recorded.
4. Work **one step at a time**. Say which step of the landing plan is next, give the user the exact
   commands (push snippet rules are in memory `push-via-vm-remote.md`), and wait. After a merge,
   rebase dependent branches (`git rebase --onto origin/main <old parent> <branch>`, keeping a
   `backup/` ref first), re-run their gates, and give the force-push line.
5. Delegated code work: brief fresh agents with `~/wrpc-issues/fleet/agent-rules.md` plus the
   branch, its head, and what's decided. Always pass `model` (`opus`, or `sonnet` for mechanical
   work, per branch-fleet §2); an agent without one runs on this session's model.
6. `~/wrpc-issues` is a git repo and replaces branch-fleet's scratchpad files: `HANDOFF.md` is
   the fleet state and `agent-rules.md` the brief. Keep `HANDOFF.md` current (branch table, current
   step, decisions) and commit after every change, following the README's "How this repo works".
   Record new user decisions in memory as well. Only you write there; agents report.
