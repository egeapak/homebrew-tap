# Homebrew Tap

Homebrew formulae for [egeapak](https://github.com/egeapak) projects.

## Installation

```bash
brew tap egeapak/tap
```

## Available Formulae

| Name | Type | Description | Version |
|------|------|-------------|---------|
| [mergers](https://github.com/egeapak/mergers) | Formula | CLI/TUI tool for streamlining Azure DevOps PR merging via cherry-picking | 1.2.0 |
| [engramdb](https://github.com/egeapak/engramdb) | Formula | Project-scoped persistent memory store for coding agents | 0.9.0 |

### mergers

Requires `gh auth login` (private repository).

```bash
brew install mergers
```

### engramdb

```bash
brew install engramdb
```

EngramDB loads ONNX Runtime at startup rather than bundling it, so the formula
depends on Homebrew's `onnxruntime` and pulls it in automatically. Without a
runtime EngramDB still starts, but semantic search falls back to keyword
matching — `engramdb doctor` reports which runtime was resolved.
