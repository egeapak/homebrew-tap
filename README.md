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
| [clove](https://github.com/egeapak/clove) | Formula | Fast, git-native, dependency-aware work-item tracker | 0.2.0 |
| [clove-sync-github](https://github.com/egeapak/clove) | Formula | Two-way GitHub Issues sync for clove | 0.2.0 |
| [clove-import-tk](https://github.com/egeapak/clove) | Formula | Import tk tickets into clove | 0.2.0 |
| [clove-import-beads](https://github.com/egeapak/clove) | Formula | Import and export Beads issues for clove | 0.2.0 |

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

### clove

```bash
brew install clove                 # clove + the cloved daemon
brew install clove-sync-github     # optional: `clove sync github`
brew install clove-import-tk       # optional: `clove import tk`
brew install clove-import-beads    # optional: `clove import|export beads`
```

Run `clove init` in a repository to start tracking work, and `clove setup` to
wire it into Claude Code. The plugin formulae depend on `clove` and install from
the same release archive, which Homebrew has already cached, so they don't
download it again. To bump all four, edit `version` and the checksums in
`lib/clove_release.rb`.
