# Copilot Instructions

## Project Overview

A [fish shell](https://fishshell.com/) plugin that configures Homebrew shell environment (`brew shellenv`) for systems with multiple Homebrew installs (native arm64 and Rosetta x86_64). Installed via [Fisher](https://github.com/jorgebucaran/fisher).

## Architecture

- `conf.d/brew.fish` — The entire plugin (single file). Fish shell auto-sources files in `conf.d/` on startup via Fisher's convention.
- On macOS: uses `arch` to select `/opt/homebrew` (arm64) vs `/usr/local` (x86_64/Rosetta).
- On Linux: iterates candidate brew paths including `/home/linuxbrew/.linuxbrew/bin/brew`.
- **Caching layer**: `brew shellenv` output is cached per-architecture in `$XDG_CACHE_HOME/rosetta-brew.fish/` (default `~/.cache/rosetta-brew.fish/`). Cache is invalidated by comparing the brew binary's mtime. Writes are atomic (write to temp file, then `mv`). On `brew shellenv` failure, falls back to uncached inline eval.
- **Helper functions** (`_brew_stat`, `_brew_cache_dir`, `_brew_load_env`) are defined at the top of the file, used during startup, then erased with `functions -e` so they don't pollute the user's shell namespace.
- `brew-cache-reset` is a persistent user-facing function (not erased) that clears the cache directory.

## Conventions

- Follow [fish shell scripting syntax](https://fishshell.com/docs/current/language.html) — `test`, `if`/`else`/`end`, `set -l` for locals.
- Use `type -q` for command existence checks and `test -f` for file existence.
- Fisher plugins use the `conf.d/` directory convention — files there run automatically on shell startup.
- Internal/private helper functions are prefixed with `_brew_` and erased after use via `functions -e`.
- No build, test, or lint tooling — the plugin is a single fish script. Test manually by sourcing `conf.d/brew.fish` in a fish shell.
