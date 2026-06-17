# Bytecode Alliance AI Tool Policy

All AI-assisted work in any Bytecode Alliance project (wasmtime, wasm-tools,
cranelift, wasi, etc.) must comply with
https://github.com/bytecodealliance/governance/blob/main/AI_TOOL_POLICY.md

- **No AI co-authors.** Do NOT add `Co-Authored-By: Claude ...` trailers to
  commits or PRs in BA repos — only humans may be authors. This overrides the
  default commit-trailer behavior.
- **Human review first.** The author must read and review all AI-generated code
  or text before requesting maintainer review; never present output as ready for
  others to review on their behalf.
- **No autonomous agent actions** (no `@claude`-style auto-acting, no
  auto-publishing review comments without human review).
- **No `good first issue` fixes** using AI.
- **Author writes PR descriptions.** Offer drafts only as raw material, or limit
  to translation/copy-editing if asked.
- **Disclosure is optional.** If wanted, use a trailer like
  `Assisted-by: claude:claude-opus-4-8` instead of a co-author trailer.
- Watch for copyright/licensing issues in generated content.

# LF Decentralized Trust AI Guidelines

All AI-assisted work in any LF Decentralized Trust (LFDT) project — including
Hyperledger and Midnight projects — must comply with the LFDT AI Guidelines
(https://github.com/LF-Decentralized-Trust/governance/pull/321,
`tac/governing-documents/AI-GUIDELINES.md`).

- **Disclosure is required.** Disclose AI assistance with an `Assisted-by`
  trailer in the commit message:
  `Assisted-by: PROVIDER:MODEL_VERSION [TOOL1] [TOOL2]` — e.g.
  `Assisted-by: anthropic:claude-opus-4-8`. `PROVIDER` is kebab-case
  (`anthropic`, `openai`, `google`); `MODEL_VERSION` is the exact model.
  This is in addition to disclosure being merely optional under BA rules.
- **No AI authors or co-authors.** AI cannot be an author or contributor — do
  NOT add `Co-Authored-By: Claude ...` trailers in LFDT repos. Use `Assisted-by`
  instead. This overrides the default commit-trailer behavior.
- **No AI DCO sign-off.** AI agents must NOT add `Signed-off-by` or DCO tags;
  only the human submitter may certify the Developer Certificate of Origin.
- **Human review first.** All AI output must be reviewed by a human before
  submission; AI output is not a code review and does not satisfy a project's
  review requirements.
- **Understand your own code.** The committer is solely responsible for the
  correctness, security, licensing, and maintenance of all submitted code, and
  must be able to explain any part of it.
- **Focused, reviewable PRs.** AI can easily produce large changes; break work
  into small, focused units. Prefer multiple small PRs over one large one, and
  follow each project's conventions and contribution guidelines.
- **No AI governance/approval actions** — AI cannot approve PRs, make governance
  decisions, or vote in elections.
- Watch for copyright/licensing issues; don't feed proprietary or confidential
  code to tools that may store or train on prompts.
- **Exemptions** (no disclosure needed): IDE grammar/spelling fixes, single-line
  autocomplete, and standard formatters (Prettier, gofmt, `nix fmt`, …).
