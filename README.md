# Homebrew Tap

Homebrew formulae for [egeapak](https://github.com/egeapak) projects.

## Usage

```bash
brew tap egeapak/tap
brew install <formula>
```

Or install directly:

```bash
brew install egeapak/tap/<formula>
```

## Adding a new formula

1. Copy `Formula/example.rb` and rename it to `Formula/<project>.rb`
2. Update the class name, description, homepage, and URLs
3. Generate checksums with `shasum -a 256 <file>` for each release asset
4. Test locally with `brew install --build-from-source Formula/<project>.rb`
5. Validate with `brew audit --strict Formula/<project>.rb`
