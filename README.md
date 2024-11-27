# rosetta-brew.fish

This is a wrapper for folks who have multiple [homebrew](https://brew.sh) installs one under native (arm64) and another under rosetta (x86_64).

It'll check if running arm64 or not, and call the appropriate `eval "$(/opt/homebrew/bin/brew shellenv)"`.

It will also attempt to re-order your universal `$fish_user_paths` afterwards so if you have any custom things added to `PATH` it'll be found before finding it in homebrew.

It _should_ also work if you are on linux or not using rosetta.

## Installation

Install with [Fisher](https://github.com/jorgebucaran/fisher):

```fish
fisher install scaryrawr/rosetta-brew.fish
```
