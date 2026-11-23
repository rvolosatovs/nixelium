---
name: branch-fleet
description: Orchestrate a batch of small, PR-ready branches with background subagents in git worktrees, then keep them reviewed and rebased while PRs move through review and a merge queue. Use when the user asks to fix a list of issues, "kick off agents", get "small clean focused branches ready for PRs", run review loops on each branch, watch a merge queue and keep rebasing, or asks "what's ready for PR?".
---

# Branch fleet

You are the orchestrator. Subagents do the code work in their own worktrees; you plan, brief, verify,
relay, rebase and report. Keep your own context for decisions and status, not file dumps.

## 0. Before anything

- Read the repo's CLAUDE.md files and the memory index. Their conventions (commit trailers, AI policy,
  code style, test rules, worktree location, push policy) override the defaults below.
- Check what else is running: `git worktree list`, `git status` in the main checkout. **Assume another
  agent may be working in the main checkout**: never edit it, switch its branch, stash in it, or write to
  its build dir. All work happens in worktrees (default `<repo>/.claude/worktrees/<name>`, unless the
  project says otherwise).
- `git fetch --no-prune` only. A repo with `fetch.prune=true` deletes remote-tracking refs other
  sessions depend on; if refs vanish, restore them with an explicit `--no-prune` fetch.
- Check machine resources (`nproc`, `free -g`, `df -h`). Cap parallel heavy builders accordingly (roughly
  one per 1.5–2 GB RAM) and pass build-parallelism limits to agents.
- Never push or open PRs unless the user says so; hand them a push snippet instead (see §6).

## 1. Plan

- One branch per issue, based on the latest default branch, named `<type>/<topic>`. Small and focused
  beats complete; split anything that mixes concerns.
- Group branches into agents by area / shared files (one agent may do several branches sequentially in
  one worktree). Branches touching the same files go to the same agent or get stacked deliberately.
- Stack only when one change truly needs another; record the stack base so it can be rebased with
  `--onto` later.
- Decisions that are genuinely the user's (API shape, protocol/spec semantics, breaking a stated rule):
  make the obviously-recommended call when the user said "fix all", state it, and ask in the same reply;
  otherwise ask before spawning. Check saved memories for prior user decisions that contradict a task
  and surface the conflict instead of silently following either.

## 2. Brief

- Write the shared rules once to a file in the scratchpad from [brief-template.md](brief-template.md),
  filled in with this repo's specifics (gates, test commands, trailer, resource caps, known pitfalls).
- Each agent prompt: "Read and follow `<rules file>`" + its issues/branches/base + what is already
  decided + what is out of scope + anything specific (expected conflicts, files to look at). Agents know
  nothing else; give exact paths, commit SHAs and names.
- One agent per task. Once it reports, retire it: send every follow-up (rebase, review fix, new ask on
  the same branch) to a fresh agent briefed with the branch, its head SHA, what was done and decided,
  and the rules file. SendMessage only for a quick correction while the agent is still mid-task. A
  resumed agent re-reads its whole history every turn and cannot be compacted from outside; reused
  agents reached 500k+ context and 100M+ input tokens, against ~100k for fresh ones. Never kill an agent
  that is close to finishing (final gates), since a replacement would have to redo its setup. Several
  independent agents go out in one message.
- Pass `model` on every spawn; without it an agent (and every reviewer it starts) runs on the
  session's model. `opus` for implementation, conflict resolution, protocol/API design and review
  loops. `sonnet` for mechanical follow-ups: rebases with no expected conflicts, re-running gates,
  scripted moves/renames, applying review fixes already triaged to an exact change; tell it to stop
  and report on any conflict or surprise instead of resolving it. The rules file must not hardcode a
  model ID in commit trailers.
- Agents run in the background; you are notified on completion. Never poll their output files, never
  predict their results.

## 3. Review loop (every branch)

Each branch gets the `code-review` skill once its gates pass: `high` for the first round, `medium` for
later rounds, which mostly check the fixes. Fix real findings by folding them into the commit they
belong to; repeat until a round finds nothing real (cap 3 rounds). Reviews run inside an agent (the
implementing one, or a fresh `opus` one), not in the orchestrator session, since reviewers inherit the
caller's model. Add one review in a fresh `fable` agent when the user asks, or when the change is big
or heavy on new abstractions (new traits, API reshapes, protocol changes); say when you do. Put already-made decisions in the args ("design decided, do not re-report: …") so
reviewers don't relitigate them.

