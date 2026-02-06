# rosetta-brew.fish

This is a wrapper for folks who have multiple [homebrew](https://brew.sh) installs one under native (arm64) and another under rosetta (x86_64).

It'll check if running arm64 or not, and call the appropriate `eval "$(/opt/homebrew/bin/brew shellenv)"`. The result is cached for fast shell startup.

It also works on Linux with [Linuxbrew](https://docs.brew.sh/Homebrew-on-Linux), detecting the correct Homebrew prefix automatically.

## Caching

`brew shellenv` can take ~40–50ms to run, which adds up on every new shell. This plugin caches the output so subsequent shell launches are near-instant.

- **Cache location**: `$XDG_CACHE_HOME/rosetta-brew.fish/` (defaults to `~/.cache/rosetta-brew.fish/`), with a separate file per architecture (e.g., `arm64.fish`, `i386.fish`).
- **Auto-invalidation**: The cache is automatically regenerated when the Homebrew binary is updated.
- **Atomic writes**: Cache files are written atomically to avoid corruption when multiple shells start concurrently.
- **Failure recovery**: If `brew shellenv` fails, the plugin falls back to uncached inline evaluation instead of persisting a broken cache.
- **Manual reset**: Run `brew-cache-reset` to clear the cache — useful after changing Homebrew configuration.

```fish
brew-cache-reset
```

## Installation

Install with [Fisher](https://github.com/jorgebucaran/fisher):

```fish
fisher install scaryrawr/rosetta-brew.fish
```
