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
