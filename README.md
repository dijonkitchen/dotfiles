# skills

A collection of agent-agnostic skills for building safer, more capable
AI systems. Each skill is a self-contained directory at the repo root.

## Layout

This repo is designed to be consumed as a git subtree at `.agent/skills/`
in a host project. Skill folders live at the repo root so the subtree
import lands cleanly:

```
host-project/
└── .agent/
    └── skills/
        └── prompt-injection-prevention/
            ├── SKILL.md
            └── scripts/
```

To embed in a host project:

```sh
git subtree add --prefix=.agent/skills \
  https://github.com/dijonkitchen/skills.git main --squash
```

To pull updates later:

```sh
git subtree pull --prefix=.agent/skills \
  https://github.com/dijonkitchen/skills.git main --squash
```

## Available Skills

### [Prompt Injection Prevention](./prompt-injection-prevention/)

A defense framework for LLM-based agents inspired by the **CaMeL**
(_CApability-based Machine Learning_) paper. Protects against prompt
injection attacks through:

- **Taint tracking** — labels data provenance and prevents untrusted content from influencing control flow
- **Capability-based security** — gates every tool invocation behind fine-grained, revocable permissions
- **Input sanitization** — pattern and entropy-based detection of injection payloads
- **Policy enforcement** — configurable rules that allow, deny, or quarantine actions
- **Dual LLM architecture** — isolates trusted and untrusted content into separate processing contexts

```bash
cd prompt-injection-prevention
uv sync
uv run python -m unittest discover -s scripts/tests -v
```

## License

MIT
