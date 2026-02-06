# ---------------------------------------------------------------------------
# rosetta-brew.fish — cached Homebrew shell environment for fish
# ---------------------------------------------------------------------------

# _brew_stat: cross-platform mtime helper (macOS vs Linux)
function _brew_stat --argument-names path
    command stat -f '%m' $path 2>/dev/null; or command stat -c '%Y' $path 2>/dev/null
end

# _brew_cache_dir: resolve XDG-compliant cache directory
function _brew_cache_dir
    if set -q XDG_CACHE_HOME; and test -n "$XDG_CACHE_HOME"
        echo $XDG_CACHE_HOME/rosetta-brew.fish
    else
        echo $HOME/.cache/rosetta-brew.fish
    end
end

# _brew_load_env: source cached shellenv or regenerate if stale/missing
function _brew_load_env --argument-names brew_path cache_file
    set -l current_mtime (_brew_stat $brew_path)

    # Try to validate existing cache
    if test -f $cache_file
        set -l cached_mtime (head -1 $cache_file | string replace '# brew_mtime:' '')
        if test "$cached_mtime" = "$current_mtime"
            source $cache_file
            return
        end
    end

    # Cache miss or stale — regenerate
    set -l cache_dir (string match -r '.*/' $cache_file | string trim --right --chars=/)
    mkdir -p $cache_dir

    set -l tmp_file $cache_file.(random)

    begin
        echo "# brew_mtime:$current_mtime"
        echo "# brew_path:$brew_path"
        $brew_path shellenv fish
    end >$tmp_file
    set -l brew_status $status

    if test $brew_status -eq 0
        command mv -f $tmp_file $cache_file
        source $cache_file
    else
        command rm -f $tmp_file
        $brew_path shellenv fish | source
    end
end

# --- Determine brew path and cache key, then load ---

set -l _brew_cache_dir (_brew_cache_dir)

if string match -q Darwin (uname)
    # macOS — check if we're running arm64 vs Rosetta
    set -l _arch (arch)
    set -l _cache_file $_brew_cache_dir/$_arch.fish

    if test $_arch = arm64
        test -f /opt/homebrew/bin/brew && _brew_load_env /opt/homebrew/bin/brew $_cache_file
    else
        test -f /usr/local/bin/brew && _brew_load_env /usr/local/bin/brew $_cache_file
    end
else
    # Linux or no arch command — iterate candidate paths
    set -l brew_paths /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew
    set -l _cache_file $_brew_cache_dir/default.fish

    for brew_path in $brew_paths
        if test -f $brew_path
            _brew_load_env $brew_path $_cache_file
            break
        end
    end
end

# Clean up internal helper functions (they only need to run once at startup)
functions -e _brew_stat _brew_cache_dir _brew_load_env

# ---------------------------------------------------------------------------
# brew-cache-reset: delete cached shellenv files and print confirmation
# ---------------------------------------------------------------------------
function brew-cache-reset --description "Clear rosetta-brew.fish shellenv cache"
    set -l cache_dir
    if set -q XDG_CACHE_HOME; and test -n "$XDG_CACHE_HOME"
        set cache_dir $XDG_CACHE_HOME/rosetta-brew.fish
    else
        set cache_dir $HOME/.cache/rosetta-brew.fish
    end

    if test -d $cache_dir
        command rm -rf $cache_dir
        echo "rosetta-brew.fish: cache cleared ($cache_dir)"
    else
        echo "rosetta-brew.fish: no cache to clear ($cache_dir)"
    end
end