Triage findings honestly: fix real bugs and real coverage gaps; skip style nits, out-of-scope asks and
findings that contradict a user decision, and say which you skipped and why. If a fix opens a can of
worms (e.g. a new normative rule that implementations don't meet), back it out and report the gap.

## 4. Verify and relay

- Verify agent claims cheaply before reporting: `git log --oneline <base>..<branch>`,
  `git merge-base --is-ancestor`, `git diff --stat`, tree equality (`git rev-parse X^{tree}`).
- Relay results compactly: per branch → head, one-line change, test/gate result, review outcome,
  decisions for the user. Lead with what needs the user.
- When the user changes direction: message affected agents immediately (stop / new rule), have them
  abort in-progress rebases and remove worktrees but keep branches, remove now-wrong text from docs,
  and save the decision to memory.

## 5. Merge queue and rebasing

- Watch with Monitor (≤30 min, re-arm on expiry), polling every ~60 s, e.g. for GitHub:
  `gh api repos/O/R/commits/main --jq .sha[0:8]` plus
  `gh api graphql -f query='{repository(owner:"O",name:"R"){mergeQueue(branch:"main"){entries(first:30){nodes{state pullRequest{number}}}}}}'`,
  emitting a line only when the state changes.
- On a new base: `fetch --no-prune`, then rebase every idle branch in a dedicated scratch worktree
  (`git rebase -q origin/main <branch>`, abort on conflict and report). A branch checked out in another
  worktree cannot be rebased elsewhere: that's not a conflict; detach it there or tell its agent.
- Merge queues that rebase or squash give merged commits new hashes: move stacked branches with
  `git rebase --onto origin/main <old-parent-tip> <branch>`. Tell agents working on stacked branches to
  do the same before reporting.
- Queued PRs marked unmergeable/conflicting: resolve ahead of time by rebasing onto the PR that will
  merge first, test, and have the user force-push when that PR lands.
- After a rebase that touched code another merge changed semantically, re-run the relevant
  build/tests before calling it ready.
- Keep `backup/<branch>-<reason>` refs before any history rewrite.

## 6. "What's ready for PR?"

Always re-check live state first (fetch, open PRs and their head SHAs vs local heads, queue), then
answer in this order:

1. **Ready for a new PR**: branch, head, one line.
2. **Open PRs whose local head differs**: PR, branch, GitHub head → local head, why (rebase, review fix,
   message) + one push snippet:
   ```sh
   git fetch <remote>
   for b in <branches>; do git push --force-with-lease origin "<remote>/$b:$b"; done
   ```
3. **In the queue / in review**: one line.
4. **In progress** (agent running) and **blocked on a user decision** (state the decision crisply).

## 7. Housekeeping

- Agents remove their worktrees when done; you remove yours. Branches stay.
- Abandoned work stays as branches (say so), never deleted unasked.
- Save durable user preferences and decisions to memory as they come up (commit message style,
  API decisions, rules like "never X"), and pass them to agents in later briefs. When the user corrects
  how the fleet itself is run, also fold the lesson into this skill. Its source is
  `~/nixelium/agents/skills/branch-fleet/` (the installed copy is a read-only link): edit it there on a
  topic branch and commit.

## 8. Orchestrator context

- Keep `fleet-state.md` in the scratchpad and update it on every change (if the project keeps a
  durable tracker, e.g. a git repo of notes, keep it there and commit each update instead). It records:
  - main head and queue;
  - each open PR's branch, base, GitHub head vs local head, and state;
  - unpushed branches in flight, with stacks, backup refs and pending conflicts;
  - running agents with their task and context size;
  - worktrees.
  
  After a compaction, read it first instead of re-deriving state from git.
- The orchestrator grows about 1k tokens per turn, since notifications and monitor events wake it often.
  Suggest a /compact at about 200k context, at a quiet moment: after relaying a batch, with no result
  waiting to be relayed. With a durable tracker (e.g. a resume skill over a handoff file), suggest
  `/clear` plus the resume skill instead, after saving state there: a fresh start costs less than a
  summary and drops stale detail. Much earlier loses SHAs and conflict notes; much later re-reads 300k+ every turn.
- Measure, don't guess: each transcript line with `message.usage` gives context as
  `input + cache_read + cache_creation`. Agent transcripts are the task `.output` files; the
  orchestrator's is `~/.claude/projects/<proj>/<session>.jsonl`.
