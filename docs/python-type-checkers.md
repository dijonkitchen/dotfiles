# Evaluating `ty` vs. other Python type checkers

A decision note on whether to adopt [Astral's `ty`](https://github.com/astral-sh/ty)
as the Python type checker for this setup, and what to reach for instead until
it matures. This repo already standardizes on Astral's `uv` (see
[`python.sh`](../python.sh) and [`Brewfile`](../Brewfile)), so `ty` is the
ecosystem-native candidate — but "native" is not the same as "ready."

> **Fast-moving target.** These tools improve weekly. Conformance and speed
> figures below are dated; treat them as a snapshot (mid-2026), not gospel.
> Re-check before committing to a long-lived CI decision.

## TL;DR recommendation

- **CI / source of truth (today): [Pyright](https://github.com/microsoft/pyright).**
  Highest typing-spec conformance (~98%), mature, fast enough, zero install
  friction. It catches the most real bugs with the fewest false positives.
- **Editor + pre-commit (today): `ty`.** Sub-second feedback and a clean
  Salsa-based incremental language server make it a pleasure to edit against,
  even while it's still in beta. Pair it *with* a stricter checker in CI — don't
  rely on it as the gate yet.
- **Only if you need plugins: [mypy](https://github.com/python/mypy).** If a
  project leans on mypy plugins (Django ORM, SQLAlchemy, Pydantic v1), neither
  `ty` nor the other Rust checkers can replace it — they have no plugin system
  and no plans for one.
- **Strongest of the new Rust checkers on correctness:
  [Pyrefly](https://github.com/facebook/pyrefly)** (Meta). If you want a fast
  Rust checker you can put in CI *now*, it conforms far better than `ty` does
  today (1.0, >90% conformance).
- **Revisit `ty` for the gate role at its 1.0.** It's the natural long-term
  fit for an Astral-centric toolchain; it's just not there yet.

## The contenders

| Checker | Author | Lang | Status (mid-2026) | Typing-spec conformance | Speed | Plugins |
| --- | --- | --- | --- | --- | --- | --- |
| **Pyright** | Microsoft | TypeScript | Stable, mature | ~98% (reference-grade) | Fast | No |
| **mypy** | Python org | Python | Stable, mature | ~57% | Slowest | **Yes** |
| **Pyrefly** | Meta | Rust | Stable (1.0) | >90% | Very fast | No |
| **ty** | Astral | Rust | **Beta (0.0.x)** | ~53% and climbing (was ~15% in Aug 2025) | **Fastest** | No |
| Zuban | community | Rust | Newer | ~69% | Very fast | No |

Conformance is measured against the official
[Python typing conformance suite](https://github.com/python/typing/tree/main/conformance).
The numbers move fast and disagree across sources depending on measurement date
— `ty` in particular has been climbing steeply.

## Where each one wins

### `ty` — speed and editor experience

- **Order-of-magnitude faster** than mypy and Pyright. Reported figures put a
  cold check of Django at ~0.5s where Pyright takes ~16s.
- **Best-in-class incrementalism.** `ty` uses [Salsa](https://github.com/salsa-rs/salsa)
  for fine-grained recomputation: a keystroke invalidates only the computations
  that actually depend on the change. Pyrefly recomputes at module granularity.
  For a language server reacting to every edit, that gap is large.
- **Astral-native.** Installs and runs through the same `uv` toolchain this repo
  already uses (`uvx ty check`), configures in `pyproject.toml` under
  `[tool.ty]`, and shares design DNA with Ruff.
- **The catch:** it's beta (`0.0.x`, "expect bugs, missing features, and fatal
  errors"), no stable API, lower conformance than the mature tools, and **no
  plugin system**. It will report things the spec says it shouldn't, and miss
  things it should — both are improving release over release.

### Pyright — the correctness/maturity default

- Reference-grade conformance (~98%) and a battle-tested language server (it
  powers Pylance). Fast enough for most repos. The safest "is my code actually
  type-correct" gate in 2026.
- Downsides: Node/TypeScript runtime (not a single static binary), and its
  strictness defaults can be noisy without tuning.

### mypy — the plugin escape hatch

- The reference implementation and industry baseline. Its real moat now is the
  **plugin ecosystem** — Django, SQLAlchemy, Pydantic v1, attrs. If a codebase
  depends on those, mypy stays, full stop.
- Downsides: the slowest of the bunch; moderate conformance to the spec it
  helped define (much of its behavior predates the formal spec).

### Pyrefly — the fast checker you can gate on today

- Meta's Rust checker hit 1.0 with >90% conformance — far ahead of `ty` on
  correctness — while staying in the same "very fast, low memory" class.
- If the goal is "a modern Rust type checker in CI *right now*," Pyrefly is the
  pragmatic pick over `ty`. `ty` wins on raw editor latency; Pyrefly wins on
  being trustworthy as a gate today.

## Recommendation for this repo

This is a dotfiles repo (shell + config), so there is no Python source here to
type-check — the decision is about what to standardize on **for Python projects
bootstrapped from this environment**, given it's already all-in on Astral's
`uv`.

Adopt a **two-tool split** rather than betting everything on one:

1. **`ty` in the editor and as a `pre-commit` hook** for instant feedback —
   ecosystem-native, fast, and good enough to catch obvious mistakes as you
   type. Use the [official pre-commit hook](https://github.com/astral-sh/ty).
2. **Pyright (or Pyrefly) as the CI gate** for correctness, until `ty` reaches
   1.0 and closes the conformance gap. Switch the gate to `ty` once it's stable
   — at that point a single Astral toolchain (`uv` + `ruff` + `ty`) becomes very
   attractive.
3. **Keep mypy in your back pocket** strictly for projects that need its
   plugins; don't make it the default.

### Minimal `ty` config (when you want it)

```toml
# pyproject.toml
[tool.ty.environment]
python-version = "3.12"

[tool.ty.src]
exclude = ["**/tests/**"]

[tool.ty.rules]
unresolved-import = "warn"
```

```sh
uvx ty check        # one-off, no install
```

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/astral-sh/ty
    rev: ""   # pin to a released tag
    hooks:
      - id: ty
```

## When to re-evaluate

- **`ty` 1.0 ships** (stable API, conformance in the 90s) → promote it to the
  CI gate and collapse to a single Astral toolchain.
- A project picks up a **mypy-plugin-dependent** dependency → mypy stays for
  that project regardless of the above.

## Sources

- [GitHub — astral-sh/ty](https://github.com/astral-sh/ty)
- [ty documentation & configuration reference](https://docs.astral.sh/ty/)
- [How do mypy, Pyright, and ty compare? — pydevtools](https://pydevtools.com/handbook/explanation/how-do-mypy-pyright-and-ty-compare/)
- [mypy vs Pyright vs ty (2026) — danilchenko.dev](https://www.danilchenko.dev/posts/ty-vs-mypy-vs-pyright/)
- [Pyrefly vs. ty — Edward Li](https://blog.edward-li.com/tech/comparing-pyrefly-vs-ty/)
- [How Well Do New Python Type Checkers Conform? — Rob's Blog](https://sinon.github.io/future-python-type-checkers/)
- [Typing Spec Conformance — Pyrefly blog](https://pyrefly.org/blog/typing-conformance-comparison/)
- [Speed and Memory Usage — Pyrefly blog](https://pyrefly.org/blog/speed-and-memory-comparison/)
- [Python type checker ty now in beta — InfoWorld](https://www.infoworld.com/article/4108979/python-type-checker-ty-now-in-beta.html)
