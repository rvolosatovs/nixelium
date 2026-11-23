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

# Code Style

- **No explanatory comments.** Do not add comments to code edits; keep any
  rationale in the chat response, not in the source. Only add comments when
  explicitly asked, or when the surrounding code clearly uses them in that spot.

# Scope

- **Simplest thing that works.** Start from the smallest change that meets the
  stated goal and passes a real test; only add to it for a reason the user gave
  or would clearly want. Facts turned up while researching (extra flags, edge
  cases, hypothetical inputs) are not requirements — leave them unhandled and
  say so in the reply instead of coding for them.

# Rust style

The user's standing review preferences, gathered from wrpc, wasmtime,
Starstream and wasm-tokio; project memory adds repo-specific ones.

- `?` ends a statement. Bind with `let` before calling a method
  (`let v = x?; v.foo()`, not `x?.foo()`), and never put `?` inside call or
  macro arguments or operators (`f(g()?)`, `assert_eq!(x.await?, y)`,
  `Ok(a? + b?)`). The same goes for method chains on `.await`, except
  `.unwrap()`, `.expect(..)`, `.unwrap_err()`, `.expect_err(..)`,
  `.context(..)` and `.map_err(..)`; `f(x.await)` and
  `assert_eq!(x.await, y)` are fine. Also fine: `let Some(x) = expr? else
  { .. }` (preferred over a separate binding), and `?` in expression slots of
  macros whose expansion `let`-binds them
  (`$decode!(.., _i => self.read_u8().await?)`).
- Import with `use` instead of qualifying at the call site, preferring
  `core::` paths when the item lives there. Generic free functions stay
  module-qualified: `use core::mem;` then `mem::replace(..)`. Exceptions,
  always fully qualified at the use site: `std::sync::{Mutex, MutexGuard,
  PoisonError}` and most `std::io` items (`std::io::Error`,
  `std::io::ErrorKind`, `std::io::Result`); an upstream repo's own import
  style wins. Separate the `core` and `std` `use` groups with a blank line.
  Tests `use` tokio items (`join`, `try_join`, `spawn`, `yield_now`) but keep
  generic names qualified (`tokio::time::timeout`, `tokio::io::duplex`).
- `#[cfg]` gates code, never `use` lines: fully qualify inside the gated block
  (UFCS for trait methods).
- Construct empty values with `T::default()` whenever `Default` exists
  (`Vec::default()`, `BytesMut::default()`, `Arc::default()`), even in a
  crate that habitually uses `::new()`. Exceptions: `None`, never
  `Option::default()`; unit structs as the bare literal (`FrameEncoder`, as
  clippy requires), without `#[non_exhaustive]` to dodge it.
- Prefer checked conversions and saturating arithmetic
  (`usize::try_from(n).unwrap_or(usize::MAX)`, `saturating_sub`) over `as`
  casts and raw `-`; they avoid silent truncation and overflow panics. `as`
  is right for infallible round-trips (a `usize` clamped to `u32`, widened
  back).
- Ignore fields with the rest pattern: `Ok(..)`, `let (tx, ..) = ..`, not `_`.
- Outside `#[cfg(test)] mod tests`, import through `crate::` paths, never
  `use super::..`; test modules do use `use super::*;`.
- Inline trivial private helpers that only wrap a field access, and keep the
  user's own variable names when refactoring their code, including deliberate
  shadowing.
- Names: a lone generic is `T`; reader/writer generics go input first, but
  values and tuples are `(tx, rx)`. In trait impls write `Self::Assoc`, not
  the concrete type. No private single-use type aliases. Bind channel pairs
  (`let (tx, rx) = channel()`, never `channel().0`). Stored byte-buffer
  fields are `buffer`, not `buf`.
- No `futures::Either` to unify branches: plain `if`/`else` awaiting each.
- Take `impl IntoIterator` when a fn only iterates; slices only for
  indexing; no `BTreeSet` without a need for order or dedup.
- Never `#[allow(dead_code)]`: delete the unused code.
- Tests: define items used by only one test fn inside it.
- Doc comments: the minimal important facts, no narration of the algorithm.
