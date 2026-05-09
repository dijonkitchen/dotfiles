# skills

A collection of agent skills for building safer, more capable AI systems.

## Available Skills

### [Prompt Injection Prevention](./.agent/skills/prompt-injection-prevention/)

A defense framework for LLM-based agents inspired by the **CaMeL** (_CApability-based Machine Learning_) paper. Protects against prompt injection attacks through:

- **Taint tracking** — labels data provenance and prevents untrusted content from influencing control flow
- **Capability-based security** — gates every tool invocation behind fine-grained, revocable permissions
- **Input sanitization** — pattern and entropy-based detection of injection payloads
- **Policy enforcement** — configurable rules that allow, deny, or quarantine actions
- **Dual LLM architecture** — isolates trusted and untrusted content into separate processing contexts

```bash
cd .agent/skills/prompt-injection-prevention
uv sync
uv run python -m unittest discover -s scripts/tests -v
```

## License

MIT